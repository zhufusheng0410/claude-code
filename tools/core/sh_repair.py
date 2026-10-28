# -*- coding: utf-8 -*-
"""甲方交付 .sh 的「拼接副本」修复：只保留第一个 beeline 对应的完整 SQL。

背景（2026-10-26 实测）：
  甲方 `02-DWS执行脚本/*.txt` 里有个别文件是**两份脚本被拼接**在一起的：
    `DWS_PROD_SALE_DATA_PTD.sh` 第 71 行是 `done#!/bin/sh` —— 第一份的 `done`
  与第二份的 shebang 之间丢了换行，于是 `done` 不再是关键字（被粘成一个词），
  第一个 `while` 闭不上，整脚本 `bash -n` 报 `unexpected end of file`，无法执行。

处置口径（用户 2026-10-26 定）：
  **类似 sale_data 的脚本，只保留第一个 beeline 对应的完整 SQL**，即截到第一份
  循环体结束（第一个 `done`），把其后粘连的副本整段丢掉；两份 SQL 若不一致则只提示、
  仍按第一份保留（口径优先，差异需人工确认）。

判定信号：
  - `inceptor_beeline "` 是**带 SQL 参数**的调用（函数定义是 `inceptor_beeline()`，不含引号）；
  - 该调用出现 ≥2 次 ⇒ 视为拼接副本（本项目的脚本模板每个副本只有一处 SQL 调用）；
  - 截断点 = 第一处行首 `done`（`done#!/bin/sh` 这类粘连形态取到 `done` 为止）。

行尾保持：文件是 CRLF 就仍写 CRLF，不做顺带格式化，避免无谓 diff。
"""
import re

__all__ = [
    "count_sql_calls",
    "sql_blocks",
    "trim_to_first_copy",
    "DEVIATION_MARK",
]

# 仓库里带这个标记的文件 = 有意偏离甲方原文，`--force-dws-raw` 不得覆盖
DEVIATION_MARK = "DW-DEVIATION"

_RE_SQL_CALL = re.compile(r'(?m)^[ \t]*inceptor_beeline\s+"')
_RE_SQL_BLOCK = re.compile(r'inceptor_beeline\s+"(.*?)"', re.S)
_RE_DONE = re.compile(r'(?m)^[ \t]*done\b')


def count_sql_calls(text):
    """带 SQL 参数的 `inceptor_beeline "` 调用次数（≈ 脚本里实际执行的 SQL 份数）。"""
    return len(_RE_SQL_CALL.findall(text))


def sql_blocks(text):
    """按出现顺序取出各份 SQL 文本（已去首尾空白），用于判定副本是否等价。"""
    return [b.strip() for b in _RE_SQL_BLOCK.findall(text)]


def trim_to_first_copy(text):
    """只保留第一份（第一个 beeline SQL 所在循环体），返回 (新文本, 提示列表)。

    无可裁剪时返回 `(text, [])`，调用方可据 `new is text`/相等判断是否需落盘。
    """
    notes = []
    n = count_sql_calls(text)
    if n <= 1:
        return text, notes
    m = _RE_DONE.search(text)
    if not m:
        return text, [f"SQL 调用 ×{n} 但未找到 done，跳过（需人工确认）"]
    tail = text[m.end():]
    if "inceptor_beeline" not in tail:
        return text, [f"SQL 调用 ×{n} 但 done 之后无副本（疑似同一循环内多段 SQL），跳过"]
    nl = "\r\n" if "\r\n" in text else "\n"
    head = text[:m.end()]
    if not head.endswith(nl):
        head += nl          # 原 `done` 与下一份 shebang 粘连，补回换行

    blocks = sql_blocks(text)
    first = blocks[0] if blocks else ""
    diff = [i for i, b in enumerate(blocks[1:], start=2) if b != first]
    saved = len(tail)
    notes.append(f"SQL 调用 ×{n} → 保留第 1 份，丢弃拼接副本 {saved} 字符")
    if diff:
        notes.append(f"⚠ 第 {diff} 份 SQL 与第 1 份**不一致**：已按口径保留第 1 份，"
                     f"请人工确认是否存在漏掉的口径")
    else:
        notes.append(f"第 2~{n} 份 SQL 与第 1 份逐字符相同（丢弃无内容损失）")
    return head, notes
