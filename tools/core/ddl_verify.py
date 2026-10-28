# -*- coding: utf-8 -*-
"""DDL 结构化解析与对比（只依赖 re，供 dw-pipeline.py 落盘后自检用）。

对比维度：
- 列名、类型、注释（顺序不敏感，按名匹配）
- 分区列（顺序敏感）
- 表级 COMMENT
"""
import re
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Tuple

__all__ = ["DDLStruct", "parse_ddl", "diff_ddl", "DDLDiff"]


@dataclass
class Column:
    name: str
    type: str           # 已归一化：大写、去空格、去长度内空格，如 DECIMAL(30,8)
    comment: str = ""

    def __eq__(self, other):
        if not isinstance(other, Column):
            return False
        return self.name == other.name and self.type == other.type and self.comment == other.comment

    def __hash__(self):
        return hash((self.name, self.type, self.comment))


@dataclass
class DDLStruct:
    table_name: str
    columns: List[Column] = field(default_factory=list)
    partitions: List[Column] = field(default_factory=list)
    table_comment: str = ""

    def to_dict(self):
        return {
            "table": self.table_name,
            "columns": [{"name": c.name, "type": c.type, "comment": c.comment} for c in self.columns],
            "partitions": [{"name": c.name, "type": c.type, "comment": c.comment} for c in self.partitions],
            "table_comment": self.table_comment,
        }


@dataclass
class DDLDiff:
    table: str
    only_in_left: List[str] = field(default_factory=list)   # 仅左侧有的列名
    only_in_right: List[str] = field(default_factory=list)  # 仅右侧有的列名
    type_mismatch: List[Tuple[str, str, str]] = field(default_factory=list)   # (col, left_type, right_type)
    comment_mismatch: List[Tuple[str, str, str]] = field(default_factory=list)  # (col, left_cmt, right_cmt)
    partition_mismatch: bool = False
    left_partitions: List[Column] = field(default_factory=list)
    right_partitions: List[Column] = field(default_factory=list)
    table_comment_mismatch: Tuple[str, str] = None          # (left, right)
    # ★ 2026-10-27：两侧显示名由调用方给定（如「甲方 / 本地」「线上 / 仓库」）。
    #   原先 summary() 把它们**硬编码**成甲方/本地，而 diff_ddl() 的
    #   left_label/right_label 一路传到 _cmp_cols 却**从未被使用**
    #   ⇒ 换场景对比时摘要仍写「甲方/本地」，属误导性输出。
    left_label: str = "甲方"
    right_label: str = "本地"

    def empty(self) -> bool:
        return (not self.only_in_left and not self.only_in_right and
                not self.type_mismatch and not self.comment_mismatch and
                not self.partition_mismatch and self.table_comment_mismatch is None)

    def summary(self) -> str:
        if self.empty():
            return "无差异"
        parts = []
        if self.only_in_left:
            parts.append(f"仅{self.left_label}有列: {', '.join(self.only_in_left)}")
        if self.only_in_right:
            parts.append(f"仅{self.right_label}有列: {', '.join(self.only_in_right)}")
        if self.type_mismatch:
            parts.append(f"类型不一致: {len(self.type_mismatch)} 列")
        if self.comment_mismatch:
            parts.append(f"注释不一致: {len(self.comment_mismatch)} 列")
        if self.partition_mismatch:
            parts.append(f"分区不一致: {self.left_label}={self.left_partitions} "
                         f"vs {self.right_label}={self.right_partitions}")
        if self.table_comment_mismatch:
            parts.append(f"表注释不一致: {self.left_label}='{self.table_comment_mismatch[0]}' "
                         f"{self.right_label}='{self.table_comment_mismatch[1]}'")
        return "; ".join(parts)


# ──────────────────────────────────────────────────────────────────────────────
# 解析器
# ──────────────────────────────────────────────────────────────────────────────

_TYPE_NORM = re.compile(r'\s+')

def _norm_type(t: str) -> str:
    """类型归一化：大写、去多余空格、去长度内空格。"""
    t = t.upper().strip()
    t = _TYPE_NORM.sub('', t)  # 去掉所有空格：DECIMAL ( 30 , 8 ) → DECIMAL(30,8)
    return t


def _norm_comment(c: str) -> str:
    c = c.strip()
    if c.startswith("'") and c.endswith("'"):
        c = c[1:-1].replace("''", "'")
    return c


def _split_top_level(s: str) -> List[str]:
    """按顶层逗号分割（忽略引号内、括号内的逗号）。"""
    parts, buf, depth, quote = [], [], 0, None
    for ch in s:
        if quote:
            if ch == quote:
                quote = None
            buf.append(ch)
        elif ch in ("'", '"'):
            quote = ch
            buf.append(ch)
        elif ch == '(':
            depth += 1
            buf.append(ch)
        elif ch == ')':
            depth -= 1
            buf.append(ch)
        elif ch == ',' and depth == 0:
            parts.append(''.join(buf).strip())
            buf = []
        else:
            buf.append(ch)
    if buf:
        parts.append(''.join(buf).strip())
    return parts


# 列定义正则：`name` type [COMMENT '...']
_COL_RE = re.compile(
    r"""^\s*`?(?P<name>[A-Za-z_][A-Za-z0-9_]*)`?"""          # 列名
    r"""\s+(?P<type>[A-Za-z][A-Za-z0-9_]*(?:\s*\([^)]*\))?)"""  # 类型（含括号）
    r"""(?:\s+COMMENT\s+'(?P<cmt>(?:[^']|'')*)')?""",         # 可选注释
    re.VERBOSE | re.IGNORECASE,
)


def _parse_columns(text: str) -> List[Column]:
    cols = []
    for part in _split_top_level(text):
        m = _COL_RE.match(part)
        if not m:
            continue
        cols.append(Column(
            name=m.group('name'),
            type=_norm_type(m.group('type')),
            comment=_norm_comment(m.group('cmt') or ''),
        ))
    return cols


def parse_ddl(ddl_text: str) -> Optional[DDLStruct]:
    """解析单条 CREATE TABLE 语句。返回 DDLStruct 或 None（解析失败）。"""
    # 找 CREATE TABLE ... (
    m = re.search(
        r'CREATE\s+(?:EXTERNAL\s+)?TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?'
        r'(?:`?[A-Za-z0-9_]+`?\.)?`?(?P<table>[A-Za-z0-9_]+)`?\s*\(',
        ddl_text, re.IGNORECASE)
    if not m:
        return None
    table_name = m.group('table')
    start = m.end() - 1  # '(' 的位置

    # 平衡括号找到字段列表结束位置
    depth, quote, i = 0, None, start
    while i < len(ddl_text):
        ch = ddl_text[i]
        if quote:
            if ch == quote:
                if i + 1 < len(ddl_text) and ddl_text[i + 1] == quote:
                    i += 1
                else:
                    quote = None
        elif ch in ("'", '"'):
            quote = ch
        elif ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                body = ddl_text[start + 1:i]
                tail = ddl_text[i + 1:]
                break
        i += 1
    else:
        return None

    # 解析列
    columns = _parse_columns(body)

    # 解析 tail：PARTITIONED BY (...) 和 COMMENT '...'
    partitions = []
    pm = re.search(r'PARTITIONED\s+BY\s*\(([^)]+)\)', tail, re.IGNORECASE | re.DOTALL)
    if pm:
        partitions = _parse_columns(pm.group(1))

    table_comment = ""
    cm = re.search(r'COMMENT\s+\'((?:[^\']|\'\')*)\'', tail, re.IGNORECASE | re.DOTALL)
    if cm:
        table_comment = _norm_comment(cm.group(1))

    return DDLStruct(
        table_name=table_name,
        columns=columns,
        partitions=partitions,
        table_comment=table_comment,
    )


# ──────────────────────────────────────────────────────────────────────────────
# 对比
# ──────────────────────────────────────────────────────────────────────────────

def _cmp_cols(left: List[Column], right: List[Column]) -> DDLDiff:
    """按列名比对两组列（忽略顺序）。"""
    lmap = {c.name: c for c in left}
    rmap = {c.name: c for c in right}
    lnames = set(lmap)
    rnames = set(rmap)

    diff = DDLDiff(table="")
    diff.only_in_left = sorted(lnames - rnames)
    diff.only_in_right = sorted(rnames - lnames)

    for name in sorted(lnames & rnames):
        lc, rc = lmap[name], rmap[name]
        if lc.type != rc.type:
            diff.type_mismatch.append((name, lc.type, rc.type))
        if lc.comment != rc.comment:
            diff.comment_mismatch.append((name, lc.comment, rc.comment))
    return diff


def diff_ddl(left_text: str, right_text: str,
             left_label: str = "甲方", right_label: str = "本地") -> DDLDiff:
    """对比两段 DDL 文本，返回 DDLDiff（table 字段填为右侧表名）。

    ★ 2026-10-27：`left_label` / `right_label` 现在**真正生效**（写入 DDLDiff，
      由 `summary()` 使用）。此前这两个参数只是穿堂过，摘要恒为「甲方/本地」。
    """
    left = parse_ddl(left_text)
    right = parse_ddl(right_text)

    if left is None or right is None:
        d = DDLDiff(table=right.table_name if right else "UNKNOWN",
                    left_label=left_label, right_label=right_label)
        d.only_in_left = ["解析失败"] if left is None else []
        d.only_in_right = ["解析失败"] if right is None else []
        return d

    # 用右侧表名作为 diff 标识
    diff = _cmp_cols(left.columns, right.columns)
    diff.table = right.table_name
    diff.left_label = left_label
    diff.right_label = right_label

    # 分区对比（顺序敏感，转为字符串比对）
    lpart = [(c.name, c.type) for c in left.partitions]
    rpart = [(c.name, c.type) for c in right.partitions]
    if lpart != rpart:
        diff.partition_mismatch = True
        diff.left_partitions = left.partitions
        diff.right_partitions = right.partitions

    # 表注释对比
    if left.table_comment != right.table_comment:
        diff.table_comment_mismatch = (left.table_comment, right.table_comment)

    return diff


# ──────────────────────────────────────────────────────────────────────────────
# 便捷：从文件读取并对比
# ──────────────────────────────────────────────────────────────────────────────

def diff_ddl_files(left_path: str, right_path: str,
                   left_label: str = "甲方", right_label: str = "本地") -> DDLDiff:
    with open(left_path, encoding='utf-8', errors='replace') as f:
        left_text = f.read()
    with open(right_path, encoding='utf-8', errors='replace') as f:
        right_text = f.read()
    return diff_ddl(left_text, right_text, left_label, right_label)