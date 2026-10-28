import os
import json
import re
from typing import List, Dict
from ..core.ir import TableMeta, FieldMeta
from ..core.sql_tables import validate_table_ref
from ..config import ODS_SCHEMA_TMPL, HIVE_DYNAMIC_PARTITION_SETTINGS, SYS_FIELDS_ODS
from ..core.type_mapper import oracle_to_hive
from ..generator.ddl_common import (generate_ddl_body, build_field_defs,
                                    escape_sql_comment, quote_hive_column,
                                    quote_hive_column_sh,
                                    ORACLE_NUMERIC_PREFIXES, ORACLE_DATE_PREFIXES, ORACLE_CHAR_PREFIXES)
from tools.utils.table_utils import write_file, iter_ods_tables, write_file_safe
from tools.utils.validation import validate_db_identifier
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

# SQL 关键字/函数白名单：incr_cond 里出现这些不算「列名」，不参与存在性校验
_SQL_RESERVED = {
    "and", "or", "not", "between", "is", "null", "to_date", "date", "trunc",
    "sysdate", "current_date", "to_char", "nvl", "coalesce", "case", "when",
    "then", "else", "end", "like", "in", "select", "from", "where",
}

# 日期列的命名特征：HSFA 源库一律是 D_ 开头（D_DATE / D_RQ / D_YWRQ / D_MAKE …），
# 兜底再认 _DT / _DATE / _RQ / _TIME 后缀，避免漏掉别的命名风格。
_DATEISH_COL = re.compile(r"(?:^D_|_DT$|_DATE$|_RQ$|_TIME$|_RQ_)")

# Hive 类型白名单：_TMP 与正式表 DDL 的列类型只能是这些之一。
# ★ 2026-10-09 起因（J-01）：ZTA 字段级调研「转换后字段类型」有 **47 格被填成了
#   别的字段英文名**（整列错位）甚至整个 `CASE WHEN …` 表达式，直接拼进 DDL ⇒
#   `D_REGDATE  C_CSERIALNO  COMMENT …` → Hive `ParseException: in column type`，
#   _TMP 表根本建不出来，HdfsWriter 随后报 path does not exist。
#   上游 47 格已订正（清空、回落到 oracle_to_hive 推导，见 ODS问题汇总.xlsx J-01）；
#   这里再加一道兜底：非法类型**告警 + 降级 STRING**，保证最坏情况 DDL 仍可执行。
# ★★★ 2026-10-26：复用 ddl_common._VALID_HIVE_TYPE 而不是维护两套正则（H1）。
from tools.generator.ddl_common import _VALID_HIVE_TYPE as _HIVE_TYPE_RE

# 派生列：字段级调研里有、但**源表里没有**的列（A-01）。
#   key   = 目标列名（大写）
#   value = (Oracle 表达式模板, 取值源列)；模板里的 {col} 会替换成**已加引号**的源列。
# ★ 只作用于 DataX 的 querySql（Oracle 侧）。Hive 侧 INSERT 是从 _TMP 里选
#   同名列，名字本来就对，**不能动**。
_DERIVED_COLS = {
    # HSFA.TVOUCHERS：源 36 列 + D_MAKE_NUM + LD_TIME（与源库实测 36 列吻合）。
    #   D_MAKE 是 DATE ⇒ 转成 8 位 yyyyMMdd 才与 DWD 口径一致。
    "D_MAKE_NUM": ("TO_NUMBER(TO_CHAR({col},'YYYYMMDD'))", "D_MAKE"),
}

# Oracle 保留字：作为【列名】时必须加双引号引用，否则 Oracle 会把它解析成 SQL 语法元素。
# ★ 2026-10-08 起因：JYDB.LC_MAINOPERINCOME 的 LEVEL 列生成出 `SELECT … , LEVEL`
#   → DataX oraclereader 执行时报 `ORA-01788: 此查询块中要求 CONNECT BY 子句`
#   （LEVEL 是层次查询 CONNECT BY 的伪列，Oracle 见到裸 LEVEL 就以为在做层次查询）。
#   同类地雷还有 ODS_JY_MF_FUNDARCHIVES_PFD 的 TYPE 列，当时还没跑到所以没暴露。
# ★ 本清单只用于【列名引用】加引号，不参与 incr_cond 改写（那段是人工录入的自由文本，
#   见 _validate_incr_columns 的说明：不做语法改写以免破坏合法 SQL）。
ORACLE_RESERVED_WORDS = frozenset("""
ACCESS ADD ALL ALTER AND ANY AS ASC AUDIT BETWEEN BY CHAR CHECK CLUSTER COLUMN
COMMENT COMPRESS CONNECT CREATE CURRENT DATE DECIMAL DEFAULT DELETE DESC DISTINCT
DROP ELSE END EXCLUSIVE EXISTS FILE FLOAT FOR FROM GRANT GROUP HAVING IDENTIFIED
IMMEDIATE IN INCREMENT INDEX INITIAL INSERT INTEGER INTERSECT INTO IS LEVEL LIKE
LOCK LONG MAXEXTENTS MINUS MLSLABEL MODE MODIFY NOAUDIT NOCOMPRESS NOT NOWAIT NULL
NUMBER OF OFFLINE ON ONLINE OPTION OR ORDER PCTFREE PRIOR PUBLIC RAW RENAME
RESOURCE REVOKE ROW ROWID ROWNUM ROWS SELECT SESSION SET SHARE SIZE SMALLINT
START SUCCESSFUL SYNONYM SYSDATE TABLE THEN TO TRIGGER TYPE UID UNION UNIQUE
UPDATE USER VALIDATE VALUES VARCHAR VARCHAR2 VIEW WHENEVER WHERE WITH
""".split())


def quote_oracle_column(name: str) -> str:
    """Oracle 源侧的列名引用：保留字加双引号，其余原样返回。

    注意必须用**原样大小写**（这里源列名本来就是大写），
    因为 Oracle 数据字典里存的是大写标识符，`"level"` 反而对不上。
    """
    return '"%s"' % name if name.upper() in ORACLE_RESERVED_WORDS else name



def _extract_incr_col(incr: str, fields: list) -> str:
    """从 incr_cond 里抽出【增量日期列】的原文列名，抽不到返回 ''。

    为什么需要它
    ------------
    增量表的目标表走【动态分区】`PARTITION(P_DT)`，P_DT 的值原先恒取运行日
    `'${p_end_dt}'`。但业务上分区值应当**取该行自己的增量日期列**（如 `L_DATE`
    的 `20261008`），这样同一次抽数落在多个日期时能自动分到多个分区。

    incr_cond 是人工录入的自由文本，形态实测只有两类：
      - 裸列名：`L_DATE` / `TRADINGDAY` / `D_CDATE`
      - 列名带前缀/修饰：`T.D_CDATE`
    本函数只认这两种（取【最后一个点号后的标识符】），且要求它**确实是
    fields 里的列**（大小写不敏感），否则返回 ''（调用方退回老行为）。

    ★ 刻意不做通用 SQL 解析：`incr_cond` 也可能是 `L_YEAR+L_MONTH` 这种
      表达式，硬解析会把 `L_MONTH` 当成列名用错。宁可退回 `'${p_end_dt}'`。
    """
    if not incr:
        return ""
    known = {str(f.src_name).upper(): str(f.src_name) for f in fields}
    # 只接受「可选前缀 + 裸标识符」，整串匹配
    m = re.fullmatch(r"\s*(?:[A-Za-z_][A-Za-z0-9_]*\s*\.\s*)*([A-Za-z_][A-Za-z0-9_]*)\s*", incr)
    if not m:
        return ""
    ident = m.group(1)
    return known.get(ident.upper(), "")


def _incr_col_type(col: str, fields: list) -> str:
    """取增量日期列在【TMP 表里】的 Hive 类型（TMP 建表用的是 f.hive_type）。"""
    for f in fields:
        if str(f.src_name).upper() == col.upper():
            return (f.hive_type or "STRING").upper()
    return "STRING"


def _incr_col_src_type(col: str, fields: list) -> str:
    """取增量日期列在【Oracle 源库】里的类型（f.src_type，如 DATE / CHAR(8) / NUMBER(8,0)）。

    ★★ 为什么必须用源类型而不是 TMP 类型
    ------------------------------------
    三路分支（WHERE 上下界写法 / 是否 TO_CHAR / P_DT 表达式）全部取决于
    **源库列的真实类型**，而 TMP 侧类型会把信息抹平：
      - `DATE`       → oracle_to_hive ⇒ STRING
      - `CHAR(8)`    → STRING
      - `VARCHAR2`   → STRING
    这三者落 TMP 后**都是 STRING**，光看 hive_type 分不开，
    但它们在 Oracle 侧的谓词语义完全不同（见 _build_where_pred 的实测表）。
    """
    for f in fields:
        if str(f.src_name).upper() == col.upper():
            return (f.src_type or "").upper()
    return ""


def _is_ora_date_type(src_type: str) -> bool:
    return src_type.startswith(ORACLE_DATE_PREFIXES)


def _is_ora_number_type(src_type: str) -> bool:
    return src_type.startswith(ORACLE_NUMERIC_PREFIXES)


def _is_ora_char_type(src_type: str) -> bool:
    return src_type.startswith(ORACLE_CHAR_PREFIXES)


def _build_where_pred(incr: str, src_type: str) -> str:
    """按增量列在 Oracle 里的类型，生成 between 的上下界谓词（含列名）。

    ★★★ 2026-10-09 用户拍板的最终规则（两条，极简）：
      - **日期类型** → `TO_DATE('${p_start_dt}','YYYYMMDD')`
      - **其余一切** → 裸字符串 `'${p_start_dt}'`

    ★ 为什么格式串是 `'YYYYMMDD'` 而不是 `'YYYY-MM-DD'`
    -------------------------------------------------
    `${p_start_dt}` 由 DS 的 `${system.biz.date}` 展开，运行时是 **`20261007`**
    （8 位无横杠）。写 `'YYYY-MM-DD'` 其实也能解析（Oracle 对分隔符较宽容，
    实测 `TO_DATE('20261007','YYYY-MM-DD')` = 2026-10-07），但格式串与实际值
    不匹配属于"碰巧能跑"，改成 `'YYYYMMDD'` 才是正解。

    ★ 为什么非日期型可以直接裸字符串比较
    ------------------------------------
    实测（2026-10-09，Oracle XE）：
      - `NUMBER` 列 `L_DATE between '20200101' and '20261231'` ⇒ **不报错**
        （数字优先级更高，Oracle 把字面量隐式转成 NUMBER）——**不再需要 TO_NUMBER(REPLACE(...))**；
      - `CHAR(8)` 列 `D_CDATE between '20200101' and '20261231'` ⇒ **不报错**（同为字符，直接比）。
    而原实现一刀切 `TO_DATE` 会让 NUMBER 报 ORA-00932、让字符型"静默 0 行"（详见下）。
    ⇒ 裸字符串一种写法同时覆盖 NUMBER/CHAR/VARCHAR2，比三路分支更简洁。

    （历史背景，保留备查：159 个增量表的 Oracle 探针显示，一刀切 `TO_DATE` 时
      `DATE` 68 张 OK / `NUMBER` 58 张 ORA-00932 / `CHAR|VARCHAR2` 25 张**静默 0 行**
      —— 最后一类不报错但一行都抽不到，最危险。）
    """
    if _is_ora_date_type(src_type):
        lo = "TO_DATE('${p_start_dt}','YYYYMMDD')"
        hi = "TO_DATE('${p_end_dt}','YYYYMMDD')"
    else:
        lo = "'${p_start_dt}'"
        hi = "'${p_end_dt}'"
    return f"{incr} between {lo} and {hi}"


def _query_col_expr(col: str, src_type: str) -> str:
    """生成 DataX querySql 里该列的表达式（DATE 型包 TO_CHAR）。

    ★★★ 为什么 DATE 型必须包 TO_CHAR
    --------------------------------
    DataX 的 oraclereader 读 DATE 列时**不带格式串**，Oracle 按会话
    `NLS_DATE_FORMAT=DD-MON-RR` 输出 ⇒ 落到 TMP 的字符串是 **`07-OCT-26`**，
    不是 `20261007`。这有两个后果：
      ① P_DT 直接取该列 ⇒ 分区值变成 `07-OCT-26`，完全对不上业务日期；
      ② 正式表里那一列的值也是 `07-OCT-26`，下游 DWD 解析不了。

    ⇒ 在 querySql 层就 `TO_CHAR(<col>,'YYYYMMDD')`，让落 TMP 的值直接是
      `20261007`（8 位），P_DT 与正式表两侧都对。

    ★ 必须保留原列名作别名（`TO_CHAR(X,'YYYYMMDD') X`）：
      DataX 的 writer `column[].name` 是按列名匹配的，少了别名会对不上。

    ★ 列名引用走 quote_oracle_column（保留字如 LEVEL 要加双引号），
      且双引号必须加在 **TO_CHAR 里面** —— 写成 `TO_CHAR("LEVEL",...)`。
      若加到外面（`"TO_CHAR(LEVEL,...)"`）会变成一整个带引号的标识符，直接报错。

    ★ 派生列（A-01）：字段级调研里有、源表里没有的列（如 HSFA.TVOUCHERS 的
      `D_MAKE_NUM`）直接当列名引用必然 `ORA-00904`。这类列在 _DERIVED_COLS 里
      声明了取值表达式，此处改出表达式 + 保留原名作别名（writer 按列名匹配）。
    """
    d = _DERIVED_COLS.get((col or "").upper())
    if d:
        tmpl, src = d
        return f"{tmpl.format(col=quote_oracle_column(src))} {col}"
    q = quote_oracle_column(col)
    if _is_ora_date_type(src_type):
        return f"TO_CHAR({q},'YYYYMMDD') {col}"
    return q


def _build_p_dt_expr(incr_col: str, src_type: str, hive_type: str) -> str:
    """构造增量表 P_DT 的取值表达式 —— 目标恒为【8 位 yyyyMMdd 字符型】。

    ★★★ 2026-10-09 用户拍板的最终规则：
      - **日期类型** → `REPLACE(<col>,'-','')`（把横杠去掉，得到 8 位 yyyyMMdd）
      - `NUMBER`    → `CAST(<col> AS STRING)`（TMP 是 `DECIMAL(8,0)`，不 CAST 会被当 INT）
      - 字符型      → 直接取列名（TMP 是 STRING，源值本就是 `'20261007'`）
      - 类型未知    → 退回按 TMP 的 hive_type 猜

    ★ 为什么日期型用 REPLACE 而不是直接取列
    -------------------------------------
    `REPLACE` 对两种可能都成立，属**防御式写法**：
      - 列值是 `20261007`（本实现 querySql 用 `TO_CHAR(col,'YYYYMMDD')` 时）
        ⇒ REPLACE **无副作用**，仍是 `20261007`；
      - 列值是 `2026-10-07`（若上游/别的口径落成带横杠）
        ⇒ REPLACE 得到 `20261007`，**正好是想要的 8 位**。
    ⇒ 无论 DataX 那一侧怎么落，P_DT 都稳定是 8 位 yyyyMMdd。
    ★ 刻意**不**用 `SUBSTR(...,1,10)` 之类截断 —— 若值里带了时间部分，
      REPLACE 不去掉空格，会被 Hive 当成含空格的字符串分区名（能看出异常，好过静默截断）。

    ★ NULL **不兜底**（不加 NVL/COALESCE）—— 允许出现 P_DT=NULL 分区。
    """
    if _is_ora_date_type(src_type):
        return f"REPLACE({incr_col},'-','')"
    if _is_ora_number_type(src_type):
        return f"CAST({incr_col} AS STRING)"
    if _is_ora_char_type(src_type):
        return incr_col
    # 源类型未知 ⇒ 退回按 TMP 类型猜（老逻辑）
    if hive_type.startswith("DECIMAL") or hive_type in ("BIGINT", "INT", "DOUBLE", "FLOAT"):
        return f"CAST({incr_col} AS STRING)"
    return incr_col


def _validate_incr_columns(incr: str, fields: list, ods_table: str) -> None:
    """校验增量条件 incr_cond 引用的列是否存在于字段清单中（仅告警，不阻断）。

    为什么需要它
    ------------
    incr_cond 来自人工填写的调研文档，列名可能写错。实测案例：
      - `HSFA.T_H_FYMX` 日期列实际叫 `D_YWRQ`，文档填 `D_RQ`
        → 生成 `WHERE D_RQ between ...` → Oracle `ORA-00904: "D_RQ": 标识符无效`
      - `ODS_HSFA_TVOUCHERSJC_PTD` 填了 `L_YEAR+L_MONTH`（数值），永远不等于 DATE
    这类错误只有跑 DataX 时才暴露，反馈周期很长。这里在生成阶段就打 WARNING。

    做法
    ----
    从 incr_cond 里抽标识符，剔除 SQL 关键字后，逐个比对 fields 的 src_name。
    缺一个就 WARNING（不抛异常 —— incr_cond 可能是合法的函数/表达式，误报人工确认即可）。
    """
    known = {str(f.src_name).upper() for f in fields}
    # ★ 先按「点号分隔的标识符链」提取，再取每链【最后一段】作为列名候选。
    #   否则 `T.D_CDATE` 被拆成 `T` + `D_CDATE` 两段，`T`（表别名）会被误判成
    #   「字段清单里不存在的列」⇒ 诱导用户去「订正」一个本就合法的带别名写法。
    tokens = re.findall(
        r"[A-Za-z_][A-Za-z0-9_]*(?:\s*\.\s*[A-Za-z_][A-Za-z0-9_]*)*", incr)
    candidates = [
        tok.split(".")[-1] for tok in tokens
        if tok.split(".")[-1].lower() not in _SQL_RESERVED
    ]

    missing = [i for i in candidates if i.upper() not in known]
    if missing:
        logger.warning(
            f"  ⚠ 表 {ods_table} 的增量条件 incr_cond='{incr}' 引用了 "
            f"字段清单里不存在的列: {missing}（该表已有列共 {len(known)} 个）。"
            f"这通常是**调研文档填错列名**，生成的 SQL 会报 ORA-00904，请回上游订正。"
        )

    # 第二道防线：列名存在，但"看起来不是日期列"。
    # 增量条件会拼成 `WHERE <col> between TO_DATE(...) and TO_DATE(...)`，
    # 若 <col> 是数值列（如 L_YEAR+L_MONTH）必然 ORA-00932（NUMBER vs DATE）。
    # 实测 HSFA 78 张 ODS 的 23 张增量表：22 张是 D_ 开头（D_DATE/D_RQ/D_YWRQ/D_MAKE…），
    # 仅 TVOUCHERSJC 用 L_YEAR+L_MONTH（真阳性），该启发式零误报。
    suspicious = [i for i in candidates if i.upper() in known and not _DATEISH_COL.search(i.upper())]
    if suspicious:
        logger.warning(
            f"  ⚠ 表 {ods_table} 的增量条件 incr_cond='{incr}' 使用了疑似非日期列: {suspicious}。"
            f"增量条件会生成 `WHERE {incr} between TO_DATE(...) and TO_DATE(...)`，"
            f"若该列实际是数值/字符型会报 ORA-00932（数据类型不一致）。"
            f"请确认列名，或改用真正的日期列；确无日期列则该表只能全量抽取。"
        )


def _safe_hive_type(raw: str, src_name: str, ctx: str) -> str:
    """列类型兜底：空 → STRING；非法（填了列名/表达式）→ 告警 + 降级 STRING。

    背景见 _HIVE_TYPE_RE 的注释（J-01）。这里**只告警不阻断**：调研文档是
    人工录入的，宁可生成一个能执行的 STRING 列，也不要让整批 DDL 报
    `ParseException: in column type` 连表都建不出来 —— 后者要等到跑批才发现。
    """
    t = (raw or "").strip()
    if not t:
        return "STRING"
    if _HIVE_TYPE_RE.match(t):
        return t
    logger.warning(
        f"  ⚠ {ctx} 列 {src_name} 的 hive_type={t!r} 不是合法 Hive 类型，"
        f"已降级为 STRING（否则 DDL 报 Hive ParseException: in column type）。"
        f"请回调研文档订正「转换后字段类型」列。")
    return "STRING"


# ============================================================================
# DDL 生成函数 (保持不变)
# ============================================================================

def _escape_sql_for_json(sql: str) -> str:
    r"""★ 2026-10-09（J-05）：把 querySql 转义后才能嵌进 `.sh` 里的 JSON 字符串。

    ★★★ 为什么必须做：
    ETL 模板里写的是 `"querySql": ["${query_sql}"]` —— querySql 是**原样塞进
    JSON 字符串字面量**的。而 Oracle 保留字列（LEVEL / TYPE）必须加双引号，
    实测表 `JYDB.LC_MAINOPERINCOME` 生成的 JSON 变成：
        "querySql": ["SELECT … , "LEVEL" FROM JYDB.LC_MAINOPERINCOME …"]
    裸双引号直接把 JSON 结构打破，DataX 报：
        Code:[Common-00] 您提供的配置信息不是合法的JSON格式: TODO : L
    （`TODO : L` 是解析器撞到裸标识符 `L` 的提示，`L` 正是 LEVEL 的首字母。）

    ★ heredoc 转义实测（`.dx-tmp/heredoc-test.sh`）：
      在 `.sh` 的 `<<EOF`（无引号）里写 `\\"` 或 `\\"`，**最终落盘都还是 `\\"`**
      （`"` 在 heredoc 里不是特殊字符，只有 `$` / `` ` `` / `\\` 有含义）
      ⇒ **只需转义一层**，不必double-escape。

    ★ 顺序：先转义反斜杠再转义引号，否则会把刚加上的反斜杠二次转义。
    ★ 2026-10-26（评审）：**控制字符也必须转义**。querySql 由多行 SQL 拼成
      （`_build_query_sql` 用 `"\n".join`），此前只转义 `\` 和 `"` ⇒ 换行原样留在
      JSON 字符串里 ⇒ 按 RFC 8259 属**非法 JSON**（实测 12/12 个 ODS 脚本
      `json.loads` 报 `Invalid control character`）。DataX 的解析器较宽松，目前
      "碰巧能跑"，但任何严格解析（校验脚本/其它工具链）都会失败。
      ⇒ 换行/回车/制表符一律转成 JSON 转义序列，解码后取值与原 SQL 完全一致。
    """
    s = sql.replace("\\", "\\\\").replace('"', '\\"')
    # 反斜杠已转义完，此处新增的 `\n` 等是**期望的单层 JSON 转义**，不能再被加倍
    return s.replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t")


def generate_ods_ddl(table: TableMeta, fields: list, sys_name: str) -> str:
    """生成单张 ODS 表的建表 DDL"""
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)
    # ★ 2026-09-28 修 bug：这里【只能放裸表名】。
    #   原写法 `tbl = f"{schema}.{table.ods_table}"` 已自带 schema，而下游
    #   generate_ddl_body 又拼了一次 `f"CREATE TABLE {schema}.{tbl} ("`
    #   → 生成 `CREATE TABLE ODS_XDAY_HSFA.ODS_XDAY_HSFA.ODS_HSFA_XXX (` 双重库名，
    #   建表直接失败。库名前缀由 generate_ddl_body 统一负责。
    tbl = table.ods_table

    # 验证表名安全性，防止 SQL 注入
    validate_db_identifier(table.ods_table, "ODS table name")

    field_specs = [
        (f.src_name, _safe_hive_type(f.hive_type, f.src_name, "正式表DDL"),
         f.src_name_cn)
        for f in fields
    ]
    # ★ 2026-09-28：追加 ODS 系统字段（LD_TIME）。
    #   必须与 generate_ods_etl 的 INSERT … SELECT 列数一致 ——
    #   ETL 末尾恒定 SELECT 一列 LD_TIME，建表也必须带上它，
    #   否则报 Error 10044「Table insclause-0 has N columns, but query has N+1」。
    field_defs = build_field_defs(field_specs, sys_fields=SYS_FIELDS_ODS)

    return generate_ddl_body(
        schema, tbl, field_defs, table.src_table_cn
    )


def generate_all_ods_ddl(tables: List[TableMeta], fields_by_table: Dict[str, List[FieldMeta]], sys_name: str) -> str:
    """生成所有 ODS 建表 DDL（合并为一个 SQL 文件）

    ★ 2026-10-09（J-03）**：必须按 ods_table 去重**。
      调研文档里同一张表可能被列了两行（实测 HSFA.TACCOUNT_HS），
      `iter_ods_tables` 会原样吐两次 ⇒ 合并文件里出现两个
      `CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD (...)`，
      beeline 顺序执行时第二条直接
        AlreadyExistsException: Table ... ODS_HSFA_TACCOUNT_HS_PFD already exists
      而 `-f` 默认遇错即停 ⇒ **整个系统的后续建表全部没跑**（HSFA 78 张全废）。
      ★ 注意与 `generate_all_ods_ddl_files` 的天然差异：那边是「按文件名写」，
        同名会被覆盖，看起来没事；合并版没有这个保护 ⇒ 两边口径不一致
        （日志 79 张 vs 实际文件 78 张，罪魁就是它）。
    """
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)
    parts = [
        "-- ============================================",
        f"-- ODS 层建表语句 - 系统: {sys_name}",
        f"-- Schema: {schema}",
        "-- ============================================\n",
    ]

    seen = {}
    for table, ods_fields in iter_ods_tables(tables, fields_by_table):
        if table.ods_table in seen:
            logger.warning(
                f"  ⚠ 表 {table.ods_table} 在本次生成中重复出现"
                f"（源表 {seen[table.ods_table]} 与 {table.src_table} 映射到同一张 ODS 表），"
                f"合并 DDL 里只保留第一份。请回上游调研文档订正重复行 / 调整命名。")
            continue
        seen[table.ods_table] = table.src_table
        parts.append(generate_ods_ddl(table, ods_fields, sys_name))
        parts.append("")

    return "\n".join(parts)



def generate_all_ods_ddl_files(tables: List[TableMeta], fields_by_table: Dict[str, List[FieldMeta]], output_dir: str, sys_name: str) -> None:
    """按表生成独立的 DDL SQL 文件

    ★ 2026-10-22（评审 HIGH-9）：加 per-table 兜底 —— 单表校验失败
      （非法表名 / 非法物理源表名）不应中断整批生成。
    """
    ddl_dir = os.path.join(output_dir, "ddl")
    os.makedirs(ddl_dir, exist_ok=True)
    for table, ods_fields in iter_ods_tables(tables, fields_by_table):
        filepath = os.path.join(ddl_dir, table.ods_table + ".sql")
        try:
            ddl_sql = generate_ods_ddl(table, ods_fields, sys_name)
        except ValueError as e:
            logger.error(f"  ERROR: Skipping table '{table.ods_table}': {e}")
            continue
        write_file_safe(filepath, ddl_sql, table.ods_table, "DDL")



# ============================================================================
# ETL 生成函数 (使用模板)
# ============================================================================

def _load_etl_template() -> str:
    r"""读取 ODS ETL shell 脚本模板，失败则抛出明确错误

    ★ 2026-10-22（评审 MEDIUM-6）模板里写 JSON 的方式已修：
      原 `echo $json_obj>${json_path}${tmp_table_name}.json` 有三个问题——
        ① `$json_obj` 未加引号 ⇒ shell 按 IFS 单词拆分（JSON 缩进/换行被压成
           空格），且 JSON 里若含 `*`/`?` 会被当作 glob 展开 ⇒ DataX 配置损坏；
        ② `echo` 在部分 shell（dash）会解释反斜杠转义 ⇒ JSON 里的 `\` 被吃掉；
        ③ 目标路径未加引号 ⇒ 路径含空格时断裂。
      现为 `printf '%s' "$json_obj" > "..."`。
      注：模板**头部注释不得超过 2 行**（有测试约束，见 test_ods.py
      TestEtlTemplateConsistency）—— 模板注释会进每个生成的 .sh，
      故详细说明写在这里而非模板里。
    """
    template_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        'demo', 'templates', 'etl_ods_template.sh'
    )
    try:
        with open(template_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        raise FileNotFoundError(
            f"ETL template file not found: {template_path}. "
            "Please ensure the 'demo/templates' directory exists in the project root."
        )
    except IOError as e:
        raise IOError(f"Failed to read ETL template from {template_path}: {e}")


def _build_tmp_field_defs(fields: list) -> str:
    """构建临时表 _TMP 的字段定义字符串"""
    tmp_field_defs = []
    for f in fields:
        validate_db_identifier(f.src_name, "field name")
        comment = escape_sql_comment(f.src_name_cn)
        tmp_type = _safe_hive_type(f.hive_type, f.src_name, "_TMP DDL")
        tmp_field_defs.append(
            f"  {quote_hive_column_sh(f.src_name)}  {tmp_type}  COMMENT  '{comment}'")
    return ",\n".join(tmp_field_defs)


def _resolve_incr_info(table: TableMeta, fields: list) -> tuple:
    """解析增量条件列及其源库类型，供 querySql/WHERE/P_DT 三处共用"""
    incr_clean = (table.incr_cond or "").replace("\n", " ").replace("\r", " ").strip()
    if incr_clean in ("无", "nan"):
        incr_clean = ""
    incr_col = _extract_incr_col(incr_clean, fields) if incr_clean else ""
    incr_src_type = _incr_col_src_type(incr_col, fields) if incr_col else ""
    if incr_col and not incr_src_type:
        logger.warning(
            f"  ⚠ 表 {table.ods_table} 的增量列 {incr_col} 在字段级调研里查不到类型，"
            f"WHERE 上下界与 P_DT 将退回保守写法（按 DATE 处理）。"
        )
    return incr_clean, incr_col, incr_src_type


def _build_query_sql(fields: list, incr_col: str, incr_src_type: str, physical_src: str,
                     src_schema_var: str, where_pred: str = "") -> str:
    """构建 DataX 的 querySql

    ★ 2026-10-22（评审 HIGH-8 延伸）：`physical_src` 来自甲方调研文档的
      「源表物理名」列，是**外部输入**，此前原样拼进
      `FROM ${schema}.{physical_src}` —— 一个带引号/分号的表名就能污染
      生成的抽数 SQL。目标表名有 validate_db_identifier 兜底，源表名没有。
      ⇒ 补上分段标识符校验。

    ★ 2026-10-26（评审）：**WHERE 子句改为直接拼装**（`where_pred` 参数）。
      旧实现先拼出不带 WHERE 的 SQL，再用 `query_sql.replace(FROM…, FROM…+WHERE…)`
      回填 —— 一旦 FROM 片段的空白/变量名有任何不一致，`replace` **静默不生效**，
      增量表就会退化成全量抽取（数据正确性事故，且无任何报错）。直接拼装消除该风险。
    """
    validate_table_ref(physical_src)
    select_parts = [
        f"SELECT  {_query_col_expr(fields[0].src_name,
                                   incr_src_type if (incr_col and fields[0].src_name.upper() == incr_col.upper()) else '')}"
    ]
    for f in fields[1:]:
        st = incr_src_type if (incr_col and f.src_name.upper() == incr_col.upper()) else ""
        select_parts.append(
            f"                                   , {_query_col_expr(f.src_name, st)}")
    select_str = "\n".join(select_parts)

    tail = f"\n                                FROM ${{{src_schema_var}}}.{physical_src}"
    if where_pred:
        tail += f"\n                                WHERE {where_pred}"
    return select_str + tail


def _build_writer_columns(fields: list) -> list:
    """构建 DataX writer 的 column 列表"""
    writer_columns = []
    for f in fields:
        dx_type = _datax_type(f.src_type, f.src_name_cn)
        writer_columns.append({"name": f.src_name, "type": dx_type})
    return writer_columns


def _build_select_columns(fields: list, table: TableMeta, incr_col: str, incr_src_type: str) -> str:
    """构建 INSERT 语句的 SELECT 字段列表（含 LD_TIME、P_DT）"""
    select_lines = []
    for i, f in enumerate(fields):
        prefix = "       " if i == 0 else "     , "
        select_lines.append(f"{prefix}{quote_hive_column_sh(f.src_name)}")
    select_lines.append("     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME")

    if table.load_strategy != "FULL":
        if incr_col:
            p_dt_expr = _build_p_dt_expr(
                incr_col, incr_src_type, _incr_col_type(incr_col, fields))
            # ★ 2026-10-26（评审）：保持 debug。曾尝试升级为 warning 提醒
            #   「NULL 会落 __HIVE_DEFAULT_PARTITION__」，但**无法定位真风险**：
            #   · 调研文档的「是否允许为空」列实测**整列为空**（HSDS 1212 字段全空），
            #     无法据此只对可空列告警；
            #   · 无差别 warning 会让每张增量表都刷一条，破坏「零误报」底线
            #     （test_existing_column_no_warning / test_dateish_column_no_warning 即为此设）。
            #   ⇒ 保留 debug；如需排查空值，按需在上游侧查 null 率更可靠。
            logger.debug(
                "  表 %s 增量列 %s 依赖上游非空（NULL 将累积进 __HIVE_DEFAULT_PARTITION__）",
                table.ods_table, incr_col)
        else:
            p_dt_expr = "'${p_end_dt}'"
            logger.warning(
                f"  ⚠ 表 {table.ods_table} 无法从增量条件 "
                f"incr_cond='{(table.incr_cond or '').strip()}' 定位到唯一日期列，"
                f"P_DT 退回运行日 '${{p_end_dt}}'。"
                f"若该表应按行日期分区，请回上游把 incr_cond 填成裸列名。"
            )
        select_lines.append(f"     , {p_dt_expr} P_DT")
    return "\n".join(select_lines)


def _build_replacements(
    table: TableMeta,
    sys_name: str,
    schema: str,
    tmp_tbl: str,
    tmp_fields_str: str,
    query_sql: str,
    writer_columns: list,
    dynamic_sets: str,
    partition_clause: str,
    select_columns_str: str,
) -> dict:
    """构建模板占位符替换字典"""
    sys_prefix = sys_name.lower()
    return {
        "${sys_username}": f"${{{sys_prefix}_username}}",
        "${sys_password}": f"${{{sys_prefix}_password}}",
        "${sys_jdbc}": f"${{{sys_prefix}_jdbc}}",
        "${sys_path}": f"${{{sys_prefix}_path}}",
        "${target_schema}": schema,
        "${tmp_table}": tmp_tbl,
        "${tmp_table_name}": tmp_tbl.lower(),
        "${tmp_field_defs}": tmp_fields_str,
        # ★ 2026-10-22（评审 MEDIUM-7 修 bug）：表中文名此前**未转义**就填进
        #   模板的 `COMMENT '${table_cn}'` —— 中文名含单引号（如 O'Hara 基金）
        #   会直接破坏建表 DDL 的语法。
        #   字段注释早已用 escape_sql_comment 转义（见 :470），DDL 侧表注释
        #   也已转义（ddl_common.py:203）—— 这里补齐 ODS ETL 模板这一处。
        "${table_cn}": escape_sql_comment(table.src_table_cn or ""),
        "${query_sql}": _escape_sql_for_json(query_sql),
        "${writer_columns}": json.dumps(writer_columns, ensure_ascii=False),
        "${dynamic_sets}": dynamic_sets,
        "${target_table}": table.ods_table,
        "${partition_clause}": partition_clause,
        "${select_columns}": select_columns_str,
        # ★ 2026-10-26：HDFS 配置参数化（模板里写 ${hdfs_transfer_protection} 等）
        "${hdfs_transfer_protection}": "authentication",
        "${hdfs_use_datanode_hostname}": "true",
    }


def generate_ods_etl(table: TableMeta, fields: list, sys_name: str, template: str) -> str:
    """生成完整的 ODS 抽数 shell 脚本，使用模板"""
    # 公共 API 自我防御：iter_ods_tables 已过滤无字段表，但直接调用此函数时仍需保护
    if not fields:
        logger.warning(f"  表 {table.ods_table} 无字段，跳过 ETL 生成")
        return ""
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)
    # 验证表名安全性
    validate_db_identifier(table.ods_table, "ODS table name")
    tmp_tbl = table.ods_table + "_TMP"

    # 1. 临时表字段定义
    tmp_fields_str = _build_tmp_field_defs(fields)

    # 2. 解析增量信息（供 querySql/WHERE/P_DT 共用）
    incr_clean, incr_col, incr_src_type = _resolve_incr_info(table, fields)

    # 3. WHERE 谓词（增量表）
    # ★ 2026-10-18（评审 #1）：必须按**归一化后**的 incr_clean 判空 ——
    #   「无」/`nan` 原文是真值，旧写法会进分支但 WHERE 左操作数已归一化成空串，
    #   产出 `WHERE  between '${p_start_dt}' and '${p_end_dt}'`（缺左操作数，必炸）。
    where_pred = ""
    if table.load_strategy == "INCR" and incr_clean:
        _validate_incr_columns(incr_clean, fields, table.ods_table)
        where_pred = _build_where_pred(incr_col or incr_clean, incr_src_type)

    # 4. 构建 DataX querySql（WHERE 直接拼装，不再事后 replace）
    src_schema_var = f"{sys_name.lower()}_src_schema"
    physical_src = table.src_table_phys or table.src_table
    query_sql = _build_query_sql(fields, incr_col, incr_src_type, physical_src,
                                 src_schema_var, where_pred)

    # 5. Writer columns
    writer_columns = _build_writer_columns(fields)

    # 6. SELECT 列表（INSERT 用）
    select_columns_str = _build_select_columns(fields, table, incr_col, incr_src_type)

    # 7. 动态 SET 与分区子句
    dynamic_sets = "" if table.load_strategy == "FULL" else "\n".join(HIVE_DYNAMIC_PARTITION_SETTINGS)
    partition_clause = "PARTITION(P_DT='${p_end_dt}')" if table.load_strategy == "FULL" else "PARTITION(P_DT)"

    # 8. 填充模板
    replacements = _build_replacements(
        table, sys_name, schema, tmp_tbl, tmp_fields_str,
        query_sql, writer_columns, dynamic_sets, partition_clause, select_columns_str
    )
    filled = template
    for placeholder, value in replacements.items():
        filled = filled.replace(placeholder, value)

    return filled


def generate_all_ods_etl(tables: List[TableMeta], fields_by_table: Dict[str, List[FieldMeta]], output_dir: str, sys_name: str) -> None:
    """按表生成独立的 ETL shell 脚本

    ★ 2026-10-22（评审 HIGH-9）：加 per-table 兜底（理由同上）。
    """
    etl_dir = os.path.join(output_dir, "etl_sh")
    os.makedirs(etl_dir, exist_ok=True)
    template = _load_etl_template()
    for table, ods_fields in iter_ods_tables(tables, fields_by_table):
        filepath = os.path.join(etl_dir, table.ods_table + ".sh")
        try:
            script = generate_ods_etl(table, ods_fields, sys_name, template)
        except ValueError as e:
            logger.error(f"  ERROR: Skipping table '{table.ods_table}': {e}")
            continue
        write_file_safe(filepath, script, table.ods_table, "ETL")


def _datax_type(src_type: str, field_cn: str = "") -> str:
    """DataX column type: 参照参考脚本统一用 DOUBLE 或 STRING"""
    if not src_type:
        return "STRING"
    t = src_type.upper().strip()
    if any(t.startswith(x) for x in ("NUMBER", "FLOAT", "BINARY_FLOAT", "BINARY_DOUBLE", "INTEGER", "INT")):
        return "DOUBLE"
    return "STRING"
