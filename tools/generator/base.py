import os
import re
from typing import List
from collections import defaultdict
from ..core.ir import MappingSheet
from ..core.sql_tables import (
    is_subquery, extract_tables_from_subquery,
    wrap_subquery, qualify_subquery_tables, qualify_table,
    compat_sql_functions, normalize_inceptor_sql,
)
from ..config import (
    DDL_PARTITIONS, DDL_ROW_FORMAT,
    DDL_FIELD_PREFIX, DDL_FIELD_SEP,
    AS_POS, COMMENT_POS, DEP_TBL_WIDTH,
    HIVE_SETTINGS,
    TIMESTAMP_EXPR,
)
from tools.utils.validation import validate_db_identifier
from tools.utils.logging_setup import get_logger
from tools.utils.table_utils import write_file, write_file_safe, extract_physical_name
from ..generator.ddl_common import (generate_ddl_body, build_field_defs,
                                    quote_hive_column, quote_hive_column_sh,
                                    normalize_hive_type,
                                    HIVE_NUMERIC_PREFIXES, HIVE_STRING_PREFIXES,
                                    ORACLE_CHAR_PREFIXES, ORACLE_DATE_PREFIXES)

# ★★★ 2026-10-13（J-27）：数值型目标列的**空串占位**必须带 CAST。
#   多组 UNION ALL 时，甲方常在某一组把取不到的列填 `NULL` 或 `''`。
#   Hive 里 `''` 是 string ⇒ 与另一组的真实数值列做 UNION 时：
#     SemanticException Schema of both sides of setop should match:
#       Column reinv_share is of type decimal(16,2) on first table
#       and type string on second table.
#   （实测 6 张表：UNP_YIEL/BONUS_DETAIL/BONUS_SCHEME/CHNL_PARA/
#     CUST_HLDP_ALTR_DETAIL/SUE_INFO）
#   ⇒ 只改**空串占位**那一行（绝不碰真实表达式），按目标列类型 CAST 成 NULL。
# ★ 2026-10-14（用户要求）：**裸 `NULL` 是 void 类型**，INSERT/UNION 时
#   Calcite 可按目标列/对侧类型自动推断 ⇒ 一律**不强行 CAST**（甲方脚本
#   UNION 空侧本就全写裸 `NULL`；强行包 CAST 只产生无谓 diff）。
_NUMERIC_HIVE = HIVE_NUMERIC_PREFIXES

logger = get_logger(__name__)

# ★★ 2026-10-05：某组在 MAPPING 里没登记源表时的 FROM 占位符。
#    以前是**静默**输出，只有脚本真跑起来（Table not found）才暴露；
#    现在统一走这个常量 + 追加醒目标记，便于 `grep -rl FROM_PLACEHOLDER` 全仓定位。
FROM_PLACEHOLDER = "FROM source_table --主表"


def _extract_sys_from_table(table_name: str) -> str:
    """从表名提取源系统简称, 如 ODS_XDAY_HSFTA.xxx -> HSFTA"""
    if not table_name:
        return ""
    m = re.search(r'ODS_XDAY_(\w+)', table_name)
    return m.group(1) if m else ""


def _resolve_group_sys(mappings: list, fallback: str) -> str:
    """从该组映射的主表名提取源系统，跨系统多组时各组输出对应的 SSYS

    ★ 2026-10-12：主表行贴的是整段子查询时（`SELECT ... FROM ODS_HSFA_...`），
    从子查询内部第一张 ODS_ 表提取系统名，避免退化成 fallback。
    """
    for mr in mappings:
        if mr.join_type == "MAIN TABLE" and mr.src_table_name:
            src = mr.src_table_name
            if is_subquery(src):
                for tb, _cn in extract_tables_from_subquery(src):
                    extracted = _extract_sys_from_table(tb)
                    if extracted:
                        return extracted
                continue
            extracted = _extract_sys_from_table(src)
            if extracted:
                return extracted
    return fallback


_ALIAS_RE = re.compile(r"^[A-Za-z]{1,4}\d+$")  # T1 / A11 / B2 这类别名前缀


def _alias_sort_key(alias: str):
    """JOIN 排序键：按【源表别名的数字部分】数值升序；无数字的别名排最后（不丢弃）。

    ★ 2026-10-20：为把 `_build_from_join` 的 JOIN 顺序从「MAPPING 行首现序」改为
      「别名序号升序」而加。要点：
        - 取数字部分做 int 比较 ⇒ **数值序而非字典序**（A10 排在 A5 之后；
          若按字符串排序会得到 A1, A10, A5）。
        - 纯字母/空别名返回 `(1, 0)` ⇒ 统一排在带数字的别名之后。**绝不像
          `D:\\桌面\\PycharmProjects\\xday\\dwd\\mapping.py` L321-322 那样把
          `table_index == -1` 的 JOIN 静默丢弃**，那个 bug 会无声少一张源表。
        - 等值键靠 `sorted()` 的稳定性保持原相对顺序（如 A1 与 B1 同号时不乱）。
    """
    d = re.sub(r"\D", "", alias or "")
    return (0, int(d)) if d else (1, 0)


def _normalize_src_tab_value(val: str) -> str:
    """把 MAPPING 的 SRC_TAB（或 SOURCE_TAB）单元格值归一化成合法 SQL 表达式。

    ★★★ 2026-10-14（J-28）：修 19 张表 ParseException 回归。
      Excel 的 SRC_TAB 行有脏数据：值带着【只有收尾】的引号
      （实测 `ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD'`、`ODS_OA_IP_AGENCY_HIERARCHY_PFD'`）。
      旧逻辑：含 `.` 原样透传 ⇒ 裸引号把后面整行吞成一个字符串 ⇒ `'yyyy' '-'` ParseException；
             不含 `.` 再包一层 ⇒ `''` 双引号同样吞行。
      新逻辑：先剥首尾引号拿裸值，再按形态分流——
        - 含 `(`（表达式）⇒ 原样输出；
        - 「别名.列」引用（点前是 T1/A11 这类「字母1-4位+数字」形态，如 `T1.SRC_TAB` 透传 TMP 表）⇒ 原样输出；
        - 其余（裸表名，可带 schema 前缀，可逗号分隔多张）⇒ 统一包一层引号。
    """
    s = (val or "").strip()
    if not s:
        return "''"
    if "(" in s:
        return s
    head = s.split(".", 1)[0].strip("'\"")
    if "." in s and _ALIAS_RE.match(head):
        return s  # 别名.列 引用（如 T1.SRC_TAB），原样透传
    parts = [p.strip().strip("'\"").strip() for p in s.split(",")]
    parts = [p for p in parts if p]
    return "'" + ",".join(parts) + "'"


def _resolve_group_src_tab(mappings: list, fallback_tables: list) -> str:
    """取该组 MAPPING 里显式登记的 SRC_TAB（或 SOURCE_TAB）行的「映射规则」原文。

    ★★★ 2026-10-14（J-26）：用户反馈「SRC_TAB 为啥拼接了这么多，请按 Excel 的来」。
      MAPPING 每个分支通常都有一行 c1=SRC_TAB（映射规则 = `'ODS_XXX_PTD'` 字面量，
      或 `T1.SRC_TAB` 透传 TMP 表）。旧行为**跳过**这些系统字段行，然后拿**整 sheet**
      的「源表英文名」并集拼接 ⇒ 一个分支里混进其他分支和维表
      （实测 UNP_YIEL 每个分支都拼了 5 张：HSFTA 的 TINCOME + 3 张维表）。
      甲方自己的脚本口径也是每分支只写本分支主表名（如 `'ODS_HSZTA_TINCOME_PTD'`）。
      未登记该行的表（如 SCR_CHANGE）回退到旧行为（整表源表清单拼接），不引入新推断。

    ★★★ 2026-10-14（J-28）：取值统一走 `_normalize_src_tab_value` 做引号归一化
      （Excel 脏数据带残留收尾引号，见该函数注释），回退分支同样归一化。
    """
    for mr in mappings:
        if (mr.tgt_name or "").upper() in ("SRC_TAB", "SOURCE_TAB"):
            val = (mr.src_field_alias or "").strip()
            if val:
                return _normalize_src_tab_value(val)
    joined = ",".join(t.strip().strip("'\"").strip() for t in (fallback_tables or []) if t and t.strip())
    return _normalize_src_tab_value(joined)


# ★★ 2026-10-10：允许保留的分区变量（其余一律规范化为 p_end_dt）
ALLOWED_PARAMS = {"p_start_dt", "p_end_dt", "p_start_dt_1", "p_end_dt_1"}

# ★★ 2026-10-10：MAPPING 里散见、需规范化的变量名（无 `$` 裸写形态用）。
#    ★ 特意**不含 `P_DT`** —— 它是分区**列名**（`PARTITION(P_DT = ...)`），
#      裸写时绝不能替换；它只以 `${P_DT}` 形式出现时才算变量（由 _BRACE_LEGACY 处理）。
LEGACY_PARAM_NAMES = ("PI_DATE", "PI_DT", "P_BATCH_DT", "p_batch_dt")

# ★★ `${...}` 形态里额外要处理的：`P_DT`（它只在这种形态下才是变量）
#    + 两种**非法**写法（变量名里带空格，shell 必挂）：`${p_end dt}` / `${p_end_ dt}`
#    + `P_BATCH_DT` 来自 LEGACY_PARAM_NAMES，统一在 normalize_params 里处理
_BRACE_LEGACY = {"P_DT", "p_end dt", "p_end_ dt"} | set(LEGACY_PARAM_NAMES)


def qualify_src_table(tbl: str) -> str:
    """给源表名补库名（2026-10-10 新增）。

    MAPPING 的「源表」行里约 17%（64/370）只写了裸表名（如 `ODS_O32_TSTORMCOMPANY_PFD`），
    生成器原本**原文照抄** ⇒ 出现"同一句 SQL 有的表带库名、有的不带"
    （用户 2026-10-10 在 `DWD_CMM_ALGOR_DEFN_PFD.sh` 里发现，HSFA 占 60 条）。

    当前只是**碰巧**能跑（目标库与源表库同名），跨库引用必挂。

    ⇒ 规则：不含 `.` 时，按 `ODS_<sys>_` 前缀推 `ODS_XDAY_<sys>.`；
      非 `ODS_` 前缀（如 `DWDXDAY` 系）或已带库名的，原样返回。
    ★ 2026-10-12：改委托 `core.sql_tables.qualify_table` —— 裸 `DWD_*` 同样补
      `DWDXDAY.`、裸 `DWS_*` 补 `DWSXDAY.`。修复前普通行（非子查询）里的
      `LEFT JOIN DWD_CMM_STD_DICT_CDVAL_MAP A3`（无 schema）在 beeline 默认库下
      解析失败（实测 `Table not found 'DWD_CMM_STD_DICT_CDVAL_MAP'`）。
    """
    return qualify_table(tbl)


def _render_src_ref(ref: str) -> str:
    """渲染 FROM/JOIN 里的源表引用：普通表名补库名；**子查询**包括号 + 内部表名补库名。

    ★ 2026-10-12 修（13 张 DWD_EVT_* 语法崩的根因）：甲方 MAPPING 的「源表英文名」
    列直接贴了整段子查询（`SELECT ... FROM ODS_HSFA_TZQXX_PFD T1 LEFT JOIN ...
    WHERE T1.P_DT = '...'`）。旧实现把整段文本当表名拼进 `LEFT JOIN SELECT ... FROM ...`
    ⇒ `ParseException: cannot recognize input near 'T1' '.' 'L_ZQNM'`（无括号、无别名作用域）。

    本函数（复用 core.sql_tables）：
      1. 识别子查询 ⇒ `wrap_subquery` 包成 `( ... )` 派生表，别名拼在括号后
         （调用方拼别名：`LEFT JOIN ( ... ) A12 --证券类别信息`）；
      2. `qualify_subquery_tables` 把子查询内部 FROM/JOIN 的裸表名逐个补 schema
         （`ODS_HSFA_TZQXX_PFD` → `ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD`，
         `DWD_CMM_STD_DICT_CDVAL_MAP` → `DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP`）。
    """
    if not ref:
        return ref
    if is_subquery(ref):
        return wrap_subquery(qualify_subquery_tables(ref.strip()))
    return qualify_src_table(ref)


def normalize_params(text: str) -> str:
    """把非标准分区变量统一成 `p_end_dt`（2026-10-10 新增，用户口径）。

    实测 DWD 脚本里散着 7 种写法共 493 处：
        `p_batch_dt`(234) / `PI_DT`(203) / `PI_DATE`(46) / `P_BATCH_DT`(6) / `P_DT`(1)
        + 2 处**非法**（`${p_end dt}` / `${p_end_ dt}`，变量名带空格 ⇒ shell 必挂）
    ⇒ 一律改成 `p_end_dt`；`p_start_dt` / `p_end_dt`（含 `_1` 后缀）保留。

    ★★★ 2026-10-10 修正（**踩坑记录**）：
      第一版写成「**不在白名单里的 `${}` 一律替换**」，结果把脚本环境变量也误伤了：
          beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}
        → beeline -u ${p_end_dt}  -n ${p_end_dt}      -p ${p_end_dt}
      运行时直接 `No known driver to handle "20261009"`（beeline 把日期当 JDBC URL）。
      ⇒ 现改为**白名单式**：**只替换明确列举的旧变量名**，其余 `${...}` 一律原样保留。

    ★★★ 2026-10-10 第二次修正（**又踩一坑**）：
      替换结果必须保留 `${...}` 形态 —— 因为 `${p_end_dt}` 是 **DS 在派发时**
      做字符串替换的（不是 shell 变量），写成 `$p_end_dt` 或裸 `p_end_dt`
      DS **认不出来**，脚本会原样带着 `$p_end_dt` 送进 beeline。实测：
            WHERE T1.P_DT = '$p_end_dt'        ← DS 不替换，shell 也没这个变量
            AND   T2.P_DT = p_end_dt           ← 直接把变量名当列名，必挂
      ⇒ 统一产出 **`'${p_end_dt}'`**（带单引号，因为 P_DT 是 STRING 分区列）：
          ① `'${旧名}'`  → `'${p_end_dt}'`
          ② `${旧名}`    → `${p_end_dt}`      （调用方若已带引号则保持）
          ③ `$旧名`      → `${p_end_dt}`
          ④ 裸 `旧名`    → `'${p_end_dt}'`    （JOIN 条件里 `= PI_DATE` 这种）
    """
    # ★★★ 2026-10-26：单遍正则替换（原 5 遍 → 1 遍，大脚本从 O(n²) 降为 O(n)）。
    # 统一匹配四种形态：${...}  '...'  $...  裸词，回调里按白名单决定是否替换。
    _SINGLE_PASS_RE = re.compile(
        r'\$\{([A-Za-z_][A-Za-z0-9_ ]*)\}'          # ① ${...}  （含带空格的非法名）
        r"|(?<![A-Za-z0-9_$.])'([A-Za-z_][A-Za-z0-9_]*)'"  # ② '...'   （单引号包裹；lookbehind 在引号前）
        r"|\$([A-Za-z_][A-Za-z0-9_]*)"               # ③ $...    （无花括号）
        r"|(?<![A-Za-z0-9_$.'\"])([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_])"  # ④ 裸词（排除引号前）
    )

    def _repl(m):
        # m.group(1)=${...}内容  m.group(2)='...'内容  m.group(3)=$...内容  m.group(4)=裸词
        if m.group(1) is not None:          # ${...}
            name = m.group(1).strip()
            if name in LEGACY_PARAM_NAMES or name in _BRACE_LEGACY:
                return "${p_end_dt}"
            return m.group(0)
        if m.group(2) is not None:          # '...'
            name = m.group(2)
            if name in LEGACY_PARAM_NAMES:
                return "'${p_end_dt}'"
            return m.group(0)
        if m.group(3) is not None:          # $...
            name = m.group(3)
            if name in LEGACY_PARAM_NAMES:
                return "${p_end_dt}"
            return m.group(0)
        if m.group(4) is not None:          # 裸词
            name = m.group(4)
            if name in LEGACY_PARAM_NAMES:
                return "'${p_end_dt}'"
            return m.group(0)
        return m.group(0)

    text = _SINGLE_PASS_RE.sub(_repl, text)

    # ⑤ ★★★ 2026-10-10 新增（用户口径）：**不带表别名的裸 `P_DT` → `'${p_end_dt}'`**
    #    为什么：多表 JOIN 时每张表都有 P_DT 分区列，`WHERE P_DT = '…'` 没写别名
    #    ⇒ Hive 报 `SemanticException Column P_DT Found in more than One Tables/Subqueries`
    #    （实测 DWD_CMM_AREA_INFO_PFD 就是这么挂的）。
    #    ⇒ 把裸 P_DT 换成分区变量值，条件退化为 `'20261009' = '20261009'`（恒真），
    #      不再歧义；带别名的 `T1.P_DT` 不动，`PARTITION(P_DT = …)` 子句也不动。
    return _strip_bare_pdt(text)


# ★★★ 2026-10-13（J-26）：上面的替换**必须跳过派生表内部**。
#   逐行正则会把派生表 SELECT 列表里的真实 `P_DT` 列也换成字面量：
#       甲方 MAPPING 写的是
#         (SELECT PROD_NUM, …, MIN_HOLD_AMT,P_DT, MIN(ST_DATE) AS MIN_DT FROM … A …) T2
#       生成后变成
#         (SELECT PROD_NUM, …, MIN_HOLD_AMT,'${p_end_dt}', MIN(ST_DATE) AS MIN_DT …) T2
#       ⇒ 派生表**没有 P_DT 这一列**了，而 ON 条件里还写着 `T1.P_DT = T2.P_DT`
#       ⇒ `SemanticException [Error 10002]: Invalid column reference 'P_DT'`
#       （实测 DWD_PROD_PROD_TAIL_PFD / DWD_CHNL_CHNL_BASIC_INFO_PFD）。
#   判据同 `tools/check-dwd-insert-align.py`：`(` 后面紧跟 SELECT 的才算派生表
#   （纯函数调用 COALESCE/UNIX_TIMESTAMP 不算，其内部裸 P_DT 该换还得换）。
_RE_PARTITION_CLAUSE = re.compile(r"(?i)\bPARTITION\s*\([^()]*\)")
_RE_MASK = re.compile("\x00(\\d+)\x00")


def _strip_bare_pdt(text: str) -> str:
    """把**顶层**的裸 P_DT 换成 '${p_end_dt}'；派生表/分区子句内部的 P_DT 不动。"""
    kept = []

    def _mask(m):
        kept.append(m.group(0))
        return "\x00%d\x00" % (len(kept) - 1)

    masked = _RE_PARTITION_CLAUSE.sub(_mask, text)

    out = []
    stack = []          # 每个 `(` 记一个标记：其后紧跟 SELECT 才是派生表
    i, n = 0, len(masked)
    while i < n:
        ch = masked[i]
        if ch == "(":
            j = i + 1
            while j < n and masked[j] in " \t\r\n":
                j += 1
            stack.append(masked[j:j + 6].upper() == "SELECT")
            out.append(ch)
            i += 1
            continue
        if ch == ")":
            if stack:
                stack.pop()
            out.append(ch)
            i += 1
            continue
        if (not any(stack)) and masked.startswith("P_DT", i) \
                and (i == 0 or not (masked[i - 1].isalnum() or masked[i - 1] in "_.")) \
                and not (i + 4 < n and (masked[i + 4].isalnum() or masked[i + 4] == "_")):
            out.append("'${p_end_dt}'")
            i += 4
            continue
        out.append(ch)
        i += 1

    return _RE_MASK.sub(lambda m: kept[int(m.group(1))], "".join(out))



def _one_line(s: str) -> str:
    """把可能含换行的文本压成单行，防止注入到 `--` 行注释时把注释“撑断”。

    ★★ 2026-10-05 修复：列注释 / 表注释 / 描述若含 `\\n`，续行会**丢掉 `--` 前缀**，
       于是续行被 Hive 当成 SQL 解析 ⇒ 整条语句从该处开始报
       `ParseException ... cannot recognize input near '2' 'TA' 'TA'`
       （典型：描述字段里手工换行的「1、…\\n2、…」）。
    """
    return (s or "").replace("\r\n", "\n").replace("\r", "\n").replace("\n", " ").strip()


class BaseGenerator:
    def __init__(self, schema, sys_fields, has_src_fields):
        self.schema = schema
        self.sys_fields = sys_fields
        self.has_src_fields = has_src_fields

    def generate_ddl(self, sheet: MappingSheet) -> str:
        """从 MappingSheet 生成建表 DDL"""
        tbl = extract_physical_name(sheet.tgt_table)

        # 验证表名安全性，防止 SQL 注入
        validate_db_identifier(tbl, "table name")

        # 去重字段（按 tgt_name，保留首次出现），构建字段三元组
        #
        # ★★★ 2026-10-13（J-24）：**必须和 `_build_select_lines` 用同一个排序**。
        #   那边是 `sorted(mappings, key=lambda m: m.tgt_ordinal)`（按「序号」列），
        #   这里原来直接按 sheet 行序 ⇒ 只要 MAPPING 的序号列与行序不一致
        #   （实测 O32 `DWD_TRAN_ROUG_REPO_PTD`：PORTF_SERIALNO 在 sheet 里排第 6，
        #    序号却排在 SCR_NUM 之后），DDL 与 SELECT 就**列序错位**。
        #   Hive 的 INSERT 按位置匹配 ⇒ 项数相同也照样**静默写错列**（比 10044 更危险）。
        #   Python 的 sort 是稳定的 ⇒ 同序号时仍保持 sheet 行序，与 SELECT 完全一致。
        #
        # ★★★ 2026-10-13（J-25）：系统字段（SSYS/SRC_TAB/LD_TIME/MODIFY_TIME）
        #   **不能**按 MAPPING 里的序号就地摆放。
        #   `_build_select_lines` 对这类行的处理是：先 `continue` 跳过，再在**末尾统一追加**
        #   （顺序 = `SYS_FIELDS_DWD`）。而 DDL 原来把 MAPPING 里那一行按序号插在中间
        #   ⇒ 两边列数相同但**顺序不同** ⇒ Hive 按位置匹配 ⇒ 静默写错列。
        #   实测 `DWD_AST_VOU_INFO_PTD`（MAPPING 里 MODIFY_TIME 排第 37）与
        #        `DWD_CMM_CHNL_PARSE_RULE_PFD`（MAPPING 里 SSYS 排第 16）。
        #   修法：这里同样跳过，交给 `build_field_defs` 按 `SYS_FIELDS_*` 顺序追加到末尾，
        #   与 SELECT 完全同构。
        sys_field_names = {sf[0] for sf in self.sys_fields}
        seen = set()
        field_specs = []
        for mr in sorted(sheet.mappings, key=lambda m: m.tgt_ordinal):
            if not mr.tgt_name or mr.tgt_name in seen:
                continue
            if mr.tgt_name in sys_field_names:
                continue
            seen.add(mr.tgt_name)
            ftype = mr.tgt_type if mr.tgt_type else "STRING"
            field_specs.append((mr.tgt_name, ftype, mr.tgt_name_cn))

        # 统一字段定义构建（含系统字段追加与去重）
        field_defs = build_field_defs(field_specs, sys_fields=self.sys_fields)

        return generate_ddl_body(
            self.schema, tbl, field_defs, sheet.tgt_table_cn,
            field_prefix=DDL_FIELD_PREFIX,
            field_sep=DDL_FIELD_SEP,
            partitions=DDL_PARTITIONS,
            row_format=DDL_ROW_FORMAT,
        )

    def generate_all_ddl(self, sheets: list) -> str:
        """生成所有建表 DDL（合并为一个 SQL 文件）"""
        parts = [
            f"-- {self.schema} 层建表语句",
            f"-- Schema: {self.schema}\n",
        ]
        for sheet in sheets:
            if not sheet.tgt_table:
                continue
            try:
                parts.append(f"-- {sheet.tgt_table_cn}")
                parts.append(self.generate_ddl(sheet))
                parts.append("")
            except ValueError as e:
                # 验证失败或其他错误，记录并跳过此表
                logger.error(f"  ERROR: Skipping table '{sheet.tgt_table}': {e}")
                continue
        return "\n".join(parts)

    def generate_all_ddl_files(self, sheets: List[MappingSheet], output_dir: str, sys_name: str = "O32") -> None:
        """按表生成独立的 DDL SQL 文件

        ★ 2026-10-22（评审 HIGH-9）：加 per-table 兜底。
          原实现无 try/except ⇒ 一张表校验失败（非法表名 / 非法 param）会抛
          ValueError **中断整批** DDL 文件生成，前面已生成的留在磁盘上、
          后面的一律不生成 ⇒ 产出「半截」结果集。
          本文件内的 generate_all_ddl 已有同类兜底（见上），此处补齐一致。
        """
        ddl_dir = os.path.join(output_dir, "ddl")
        os.makedirs(ddl_dir, exist_ok=True)
        for sheet in sheets:
            if not sheet.tgt_table or not sheet.mappings:
                continue
            tbl = extract_physical_name(sheet.tgt_table)
            filepath = os.path.join(ddl_dir, tbl + ".sql")
            try:
                ddl_sql = self.generate_ddl(sheet)
            except ValueError as e:
                logger.error(f"  ERROR: Skipping table '{sheet.tgt_table}': {e}")
                continue
            write_file_safe(filepath, ddl_sql, sheet.tgt_table, "DDL")

    def _collect_aliases(self, mappings: list) -> dict:
        """收集所有表的别名信息"""
        aliases = {}
        for mr in mappings:
            alias = mr.src_table_alias
            if not alias:
                continue
            if alias not in aliases:
                aliases[alias] = {
                    "join_type": "",
                    "join_cond": "",
                    "filter_cond": [],
                    "src_table": mr.src_table_name or alias,
                    "src_table_cn": mr.src_table_cn or "",
                }
            info = aliases[alias]
            # 更新非空值（首次设置的优先保留，但 src_table 优先用非别名值）
            if mr.src_table_name and info["src_table"] == alias:
                info["src_table"] = mr.src_table_name
            info["src_table_cn"] = info["src_table_cn"] or mr.src_table_cn
            info["join_type"] = info["join_type"] or mr.join_type
            if mr.join_cond:
                cond = mr.join_cond.strip()
                info["join_cond"] = info["join_cond"] or (cond[3:] if cond.startswith("ON ") else cond)
            if mr.filter_cond and mr.filter_cond not in info["filter_cond"]:
                info["filter_cond"].append(mr.filter_cond)
        return aliases

    # ★★ 2026-10-05 修复：同一分组内「别名冲突」导致第二个源表被静默丢弃。
    #
    # 背景：MAPPING 的「组别」列经常被误填 —— 最典型的是把 SSYS/SRC_TAB/LD_TIME/MODIFY_TIME
    # 这类【系统字段行】标成第 2 组，而真正的两组业务数据都留在第 1 组。后果有两个：
    #   ① 系统字段单独成组 ⇒ 该组没有任何源表别名 ⇒ _build_from_join 吐出
    #      `FROM source_table --主表` 占位符 ⇒ 脚本一跑就 Table not found；
    #   ② 两组业务数据挤在同一组 ⇒ _collect_aliases 对同一别名 A1 只保留【首次出现】的
    #      源表 ⇒ 第二个源表（实测 ODS_O32_TSTOCKRIVALTRADER_PFD）被静默丢掉，数据少一半。
    #
    # 修法：仅当组内确实存在「同一别名指向不同源表」的冲突时，按【目标字段序号回退】
    # 做二次切分（序号重新从 1 开始 = 新的一组）。
    # ★★★ 并且带安全闸：切分后只要有任一组缺 MAIN TABLE 或拿不到任何别名，就整体放弃
    # 切分、维持原样 —— 避免把本来能跑的大表改坏。实测 DWD_PROD_PROD_BASIC_INFO_PFD
    # 切完会冒出「只有 CDVAL_MAP、没有 MAIN TABLE」的碎片组，正是该安全闸要挡下的。

    @staticmethod
    def _has_alias_conflict(rows: list) -> bool:
        """组内是否存在「同一别名指向不同源表」"""
        seen = {}
        for mr in rows:
            a, t = mr.src_table_alias, mr.src_table_name
            if not a or not t:
                continue
            if a in seen and seen[a] != t:
                return True
            seen[a] = t
        return False

    @staticmethod
    def _split_by_ordinal(rows: list) -> list:
        """按目标字段序号回退切分（序号 <= 前一行 ⇒ 开新组）"""
        out, cur, prev = [], [], None
        for mr in rows:
            o = mr.tgt_ordinal
            if prev is not None and o is not None and o <= prev:
                if cur:
                    out.append(cur)
                cur = []
            cur.append(mr)
            if o is not None:
                prev = o
        if cur:
            out.append(cur)
        return out

    def _subgroups(self, rows: list) -> list:
        """必要时把一组拆成多组；拆坏了就退回原样（安全闸）"""
        if not self._has_alias_conflict(rows):
            return [rows]
        subs = self._split_by_ordinal(rows)
        if len(subs) <= 1:
            return [rows]
        for sub in subs:
            aliases = self._collect_aliases(sub)
            if not aliases:
                return [rows]          # 有组拿不到任何源表 ⇒ 不拆
            if not any(i.get("join_type") == "MAIN TABLE" for i in aliases.values()):
                return [rows]          # 有组没有 MAIN TABLE ⇒ 不拆
        return subs

    # ★★ 2026-10-13（J-23）：SELECT/关联条件引用了【未登记】的源表别名。
    #
    # 现象：脚本跑起来报
    #   SemanticException [Error 10004]: Invalid table alias or column reference 'A10'
    # 根因：`_collect_aliases` 只认「源表别名」列；而 MAPPING 里这些别名的
    #   「源表英文名 / 源表别名」列是**空的**（或串进了注释/SQL 片段，实测
    #   DWD_AST_VALU_INFO_PTD 的 A3、DWD_AST_BAL_INFO_PTM 的 A1 的源表列竟是
    #   `SELECT B1.L_ID AS L_FUNDID --账套编号 ,B` / `--按月获取…SELECT T1.L_`），
    #   ⇒ 该别名进不了 aliases ⇒ `_build_from_join` 不为它生成 FROM/JOIN，
    #   但 `_build_select_lines` 仍按「映射规则」输出 `A10.SFAC_NUM` ⇒ 必然 10004。
    #
    # 修法（J-23d 定稿）：生成前对**拼装后的 SQL 正文**做「引用 vs 定义」交叉核对，
    #   不一致就 logger.error 报警（与 FROM_PLACEHOLDER 同套路），**不静默产出坏脚本**。
    #   登记信息本身要回上游 Excel 补，生成器无从推断。
    #
    # ★★ 为什么必须校验【最终文本】而不是 MAPPING 各列（两版失败的教训）：
    #   · 只扫「映射规则」列 ⇒ 漏掉只在 ON 条件里引用的别名
    #     （实测 DWD_SCR_DIM_SCR_INFO_PTD 的 T3，脚本照样报 10004）；
    #   · 扫「关联条件」列 ⇒ 把【所在行别名为空、整条 ON 被 `_build_from_join`
    #     静默丢弃】的也算进来（实测 DWD_ACCT_ACCT_CNFM_PFD 的 T2、
    #     DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD 的 T11 —— 脚本里根本不留痕迹，
    #     那是"丢 JOIN 丢数据"，不是 10004）。两类问题严重度与修法不同，不混报。
    #   判据只有一条：**正文里出现 `<别名>.` 引用，却没有任何地方定义该别名**。
    _RE_ALIAS_REF = re.compile(r"\b([A-Z]{1,3}\d{1,2})\.")

    # 别名定义形式一：`FROM|JOIN <表引用> [AS] <别名>`（**含子查询内部的 FROM/JOIN**）
    _RE_ALIAS_DEF_TBL = re.compile(
        r"(?:\bFROM|\bJOIN)\s+[A-Za-z0-9_.$\{\}\"]+\s+(?:AS\s+)?([A-Za-z][A-Za-z0-9_]*)\b",
        re.I)
    # 别名定义形式二：`) [AS] <别名>`（派生表 / 子查询的别名）
    _RE_ALIAS_DEF_SUBQ = re.compile(r"\)\s*(?:AS\s+)?([A-Za-z][A-Za-z0-9_]*)\b")
    _RE_LINE_COMMENT = re.compile(r"--[^\n]*")

    @classmethod
    def _undefined_aliases_in_sql(cls, sql: str) -> list:
        """在【一段拼装好的 SQL】里找出「被 `<别名>.` 引用但没有任何定义」的别名字号。

        ★ 只认 `A1.`/`A10.`/`T15.`/`B1.` 这种「字母+数字」形态 ⇒
          `DWDXDAY.` / `ODS_XDAY_HSFA.` / `P_DT.` 天然排除（schema 名与列名）。
        ★ 两种定义形式都认，故子查询**内部**自定义的别名
          （`LEFT JOIN (SELECT … FROM X T1 …) A12` 里的 T1）不会被误报
          —— 顶层并不需要 MAPPING 登记它们（J-23c 的 DWD_EVT_SCR_CHANGE_BUSIN_PTD T1）。
        ★ 注释先剥离：MAPPING 的中文注释里常出现 `A1.xxx` 之类的说明文字，不算引用。
        """
        if not sql:
            return []
        text = cls._RE_LINE_COMMENT.sub(" ", sql)
        defined = set()
        for m in cls._RE_ALIAS_DEF_TBL.finditer(text):
            defined.add(m.group(1).upper())
        for m in cls._RE_ALIAS_DEF_SUBQ.finditer(text):
            defined.add(m.group(1).upper())
        refs = {a.upper() for a in cls._RE_ALIAS_REF.findall(text)}
        return sorted(refs - defined)

    @classmethod
    def _bad_subqueries(cls, mappings: list) -> list:
        """源表列贴了【不完整】子查询的 (别名, 原因) 列表。

        ★ J-23b：实测 MAPPING 的「源表英文名」列被写进注释 + 半截 SQL
          （DWD_AST_BAL_INFO_PTM 的 A1 = `--按月获取…\\nSELECT T1.L_…`，括号不平衡），
          生成器把它原样塞进 FROM ⇒ 末尾多出孤立的 `)` 和空别名 ⇒ ParseException。
        """
        bad = []
        for mr in mappings:
            t = (mr.src_table_name or "").strip()
            if not t or not is_subquery(t):
                continue
            core = t
            if core.count("(") != core.count(")"):
                bad.append((mr.src_table_alias or "(空)",
                            "括号不平衡：%d 个 ( vs %d 个 )"
                            % (core.count("("), core.count(")"))))
        return bad

    def _build_from_join(self, aliases: dict) -> str:
        """构建 FROM/JOIN 子句

        ★ 2026-10-20：JOIN 顺序改为【按源表别名序号数值升序】。
          旧口径按 MAPPING 行首现顺序（`aliases` 的 dict 插入序），当 MAPPING 的
          「源表别名」列不按数字登记时，产出也别号乱序——实测
          `DWD_PTY_CNTP_INFO_PFD` 生成出 `A1,A2,A3,A4,A8,A5,A6,A7`（A8 夹在 A4/A5 间）。
          新口径：`other_aliases` 按 `_alias_sort_key`（别号数字 int 比较）升序 ⇒ A1..A8。
          与 `D:\\桌面\\PycharmProjects\\xday\\dwd\\mapping.py` L326 的口径一致，但
          不引入它那两个坑（无数字别名丢弃、同别号后写覆盖前写）。

          未改动的部分：`FROM` 仍取 `join_type == "MAIN TABLE"` 的行（多个 MAIN TABLE
          会连缀多个 FROM，属既存问题、不在本次范围）。
        """
        main_aliases = [a for a, info in aliases.items() if info["join_type"] == "MAIN TABLE"]
        other_aliases = [a for a, info in aliases.items() if info["join_type"] != "MAIN TABLE"]
        other_aliases = sorted(other_aliases, key=_alias_sort_key)

        if not aliases:
            # ★★ 2026-10-05：不要【静默】吐 source_table —— 加上醒目标记，
            #    让人和 grep 都能一眼看出这个脚本不可执行。
            return (FROM_PLACEHOLDER
                    + "  ★★TODO 该组在 MAPPING 中未登记「源表英文名/源表别名」，"
                      "脚本不可执行，请补 Excel 后重跑生成器")

        # ★ J-15（2026-10-13）：映射漏填 MAIN TABLE（「JOIN方式」列空）时，把首个别名
        #   提升为主表，保证 FROM 存在。此前无 MAIN TABLE ⇒ 所有别名都走 JOIN ⇒
        #   `SELECT <A1列> LEFT JOIN (子查询) A1 ON 1=1` **缺 FROM** ⇒
        #   ParseException「missing EOF at LEFT」（余额信息/估值信息实测）。
        #   已正确填 MAIN TABLE 的组不受影响（main_aliases 非空，此兜底不触发）。
        if not main_aliases and other_aliases:
            main_aliases = [other_aliases[0]]
            other_aliases = other_aliases[1:]

        lines = []
        for alias in main_aliases:
            info = aliases[alias]
            cn = " --" + info["src_table_cn"] if info["src_table_cn"] else ""
            lines.append("  FROM " + _render_src_ref(info["src_table"]) + " " + alias + cn)

        for alias in other_aliases:
            info = aliases[alias]
            cond = info["join_cond"] or "1=1"
            jt = info["join_type"] or "LEFT JOIN"
            cn = " --" + info["src_table_cn"] if info["src_table_cn"] else ""
            lines.append("  " + jt + " " + _render_src_ref(info["src_table"]) + " " + alias + cn)
            # 解析 ON 条件: 第一个条件跟在 ON 后面, 后续 AND 换行缩进3空格
            self._append_on_conditions(lines, cond)

        return "\n".join(lines)

    @staticmethod
    def _split_on_and(cond: str) -> list:
        """按**顶层** AND 切分连接条件，跳过字符串字面量内的 AND。

        ★ 2026-10-22（评审 MEDIUM-3 修 bug）：原实现用
          `re.split(r'\\s+AND\\s+', cond, flags=re.IGNORECASE)` —— 无差别切分，
          于是条件**值**里出现的 AND 也会被切开：
            `T1.STATUS = 'STANDARD' AND T1.FLAG = 'Y'`
          → 切成 `['T1.STATUS = \'STANDARD\'', 'T1.FLAG = \'Y\'']` 看似没事，
          但 `T1.CODE = 'A AND B'` 会被切成两段 ⇒ 生成残缺的 ON 子句
          ⇒ Hive ParseException。

          ⇒ 改为逐字符扫描，遇到单引号字面量就整段跳过，只在字面量**之外**
          的顶层 AND 处切分。SQL 字符串字面量用单引号，内部的单引号以
          两个连续单引号（''）转义 —— 本扫描器一并正确处理。
        """
        parts = []
        buf = []
        i = 0
        n = len(cond)
        in_string = False
        while i < n:
            ch = cond[i]
            if in_string:
                buf.append(ch)
                if ch == "'":
                    # '' 是转义的单引号，不结束字面量
                    if i + 1 < n and cond[i + 1] == "'":
                        buf.append("'")
                        i += 2
                        continue
                    in_string = False
                i += 1
                continue
            if ch == "'":
                in_string = True
                buf.append(ch)
                i += 1
                continue
            # 字面量之外：检查是否是顶层 AND
            # 判定用**词边界**而非「两侧都有空格」：
            #   · `T1.A=1 AND`      尾部 AND（右侧无内容）也要切
            #   · `AND T1.A=1`      首部 AND（左侧无内容）也要切
            #   · `T1.A='X'AND B`   引号紧邻（左侧是字面量结束）也要切
            # 前后边界 = 紧邻字符不是字母/数字/下划线（即非标识符字符）。
            prev_ch = cond[i - 1] if i > 0 else " "
            next_ch = cond[i + 3] if i + 3 < n else " "
            if (ch in ("A", "a") and cond[i:i + 3].upper() == "AND"
                    and not (prev_ch.isalnum() or prev_ch == "_")
                    and not (next_ch.isalnum() or next_ch == "_")):
                parts.append("".join(buf))
                buf = []
                i += 3
                continue
            buf.append(ch)
            i += 1
        parts.append("".join(buf))
        # 去掉孤立的首/尾 AND（`AND T1.A=1` / `T1.A=1 AND`）——
        # 它们不是连接符，是 MAPPING 里的书写残留，留着会生成 `ON AND x`。
        cleaned = []
        for idx, p in enumerate(parts):
            p = p.strip()
            if not p:
                continue
            if p.upper() == "AND":
                continue
            cleaned.append(p)
        return cleaned

    def _append_on_conditions(self, lines, cond):
        """解析 ON 条件：ON 前面4空格，AND 前面3空格，让条件部分右对齐"""
        # 清理 cond：去掉 ON 前缀，统一 AND 格式
        # ★ 2026-10-12（J-07）：ON 条件里同样兼容 IFNULL/ISNULL → NVL
        cond = compat_sql_functions(cond.strip())
        if cond.upper().startswith('ON '):
            cond = cond[3:].strip()

        # ★ 2026-10-22：改用跳过字面量的顶层 AND 切分（见 _split_on_and）
        parts = self._split_on_and(cond)

        if not parts:
            lines.append("    ON 1=1")
            return

        # 处理第一个条件（可能带注释）
        first = parts[0].strip()
        lines.append("    ON " + first)

        # 处理后续条件
        for part in parts[1:]:
            part = part.strip()
            if part:
                lines.append("   AND " + part)

    def _build_where(self, aliases: dict) -> list:
        """构建 WHERE 子句。

        filter_cond 在解析层(_extract_filter)已剥离 WHERE/AND 前缀，此处直接去空白拼接。
        """
        conds = []
        for alias, info in aliases.items():
            for fc in info.get("filter_cond", []):
                if fc and fc not in conds:
                    conds.append(fc.strip())
        return conds

    def _resolve_expr(self, raw: str) -> str:
        if not raw:
            return "''"
        raw = str(raw).strip()
        if raw in ('nan', 'NaN'):
            return "''"
        return compat_sql_functions(raw)

    def _format_case_expr(self, expr, tgt_name, comment, prefix):
        """
        格式化 CASE 表达式为参考脚本格式：
         , CASE WHEN T1.C_CUSTTYPE IS NOT NULL
                THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE))
            END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
        """

        # 按换行分割 CASE 表达式
        if "\n" in expr:
            lines = [line.rstrip() for line in expr.split("\n") if line.strip()]
        else:
            case_clean = expr.strip()
            if case_clean.upper().startswith("CASE") and "END" in case_clean.upper():
                # 在 THEN 和 END 前插入换行
                formatted = re.sub(r"(THEN\s+)", r"\n\1", case_clean, flags=re.IGNORECASE)
                formatted = re.sub(r"(\s+END)", r"\n\1", formatted, flags=re.IGNORECASE)
                lines = [line.strip() for line in formatted.split("\n") if line.strip()]
            else:
                lines = [case_clean]

        if not lines:
            return []

        result = []
        comment = comment or ""

        if len(lines) == 1:
            # 单行 CASE：整个 CASE...END 作为一行
            # ★ 2026-10-22：别名加反引号（与多行分支 :739 及 _fmt_select_line :756
            #   保持一致）——目标字段若是 Hive 保留字（如 DATE/TIME/USER），
            #   未加引号会生成 `AS DATE` ⇒ Hive ParseException:
            #   "cannot recognize input near 'AS' 'DATE'"。
            line_with_alias = (prefix + lines[0]).ljust(AS_POS) + " AS " + quote_hive_column_sh(tgt_name)
            result.append(line_with_alias.ljust(COMMENT_POS) + "--" + _one_line(comment))
        else:
            # 多行 CASE
            # 第一行（CASE...WHEN...THEN...）：没有 AS 和注释
            result.append(prefix + lines[0])

            # 中间行（THEN 部分等，缩进 12 空格）
            for line in lines[1:-1]:
                if line:
                    result.append("            " + line)

            # 最后一行：END（缩进 8 空格）后跟 AS alias 和注释
            # ★ J-16（2026-10-13）：映射规则的 END 常写成「 \n END」（END 前有空格），
            #   原 `lines[-1].upper().startswith("END")` 因前导空格判 False ⇒ 整块
            #   END + AS 别名被静默丢弃 ⇒ `missing KW_END`（AGMT_RATION 等 5 表实测）。
            #   改为 strip 后判定；末行即便非 END（映射真缺 END）也拼出、保别名可见。
            last = lines[-1].strip()
            end_line = "        " + last  # 8 空格 + END（或末行内容）
            # ★ 同 _fmt_select_line：END 分支的别名也要过保留字白名单
            end_line_with_alias = end_line.ljust(AS_POS) + " AS " + quote_hive_column_sh(tgt_name)
            result.append(end_line_with_alias.ljust(COMMENT_POS) + "--" + _one_line(comment))

        return result

    def _fmt_select_line(self, prefix, expr, tgt_name, comment) -> str:
        """格式化单行 SELECT 字段：prefix + expr AS tgt_name  --comment

        ★★★ 2026-10-10 修：**目标别名也要过 `quote_hive_column`**。
        原来只给**源列名**加引号（`T1.L_DATE`），**别名**是裸拼的 ⇒
        目标字段叫 Hive 保留字时直接炸：
            T1.L_DATE    AS DATE      --日期
        ⇒ Hive 报 `ParseException line 3:88 cannot recognize input near 'AS' 'DATE' ','`
        （实测 DWD_CMM_INTR_PARA_PFD，2026-10-10 18:53）。
        保留字清单在 `ddl_common.HIVE_RESERVED_WORDS`，`DATE` 本来就在里面，
        只是这条路径没调用。
        """
        line_with_alias = (prefix + expr).ljust(AS_POS) + " AS " + quote_hive_column_sh(tgt_name)
        return line_with_alias.ljust(COMMENT_POS) + "--" + _one_line(comment)

    def _build_select_lines(self, mappings, source_tables, sys_field_names, sys_name,
                            add_src_fields=True, in_union=False):
        """
        构建 SELECT 子句，严格参照参考脚本格式：
           T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
         , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码

        in_union=True 时启用 J-29 的 UNION 类型对齐（见 _unify_union_type）。
        """
        sorted_mrs = sorted(mappings, key=lambda m: m.tgt_ordinal)
        seen = set()
        select_lines = []
        first_field = True
        for mr in sorted_mrs:
            if mr.tgt_name in seen:
                continue
            if mr.tgt_name in sys_field_names:
                continue
            seen.add(mr.tgt_name)
            prefix = "       " if first_field else "     , "
            first_field = False
            expr = self._resolve_expr(mr.src_field_alias)
            # ★ J-19（2026-10-13）：部分映射规则**自带末尾 `AS 目标别名`**
            #   （甲方不一致，如 O32 待交割 r48 `... END  AS CPTL_DELIV_STAT_CODE`），
            #   下游各分支又统一追加 `AS {tgt_name}` ⇒ `END AS X AS X` 双 AS
            #   ⇒ `cannot recognize input near 'AS' ... 'AS'`（实测 PREP_DELI）。
            #   在分支前统一剥掉末尾冗余别名，再由生成器追加**规范**别名。
            #   对不带别名的规则（绝大多数）无影响（正则不命中即 no-op）。
            expr = re.sub(r'\s+AS\s+[A-Za-z_]\w*\s*$', '', expr.strip(),
                          flags=re.IGNORECASE)
            # ★ J-27：数值列的空串占位 `''` → `CAST(NULL AS <目标类型>)`（裸 NULL 不 cast）
            # ★ J-29：UNION 多组时走统一类型对齐（空串 CAST + 裸字段跨大类 CAST）
            if in_union:
                expr = self._unify_union_type(expr, mr)
            else:
                expr = self._cast_placeholder(expr, mr)
            comment = mr.tgt_name_cn if mr.tgt_name_cn else ""
            if expr.upper().startswith('CASE '):
                select_lines.extend(self._format_case_expr(expr, mr.tgt_name, comment, prefix))
            elif '\n' in expr:
                # ★ J-18（2026-10-13）：多行表达式原把 AS 别名挂在**第一行**末尾
                #   ⇒ 别名插进表达式中间（`UNIX_TIMESTAMP(   AS END_DATE` 换行接
                #   `LEAD(...) OVER(...)`）⇒ `cannot recognize input near 'AS'
                #   'END_DATE' 'LEAD'`（实测 SALE_FEER/TAIL）。改为别名挂**最后一个
                #   非空行**：首行带前缀不带别名，中间行缩进续接，末行缩进+别名+注释。
                parts = [ln.rstrip() for ln in expr.split('\n') if ln.strip()]
                if not parts:
                    select_lines.append(
                        self._fmt_select_line(prefix, expr.strip(), mr.tgt_name, comment))
                else:
                    for i, ln in enumerate(parts):
                        if i == len(parts) - 1:  # 末行：缩进 + AS 别名 + 注释
                            select_lines.append(
                                self._fmt_select_line("            ", ln, mr.tgt_name, comment))
                        elif i == 0:            # 首行：带前缀(含逗号)，不带别名
                            select_lines.append(prefix + ln)
                        else:                    # 中间行：缩进续接
                            select_lines.append("            " + ln)
            else:
                select_lines.append(self._fmt_select_line(prefix, expr, mr.tgt_name, comment))

        # 追加系统字段
        if add_src_fields:
            if "SSYS" not in seen:
                group_sys = _resolve_group_sys(mappings, sys_name)
                select_lines.append(self._fmt_sys_field("SSYS", f"'{group_sys}'", "源系统"))
            if "SRC_TAB" not in seen and "SOURCE_TAB" not in seen:
                # ★★★ 2026-10-14（J-26）：优先用 MAPPING 登记的 SRC_TAB 行（按分支），
                #   只有 Excel 未登记时才回退到整表源表清单拼接。详见 _resolve_group_src_tab。
                select_lines.append(
                    self._fmt_sys_field("SRC_TAB", _resolve_group_src_tab(mappings, source_tables), "源表"))
        if "LD_TIME" not in seen:
            select_lines.append(self._fmt_sys_field("LD_TIME", TIMESTAMP_EXPR, "加载时间"))
        if "MODIFY_TIME" not in seen:
            select_lines.append(self._fmt_sys_field("MODIFY_TIME", TIMESTAMP_EXPR, "修改时间"))
        return select_lines

    @classmethod
    def _cast_placeholder(cls, expr: str, mr) -> str:
        """把数值列的空串占位字面量换成带 CAST 的 NULL（J-27，见模块头注释）。

        只认一种占位：`''`（去掉空白后完全相等才算）；裸 `NULL` 是 void 类型、
        可按目标列推断 ⇒ **原样保留不 CAST**（2026-10-14 用户要求）。
        **绝不改写任何真实表达式**（改真实取数 = 改数据，风险不可控）。
        """
        s = expr.strip()
        if s.upper() == "NULL":
            return expr
        if s not in ("''", '""'):
            return expr
        ftype = normalize_hive_type(mr.tgt_type, mr.tgt_name_cn).upper()
        if not ftype.startswith(_NUMERIC_HIVE):
            return expr
        # ★ 2026-10-14（用户要求订正）：空串占位统一输出**裸 `NULL`**
        #   （void 类型可被目标列自动推断；旧规则 CAST(NULL AS 目标类型)
        #   属强行转换，只产生无谓 diff）。
        return "NULL"

    # ★★★ 2026-10-14（J-29）：多组 UNION ALL 时，同名列在各组必须**同类型**。
    #   setop 报错只由两种形态触发（2026-10-14 深夜实测订正）：
    #     a) 对侧是裸 `别名.字段`（如 T1.L_LIQUIDATEALLOT，decimal），本侧
    #        STRING 占位 `''` ⇒ `string on first table and decimal on second`；
    #     b) 两侧都是裸字段但跨大类（double vs string，如 TAIL cust_type_code）。
    #   **裸 `NULL` 是 void 类型，可与对侧任意类型适配 ⇒ 占位一律输出裸 NULL、
    #   不强行 CAST**（2026-10-14 用户要求；甲方脚本 UNION 空侧本就全写裸
    #   `NULL`。旧规则"占位一律 CAST(NULL AS 目标类型)"只产生无谓 diff）。
    #   ⇒ 规则：① 占位（`NULL`/`''`）→ 裸 `NULL`；
    #      ② 裸「别名.字段」直引且 MAPPING 登记的源字段类型与目标**大类不同**
    #        （numeric ↔ string/date）时，包一层 `CAST(... AS <目标类型>)`；
    #      ③ 已有 CAST/CASE/函数的原样不动。
    #   同大类（STRING→STRING、DECIMAL(16,0)→DECIMAL(18,0)）不包，避免无谓 diff。
    _BARE_COL_RE = re.compile(r"^[A-Za-z]{1,4}\d+\.[A-Za-z0-9_]+$")

    @classmethod
    def _type_class(cls, t: str) -> str:
        """把 Oracle/Hive 类型归大类：numeric / string / date / other"""
        u = (t or "").upper()
        if not u:
            return ""
        if u.startswith(HIVE_NUMERIC_PREFIXES) or u.startswith("NUMBER"):
            return "numeric"
        # ★ 2026-10-26：必须同时覆盖 Hive 的 STRING/TEXT 与 Oracle 的 CHAR/VARCHAR…
        #   只查 ORACLE_CHAR_PREFIXES 会把 STRING 归成 other ⇒ UNION 类型对齐失效。
        if u.startswith(HIVE_STRING_PREFIXES) or u.startswith(ORACLE_CHAR_PREFIXES):
            return "string"
        if u.startswith(ORACLE_DATE_PREFIXES):
            return "date"
        return "other"

    @classmethod
    def _unify_union_type(cls, expr: str, mr) -> str:
        s = (expr or "").strip()
        if not s:
            return expr
        ftype = normalize_hive_type(mr.tgt_type, mr.tgt_name_cn)
        if not ftype:
            return expr
        # a) 空侧占位（`NULL` / `''` / `""`）→ 统一裸 `NULL`
        #    Hive 里裸 NULL 是 void 类型，可与 UNION 对侧**任意类型**适配
        #    （甲方脚本空侧即此写法）⇒ 不强行 CAST（2026-10-14 用户要求）
        if s.upper() == "NULL" or s in ("''", '""'):
            return "NULL"
        # b) 裸「别名.字段」直引 + 源/目标大类互异 → CAST 到目标类型
        if cls._BARE_COL_RE.match(s):
            tgt_cls = cls._type_class(ftype)
            src_cls = cls._type_class(getattr(mr, "src_field_type", ""))
            if tgt_cls in ("numeric", "string", "date") and src_cls in (
                    "numeric", "string", "date") and tgt_cls != src_cls:
                return "CAST(%s AS %s)" % (s, ftype)
        return expr

    def _fmt_sys_field(self, field_name: str, expr_value: str, comment: str) -> str:
        """格式化系统字段行：     , expr AS field_name  --comment"""
        line_with_alias = ("     , " + expr_value).ljust(AS_POS) + f" AS {field_name}"
        return line_with_alias.ljust(COMMENT_POS) + "--" + _one_line(comment)

    def generate_etl(self, sheet: MappingSheet, sys_name: str = "O32") -> str:
        """从 MappingSheet 生成 ETL 加工 shell 脚本"""
        tbl = extract_physical_name(sheet.tgt_table)

        # 验证表名安全性，防止 SQL 注入
        validate_db_identifier(tbl, "table name")

        sys_field_names = {sf[0] for sf in self.sys_fields}
        param = sheet.param or "p_end_dt"
        # ★ 2026-10-10：MAPPING 的「入参」列可能写非标准值（如 PI_DATE）⇒ 统一成 p_end_dt
        if param not in ALLOWED_PARAMS:
            param = "p_end_dt"
        # 防止分区参数被注入恶意字符（直接拼入生成的 INSERT 语句）
        validate_db_identifier(param, "partition param")

        # 按 group_no 分组，支持多组 UNION ALL（Python 3.7+ dict 保序）
        groups = defaultdict(list)
        for mr in sheet.mappings:
            groups[mr.group_no or "1"].append(mr)

        # 预计算每组别名（各组内别名唯一），供 FROM/JOIN 构建使用
        # ★★ 2026-10-05：组内存在别名冲突时先做二次切分（见 _subgroups 注释）
        group_data = []
        for g_key, g_mappings in groups.items():
            for sub in self._subgroups(g_mappings):
                g_aliases = self._collect_aliases(sub)
                group_data.append((g_key, sub, g_aliases))

        # ★★ 2026-10-05：丢掉「完全没有源表」的伪组。
        #    典型是被误标成独立组的系统字段行（SSYS/SRC_TAB/LD_TIME/MODIFY_TIME），
        #    它们本来就由 _build_select_lines 自动追加，留着只会多出一个 FROM 占位符分支。
        #    ★ 但至少要保留一组 —— 否则整张表都没源表时会产出没有 SELECT 的空脚本。
        with_src = [g for g in group_data if g[2]]
        if with_src:
            if len(with_src) != len(group_data):
                logger.warning(
                    "[%s] 丢弃 %d 个无源表的伪组（多为被误标组的系统字段行），保留 %d 组",
                    tbl, len(group_data) - len(with_src), len(with_src))
            group_data = with_src

        # ★★ 仍然没有源表的组（= Excel 漏登记）⇒ 记下来，在脚本里打醒目标记并告警
        broken = [g for g in group_data if not g[2]]
        if broken:
            logger.error(
                "[%s] 有 %d 个分组在 MAPPING 中未登记「源表英文名/源表别名」"
                " ⇒ 生成 %r 占位符，脚本不可执行，请补 Excel 后重跑生成器",
                tbl, len(broken), FROM_PLACEHOLDER)

        # ★★ 2026-10-13（J-23）：被引用的别名 vs 已登记的别名交叉核对。
        #    多组 UNION 时每组都从 A1/A2 重新命名，故拿**全 sheet 已登记别名的并集**比对；
        #    只要某别名在全表都查不到登记，就一定是漏填（而非跨组引用）。
        # ★★ 2026-10-13（J-23b）：源表列贴了不完整子查询 ⇒ 括号不平衡 / 空别名
        bad_subqueries = self._bad_subqueries(sheet.mappings)
        if bad_subqueries:
            logger.error(
                "[%s] 有 %d 处「源表英文名」是【不完整子查询】%s "
                "⇒ 塞进 FROM 后括号不平衡、末尾挂空别名，执行必报 ParseException；"
                "请改回真实表名（或补全整段子查询）后重跑生成器",
                tbl, len(bad_subqueries),
                ["%s:%s" % (a, r) for a, r in bad_subqueries])

        # ★★★ 2026-10-04 修复：依赖声明块系统性漏表。
        #
        # 旧实现把每组别名合并成一个 all_aliases（**以别名为键**）再提取源表：
        #     for alias, info in g_aliases.items():
        #         if alias not in all_aliases: all_aliases[alias] = info
        # 但多组 UNION ALL 时，**每组都从 A1/A2/A3 重新命名** ⇒ 除第一组外，
        # 其余各组的同名别名一律被丢弃 ⇒ 依赖声明块只反映第一组的源表。
        #
        # 实证：DWD_PTY_ORG_BASIC_INFO_PTD 的 SQL 实际读 11 张源表，旧实现只声明了 3 张
        #（DWD_PROD_PROD_TAIL_PFD 同样：读 6 张、只声明 4 张）。
        #
        # 现改为直接遍历该 sheet 的**全部映射行**收集源表，按物理表名去重、保持首次出现顺序
        #（dict 保序）。中文名取首次出现的非空值。
        dep_map = {}
        for mr in sheet.mappings:
            t = mr.src_table_name or mr.src_table_alias
            if not t:
                continue
            # ★ 2026-10-12：源表列贴的是整段子查询时，展开成其内部 FROM/JOIN 的
            #   真实表名（补 schema 后与 SQL 里的引用一致），不再把整段 SELECT
            #   当一个"表名"写进依赖声明块。
            tbls = ([qualify_table(tb) for tb, _cn in extract_tables_from_subquery(t)]
                    if is_subquery(t) else [t])
            for tb in tbls:
                if not tb:
                    continue
                # ★ 2026-10-12：同组后续行的源表英文名常为空，代码回退取了
                #   源表别名（A12/A3/T1/1 等），别名不是表名，会污染依赖声明块
                #   （如 DWD_EVT_EQUI_JOUR_INFO_PTD 出现 "-- ** A12"）。
                #   数仓表名必含 "_"（ODS_/DWD_/DWS_）或 "."（schema.表），
                #   无此二者即视为别名丢弃；子查询已展开成真表，天然含 "_"。
                if "_" not in tb and "." not in tb:
                    continue
                if tb not in dep_map:
                    dep_map[tb] = mr.src_table_cn or ""
                elif not dep_map[tb] and mr.src_table_cn:
                    dep_map[tb] = mr.src_table_cn

        dep_lines = ["-- ** 源表："] + [
            "-- **         " + tbl.ljust(DEP_TBL_WIDTH) + cn
            for tbl, cn in dep_map.items()
        ]

        dep_block = "\n".join(dep_lines)

        # ---- 先拼 SQL 正文（SELECT…FROM/JOIN…WHERE），供「未定义别名」校验 ----
        # ★ J-23：必须对【拼装后的正文】做校验，而不是对 MAPPING 各列做 ——
        #   · 只扫「映射规则」会漏掉只在 ON 条件里引用的（实测 DWD_SCR_DIM_SCR_INFO_PFD 的 T3）；
        #   · 扫「关联条件」又会把【所在行别名为空、整条 ON 被静默丢弃】的算进来
        #     （实测 DWD_ACCT_ACCT_CNFM_PFD 的 T2 —— 脚本里根本不留痕迹，是丢数据不是 10004）。
        #   判据只有一条：**别名字号在最终 SQL 里被 `<别名>.` 引用，却没有任何地方定义它**。
        body_lines = []
        # ★ 按组逐个校验：UNION ALL 的每个分支是**独立的作用域**，A1/A2 每组都重新命名。
        #   若拿全表并集比对，第 2 组漏登记的 A1 会被第 1 组的定义"顶掉"⇒ 漏报
        #   （而 Hive 编译第 2 组时照样 10004）。
        unregistered_aliases = set()
        # ★ J-29：只要有效组 >1 就是 UNION ALL，各组 SELECT 必须同列同类型
        in_union = len(with_src) > 1
        for g_idx, (g_key, g_mappings, g_aliases) in enumerate(group_data):
            g_select_lines = self._build_select_lines(
                g_mappings, sheet.source_tables,
                sys_field_names, sys_name, add_src_fields=self.has_src_fields,
                in_union=in_union,
            )
            g_from_join = self._build_from_join(g_aliases)
            g_where = self._build_where(g_aliases)

            g_body = []
            if g_idx == 0:
                g_body.append("SELECT")
            else:
                g_body.append("UNION ALL")
                g_body.append("SELECT")

            g_body.append("\n".join(g_select_lines))
            g_body.append(g_from_join)
            if g_where:
                g_body.append("WHERE " + "\n  AND ".join(g_where))

            g_text = "\n".join(g_body)
            unregistered_aliases |= set(self._undefined_aliases_in_sql(g_text))
            body_lines.extend(g_body)

        unregistered_aliases = sorted(unregistered_aliases)
        if unregistered_aliases:
            logger.error(
                "[%s] SQL 里引用了 %d 个【没有任何地方定义】的源表别名 %s "
                "⇒ 执行必报 Error 10004 Invalid table alias or column reference；"
                "请在本表 MAPPING 给这些别名补「源表英文名 / 源表别名 / JOIN方式」后重跑生成器",
                tbl, len(unregistered_aliases), unregistered_aliases)

        lines = [
            "#!/bin/sh",
            "#初始化环境变量：",
            # ★★ 2026-10-04 修复：原来写的是 "source ${hadoop_env}" —— ${hadoop_env} 这个变量
            #   从未被定义过（展开成空 ⇒ `source` 报 "filename argument required"，脚本直接挂），
            #   且第二行 "source ${source_path}" 指向的 source_env 已于 10-04 彻底退休。
            #   现与 ODS 模板（demo/templates/etl_ods_template.sh）保持一致：只 source 一行。
            "source /home/dolphinscheduler/hadoop_env",
            "inceptor_beeline()",
            "{",
            "    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e \"$1\"",
            "}",
            "",
            "",
            "inceptor_beeline \"",
            "",
            "-- **************************************************************************",
            "-- ** 主题:" + (sheet.tgt_table_cn or ""),
            # ★★ 2026-10-05 修复：描述字段可能含手工换行（「1、…\n2、…」），
            #   原样拼接会让续行丢掉 `--` 前缀 ⇒ Hive 把续行当 SQL 解析、整条语句报 ParseException。
            #   现按行拆开，每行都加 `-- **` 前缀（续行缩进对齐）。
            *(["-- ** 描述:" + ln if i == 0 else "-- **       " + ln
               for i, ln in enumerate(
                   (sheet.func_desc or sheet.tgt_table_cn or "")
                   .replace("\r\n", "\n").replace("\r", "\n").split("\n"))]),
            "-- ** 创建者:auto",
            "-- ** 创建日期:auto",
            "-- ** 修改日志:",
            "-- ** auto，新建",
            "-- ** 目标表：" + self.schema + "." + tbl + "              " + (sheet.tgt_table_cn or ""),
            dep_block,
            # ★★ 2026-10-05：有组没源表时，把警告直接写进脚本，grep 就能捞出来
            *([
                "-- ** ★★ 警告：本脚本存在未解析的源表占位符 " + FROM_PLACEHOLDER,
                "-- **        请在本表 MAPPING 的「源表英文名 / 源表别名」列补登记后重跑生成器，",
                "-- **        否则执行会报 Table not found: source_table。",
            ] if broken else []),
            # ★★ 2026-10-13（J-23）：引用了未登记的别名 ⇒ 打醒目标记（grep 可捞）
            *([
                "-- ** ★★TODO 未登记别名：" + ", ".join(unregistered_aliases),
                "-- **        这些别名出现在「映射规则/关联条件」里，但本表 MAPPING 的",
                "-- **        「源表英文名 / 源表别名」列没给它们登记 ⇒ 不会生成 FROM/JOIN，",
                "-- **        执行必报 Error 10004 Invalid table alias or column reference。",
                "-- **        请回上游 MAPPING 补齐后重跑生成器（生成器无法推断源表）。",
            ] if unregistered_aliases else []),
            # ★★ 2026-10-13（J-23b）：源表列是不完整子查询 ⇒ 同样打标记
            *([
                "-- ** ★★TODO 不完整子查询：" + "; ".join("%s(%s)" % (a, r) for a, r in bad_subqueries),
                "-- **        「源表英文名」列被写进了注释/半截 SQL，塞进 FROM 后括号不平衡，",
                "-- **        执行必报 ParseException。请改回真实表名或补全整段子查询。",
            ] if bad_subqueries else []),
            "-- **************************************************************************",
            "",
            *HIVE_SETTINGS,
            "",
            "INSERT OVERWRITE TABLE " + self.schema + "." + tbl + " PARTITION(P_DT = '${" + param + "}')",
        ]

        # 正文已在上面拼好（拼完才能校验别名），这里直接接上
        lines.extend(body_lines)
        lines.append(";\"")
        # ★ 2026-10-10：出口统一规范化分区变量（非 p_start_dt/p_end_dt 一律改成 p_end_dt）
        # ★ J-22（2026-10-13）：出口统一剥离 Inceptor 三参 DATE_FORMAT（c20 过滤条件/
        #   c8 关联条件/自定义子查询不走 _resolve_expr 的 compat_sql_functions，
        #   只能在全文出口收口，见 sql_tables.normalize_inceptor_sql）。
        return normalize_inceptor_sql(normalize_params("\n".join(lines)))

    def generate_all_etl_files(self, sheets: List[MappingSheet], output_dir: str, sys_name: str = "O32") -> None:
        """按表生成独立的 ETL shell 脚本

        ★ 2026-10-22（评审 HIGH-9）：加 per-table 兜底（理由同
          generate_all_ddl_files）——单表校验失败不应中断整批生成。
        """
        os.makedirs(output_dir, exist_ok=True)
        for sheet in sheets:
            if not sheet.tgt_table or not sheet.mappings:
                continue
            tbl = extract_physical_name(sheet.tgt_table)
            filepath = os.path.join(output_dir, tbl + ".sh")
            try:
                script = self.generate_etl(sheet, sys_name)
            except ValueError as e:
                logger.error(f"  ERROR: Skipping table '{sheet.tgt_table}': {e}")
                continue
            write_file_safe(filepath, script, sheet.tgt_table, "ETL")
