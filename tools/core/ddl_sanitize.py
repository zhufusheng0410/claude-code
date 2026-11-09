# -*- coding: utf-8 -*-
"""Inceptor → Hive 4.2 的 DDL 方言清洗（DWD / DWS 共用单一来源）。

★ 2026-10-26 独立成模块的原因：
   原先 `dw-pipeline.py` 为了复用这 6 行，用 importlib exec 了整个 86KB 的
   `dwd-pipeline.py`（连带 openpyxl / pandas）⇒ 缺 openpyxl 的环境里
   `ddl --layers DWS --source jf` 直接抛 ModuleNotFoundError，
   而它真正用到的只是下面几个正则。独立后两边都只依赖 `re`。

清洗项（甲方交付脚本是 Inceptor 方言）：
   1. `DEFAULT NULL` —— Hive 4.2 不支持列默认值；
   2. `VARCHAR(n)` / `VARCHAR2(n)` —— 统一 STRING；
   3. 名为 `DATE` 的列 —— Hive 保留字，反引号转义；
   4. `DROP TABLE IF EXISTS` 语句剥离（`strip_drop_stmts`，见该函数注释）。
"""
import re

__all__ = ["sanitize_ddl", "strip_drop_stmts"]


def sanitize_ddl(body):
    """把一段 CREATE TABLE 语句清洗成 Hive 4.2 可执行形态（只做上述 3 项替换）。"""
    body = re.sub(r'\s+DEFAULT\s+NULL\b', '', body, flags=re.I)
    body = re.sub(r'\bVARCHAR2?\s*\(\s*\d+(?:\s+(?:BYTE|CHAR))?\s*\)', 'STRING', body, flags=re.I)
    body = re.sub(r'(?m)^([ \t]*)(DATE)(\s+)(STRING|VARCHAR|TIMESTAMP|DATE)\b',
                  r'\1`DATE`\3\4', body, flags=re.I)
    return body


# --------------------------------------------------------------------------- #
# DROP 语句剥离（2026-11-09 新增，评审 A1）
# --------------------------------------------------------------------------- #
# 甲方建表脚本里 `DROP TABLE IF EXISTS` 与 `CREATE TABLE` 之间**可能没有分号**。
# 实测 `02-DWS建表脚本.sql:1212`：
#     DROP TABLE IF EXISTS DWSXDAY.DWS_TRAN_FUTR_TRAN_DETAIL_PTD      ← 无分号
#     CREATE TABLE  DWSXDAY.DWS_TRAN_FUTR_TRAN_DETAIL_PTD (
# 而按 `;` + 换行切块后，该表所在 chunk 就变成
#     `DROP TABLE IF EXISTS X \nCREATE TABLE X (...);`
# 只认「DROP 行以 `;` 结尾」的剥法会**整条漏剥** ⇒ DROP 留在 CREATE 前面，
# 落盘的 `ddl/*.sql` 与 `01_ddl.sql` 一上 beeline 就 ParseException
# （DROP 与 CREATE 被合成一条语句）。diff_ddl 只看列/分区/注释，看不出这个问题
# —— 实测 37/37「与甲方一致」全绿。故这里**分号可有可无**都剥。
_RE_DROP_STMT_LINE = re.compile(
    r"(?im)^[ \t]*DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?[^;\n]*;?[ \t]*\n")
# 兜底：DROP 与 CREATE 被粘连在**同一行**（无换行），用 CREATE 前视界定位
_RE_DROP_STMT_INLINE = re.compile(
    r"(?i)\bDROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?[A-Za-z0-9_.]+[ \t]*;?[ \t]*(?=\bCREATE\b)")


def strip_drop_stmts(chunk: str) -> str:
    """剥掉一段 DDL 文本里的 `DROP TABLE IF EXISTS` 语句（**分号可有可无**）。

    只剥 DROP，CREATE 及其余内容原样保留；找不到 DROP 时原样返回（仅 strip）。
    """
    body = _RE_DROP_STMT_LINE.sub("", chunk)
    body = _RE_DROP_STMT_INLINE.sub("", body)
    return body.strip()
