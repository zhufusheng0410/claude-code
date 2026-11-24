# -*- coding: utf-8 -*-
"""本地 DDL 与甲方建表语句的逐表比对（DWD / DWS 两条 DDL 链路共用）。

★ 为什么单独一个模块
    「读本地 `ddl/*.sql` → `diff_ddl` 结构比对 → `lint_statements` 语句边界」
    这一组动作此前在仓库里有 **4 份副本**：`dws/ddl.py::verify_ddl_after_write`
    （落盘自检）、`dws/verify.py::cmd_verify_ddl`（纯校验）、
    `dws/ddl.py::verify_ddl_vs_jf`（反向比对）、
    `dwd/ddl_check.py::verify_ddl_after_write`（A8 落盘自检）。
    4 份副本改一处忘另一处，就会让某个维度（如语句边界）在其中一条链路上
    静默失效 —— 校验代码最不该有的死法。⇒ 收成一份内核。
    「本地文件不存在」的文案与计数各调用方不同（有的带路径、只打印表名、
    或当成一条 probs 上报），由调用方自己处理，不在这里统一。
"""
from pathlib import Path

from tools.core.loader import load

_DDL_VERIFY = Path(__file__).resolve().parent / "ddl_verify.py"


def compare_local_ddl(local_path, jf_text):
    """比对单个本地 DDL 文件与甲方建表语句。

    local_path : 本地 `ddl/*.sql` 的 Path
    jf_text    : 该表的甲方 CREATE 语句（已 sanitize / 剥 DROP、**不带**分号，
                 分号在函数内补 —— 四个调用方原本各写一遍 `stmts[t] + ";"`）

    返回 `(diff, probs)`：
      * 文件存在 ⇒ `diff` 为 `diff_ddl` 结果（无差异时 `diff.empty()` 为真），
        `probs` 包含语句边界和文件名与建表目标一致性检查（无问题为 `[]`）；
      * 文件不存在 ⇒ `(None, None)`，"本地文件不存在" 的文案由调用方决定。
    """
    if not local_path.is_file():
        return None, None
    verify = load(_DDL_VERIFY)
    text = local_path.read_text(encoding="utf-8", errors="replace")
    probs = verify.lint_statements(text)
    local = verify.parse_ddl(text)
    if local and local.table_name.upper() != local_path.stem.upper():
        probs.append(f"文件名 {local_path.stem} 与建表目标 {local.table_name} 不一致")
    return verify.diff_ddl(jf_text + ";", text, "甲方", "本地"), probs


def append_diff_section(lines, table, sysname, diff):
    """把一张表的 DDL 差异明细追加进 Markdown 报告行（DWD / DWS 报告同款）。

    ★ 与 `dws/ddl.py::_print_ddl_diff`（终端版）覆盖同一批维度；两份
      差异报告此前各抄了一遍这一节，现在只有这一份。
    """
    lines.append(f"## {table} ({sysname})")
    lines.append(f"- 摘要: {diff.summary()}")
    if diff.table_name_mismatch:
        lines.append(f"- 表名: 甲方 `{diff.table_name_mismatch[0]}` / "
                     f"本地 `{diff.table_name_mismatch[1]}`")
    if diff.type_mismatch:
        lines.append("### 类型不一致")
        for col, lt, rt in diff.type_mismatch:
            lines.append(f"- {col}: 甲方 `{lt}` / 本地 `{rt}`")
    if diff.comment_mismatch:
        lines.append("### 注释不一致")
        for col, lc, rc in diff.comment_mismatch:
            lines.append(f"- {col}: 甲方 `{lc}` / 本地 `{rc}`")
    if diff.partition_mismatch:
        lines.append("### 分区不一致")
        lines.append(f"- 甲方: {[(c.name, c.type) for c in diff.left_partitions]}")
        lines.append(f"- 本地: {[(c.name, c.type) for c in diff.right_partitions]}")
    if diff.table_comment_mismatch:
        lines.append("### 表注释不一致")
        lines.append(f"- 甲方: `{diff.table_comment_mismatch[0]}`")
        lines.append(f"- 本地: `{diff.table_comment_mismatch[1]}`")
    if diff.only_in_left:
        lines.append(f"- 仅甲方有列: {', '.join(diff.only_in_left)}")
    if diff.only_in_right:
        lines.append(f"- 仅本地有列: {', '.join(diff.only_in_right)}")
