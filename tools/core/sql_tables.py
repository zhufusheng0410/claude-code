"""SQL 表名/子查询共用工具（parser / generator / lineage 三层复用）。

★ 2026-10-12 新建：甲方 MAPPING 的「源表英文名」列会**直接贴整段子查询**
（SELECT ... FROM ... LEFT JOIN ... WHERE ...，实测 13 张 DWD_EVT_* 中招）。
此前只有 `generator/lineage.py` 私有实现了子查询识别/展开，导致
「血缘能展开、SQL 构建和源表收集不认」的分裂状态：
  - SQL 产出 `LEFT JOIN SELECT ... FROM ...`（无括号）⇒ ParseException
  - 依赖声明块/SRC_TAB 把整段子查询当一个"表名" ⇒ 真实上游表丢失
本模块把这两件事下沉到 core，三层共用，杜绝再次分裂。
"""

import functools
import re

# 正则：从子查询中提取真实表名（支持 schema.table 格式）及行尾注释
#
# ★ 2026-10-22 修 bug（评审 HIGH-1）：原正则含 `\s*(?:[A-Za-z0-9_]+)?` 这一段
#   「可选别名」，它会把表名后紧跟的**下一个标识词**当成别名吞掉。实测：
#     'FROM A JOIN B'          → 只提取到 [A]，B 丢失
#     'FROM A JOIN B JOIN C'   → 提取到 [A, C]，中间的 B 丢失
#   而正则一旦吞掉 'JOIN' 这个关键字，余下文本里就再没有 'FROM/JOIN' 前缀，
#   后续表**永远匹配不到** ⇒ 上游表静默丢失（不报错、不告警）。
#   后果：MAPPING 的 source_tables 不全 ⇒ DWD 的 SRC_TAB 字段与依赖声明块漏表
#         ⇒ 血缘与调度依赖缺边 ⇒ 静默产出错数据。
#   ⇒ 去掉别名吞掉段。别名不需要在这里取（下游按位置/注释消费），
#     且 `FROM A JOIN B` 里的 'JOIN' 本就不该被当成别名。
_TABLE_REF_RE = re.compile(
    r'(?:FROM|JOIN)\s+([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)?)\s*(?:--\s*([^\n]*))?',
    re.IGNORECASE,
)

# 子查询内部 FROM/JOIN 后的表名 token（用于逐个补 schema）
_INNER_TABLE_RE = re.compile(
    r"(?i)\b(FROM|JOIN)(\s+)([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)?)")


@functools.lru_cache(maxsize=8192)
def is_subquery(value: str) -> bool:
    """判断字符串是否为子查询（SELECT 开头 / 括号包 SELECT / 注释开头后跟 SELECT）。

    ★ 2026-10-18：lru_cache —— 同一源表值会在解析（source_tables）/依赖声明块/
      FROM/JOIN 渲染/血缘四处被反复判定，纯函数且字符串重复度高。
    """
    if not value:
        return False
    v = value.strip().upper()
    return (v.startswith("SELECT") or
            (v.startswith("(") or v.startswith("（")) and "SELECT" in v or
            v.startswith("--") and "SELECT" in v)


@functools.lru_cache(maxsize=8192)
def _extract_tables_cached(subquery: str) -> tuple:
    if not subquery:
        return ()
    matches = _TABLE_REF_RE.findall(subquery)
    seen, result = set(), []
    for table, comment in matches:
        if table and table not in seen:
            seen.add(table)
            result.append((table, comment.strip() if comment else ""))
    return tuple(result)


def extract_tables_from_subquery(subquery: str) -> list:
    """从子查询 SQL 中提取引用的真实表名，返回 [(表名, 行尾注释), ...]（保序去重）。

    ★ 2026-10-18：正则提取按 subquery 原文 lru_cache（一段子查询会被解析/依赖/
      渲染/血缘反复提取）；对外仍返回新 list，调用方原地修改不影响缓存。
    """
    return list(_extract_tables_cached(subquery))


# 单段表名的合法字符（与 tools/utils/validation.validate_db_identifier 一致）
_IDENT_RE = re.compile(r"^[A-Za-z0-9_]+$")


def validate_table_ref(name: str) -> str:
    """校验一个表引用（可含 ``schema.table`` 两段），不合法则抛 ValueError。

    ★ 2026-10-22 新增（评审 HIGH-8）：MAPPING 的「源表英文名」列是**外部输入**
      （甲方 Excel），且 J-28 已说明「MAPPING 脏数据是常态」。此前该值经
      `qualify_table` 后**原样**拼进 FROM/JOIN，从未经任何标识符校验 ——
      一个带单引号/分号/注释符的表名会直接进入生成的 ETL 脚本。
      目标表名有 `validate_db_identifier` 兜底，**源表名却没有**，是缺口。

    ⇒ 这里补上第一道防线：每段（schema 与表名）都必须是 ``[A-Za-z0-9_]+``。

    注：刻意不 import tools.utils.validation —— core 是最底层，
    依赖上层 utils 会形成环。此处规则与那边保持一致（均为字母数字下划线）。
    """
    if not name:
        raise ValueError("table reference cannot be empty")
    for seg in name.split("."):
        if not _IDENT_RE.match(seg):
            raise ValueError(
                "Invalid table reference %r: each segment must contain only "
                "alphanumeric and underscore" % name)
    return name


@functools.lru_cache(maxsize=8192)
def qualify_table(name: str, dwd_schema: str = "DWDXDAY",
                  dws_schema: str = "DWSXDAY") -> str:
    """给裸表名补 schema：`ODS_Xxx_*` → `ODS_XDAY_Xxx.*`，`DWD_*` → DWDXDAY.*，`DWS_*` → DWSXDAY.*。

    已带库名（含 `.`）或无法识别的原样返回。
    ★ 2026-10-18：lru_cache —— 依赖声明块/FROM/JOIN 渲染/血缘多处重复调用。
    ★ 2026-10-22：先做标识符校验（见 validate_table_ref）——
      源表名来自甲方 MAPPING Excel，此前**原样**拼进 FROM/JOIN，
      一个带引号/分号的表名就能污染生成的 ETL 脚本。
    """
    if not name:
        return name
    validate_table_ref(name)
    if "." in name:
        return name
    m = re.match(r"^ODS_([A-Za-z0-9]+)_", name)
    if m:
        return "ODS_XDAY_%s.%s" % (m.group(1), name)
    up = name.upper()
    if up.startswith("DWD_"):
        return "%s.%s" % (dwd_schema, name)
    if up.startswith("DWS_"):
        return "%s.%s" % (dws_schema, name)
    return name


def qualify_subquery_tables(subquery: str) -> str:
    """把子查询内部 FROM/JOIN 的裸表名逐个补 schema（其余文本原样保留）。"""
    if not subquery:
        return subquery
    return _INNER_TABLE_RE.sub(
        lambda m: m.group(1) + m.group(2) + qualify_table(m.group(3)), subquery)


def wrap_subquery(subquery: str) -> str:
    """把子查询文本包成 `( ... )` 派生表；已带括号的原样返回。"""
    if not subquery:
        return subquery
    inner = subquery.strip()
    if inner.startswith("(") and inner.endswith(")"):
        return inner
    if inner.startswith("（") and inner.endswith("）"):
        return "(" + inner[1:-1] + ")"
    return "(" + inner + ")"


# ★ 2026-10-12（J-07）：甲方 MAPPING 的映射规则里用了 Hive 4.2 不认的函数名
#   （实测 8 张表报 `SemanticException [Error 10011]: Invalid function IFNULL`）。
#   在 SELECT/CASE 表达式入口统一改写。宁窄勿宽——只改**语义与参数个数都相同**的：
#     IFNULL(a, b)  → COALESCE(a, b)   MySQL 风格 → 标准 SQL（Hive/Inceptor 通用）
#     ISNULL(a, b)  → COALESCE(a, b)   SQL Server 风格（同上）
#   选 COALESCE 而非 NVL：标准 SQL 函数，Hive 3/4 与 Inceptor 行为一致。
#   ⚠ 不动 NVL2（3 参，语义不同）、不动字符串字面量里出现的关键字
#     （如 concat('@IFNULL(' ...) 极罕见，真出现再处理）。
_FUNC_COMPAT_RE = re.compile(r"\b(IFNULL|ISNULL)\s*\(", re.IGNORECASE)


@functools.lru_cache(maxsize=8192)
def compat_sql_functions(expr: str) -> str:
    """把 Hive 不兼容的函数名改写为等价 Hive 函数（IFNULL/ISNULL → COALESCE）。

    ★ 2026-10-18：lru_cache —— 同一表达式（规则列/ON 条件）在小组切分、
      校验重扫等路径会被重复改写，纯函数。
    """
    if not expr or "IFNULL" not in expr.upper() and "ISNULL" not in expr.upper():
        return expr
    return _FUNC_COMPAT_RE.sub("COALESCE(", expr)


def normalize_inceptor_sql(sql: str) -> str:
    """J-22（2026-10-13）：剥离 Inceptor 方言**三参** DATE_FORMAT(date, fmt1, fmt2)
    → Hive 二参（保留 fmt1）。

    背景：甲方 Inceptor 的 DATE_FORMAT 可带第三参（'yyyy-MM-dd' 等），
    本集群 Hive 4.2 的签名为 (date, fmt[, timezone]) —— 第三参传格式串会当
    timezone 处理 ⇒ Error 10015 Arguments length mismatch（实测 NAV/WARN_HIS/
    SALE_FEER/TAIL 的 c20 过滤条件、c8 关联条件、DWS 保有明细等大量使用；
    NAV 变体为 fmt2='yyyyMMdd'，故按 'yyyy-MM-dd' 扫描会漏）。

    实现：**括号配平扫描**（跳过字符串字面量），仅当调用恰好 3 个顶层实参
    且第 3 参是字符串字面量时剥掉第 3 参 —— 不会误伤 COALESCE(a,'x','y')
    这类"2 参函数后跟 3 参调用"的相邻假象（正则法会）。
    第 2 参（保留的格式串）顺带去首尾空白：映射里见过 'yyyyMMdd ' 尾空格
    笔误，会让分区值多一个空格、永远匹配不上分区。
    """
    if not sql or "DATE_FORMAT" not in sql.upper():
        return sql
    low = sql.lower()
    n = len(sql)
    out = []
    i = 0
    while i < n:
        j = low.find("date_format", i)
        if j < 0:
            out.append(sql[i:])
            break
        out.append(sql[i:j])
        k = j + len("date_format")
        # 防单词内命中（如 XXXDATE_FORMAT 列名后缀）
        if j > 0 and (low[j - 1].isalnum() or low[j - 1] == "_"):
            out.append(sql[j:k])
            i = k
            continue
        while k < n and sql[k] in " \t\r\n":
            k += 1
        if k >= n or sql[k] != "(":
            out.append(sql[j:k])
            i = k
            continue
        # 配平右括号 + 顶层实参切分
        depth = 0
        inq = None
        pos = k
        cur = []
        args = []
        balanced = False
        while pos < n:
            ch = sql[pos]
            if inq:
                cur.append(ch)
                if ch == inq:
                    inq = None
            elif ch in ("'", '"'):
                inq = ch
                cur.append(ch)
            elif ch == "(":
                if depth == 0:
                    depth = 1          # 调用自身的左括号不进实参文本
                else:
                    depth += 1
                    cur.append(ch)
            elif ch == ")":
                if depth == 1:
                    args.append("".join(cur))
                    balanced = True
                    break
                depth -= 1
                cur.append(ch)
            elif ch == "," and depth == 1:
                args.append("".join(cur))
                cur = []
            else:
                cur.append(ch)
            pos += 1
        if not balanced:
            out.append(sql[j:k])
            i = k
            continue
        if len(args) == 3 and args[2].strip()[:1] in ("'", '"'):
            fmt = args[1].strip()
            if len(fmt) >= 2 and fmt[0] == fmt[-1] and fmt[0] in ("'", '"'):
                fmt = fmt[0] + fmt[1:-1].strip() + fmt[0]
            out.append("DATE_FORMAT(%s, %s)" % (args[0].strip(), fmt))
        else:
            out.append(sql[j:pos + 1])
        i = pos + 1
    return "".join(out)
