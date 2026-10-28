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
  3. 名为 `DATE` 的列 —— Hive 保留字，反引号转义。
"""
import re

__all__ = ["sanitize_ddl"]


def sanitize_ddl(body):
    """把一段 CREATE TABLE 语句清洗成 Hive 4.2 可执行形态（只做上述 3 项替换）。"""
    body = re.sub(r'\s+DEFAULT\s+NULL\b', '', body, flags=re.I)
    body = re.sub(r'\bVARCHAR2?\s*\(\s*\d+(?:\s+(?:BYTE|CHAR))?\s*\)', 'STRING', body, flags=re.I)
    body = re.sub(r'(?m)^([ \t]*)(DATE)(\s+)(STRING|VARCHAR|TIMESTAMP|DATE)\b',
                  r'\1`DATE`\3\4', body, flags=re.I)
    return body
