"""按信达词根库把中文字段名译成英文。匹配规则对齐工作簿宏 Find_name。"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import date
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parents[1]
DEFAULT_ROOTS = SKILL_DIR / "data" / "roots.json"
SOURCE_LABEL = "数据仓库模型字段名_宏翻译-信达20230614.xlsm"
OUTER_SPACE = " \t\r\n 　"


@dataclass(frozen=True)
class Root:
    zh: str
    en: str
    old: str
    source: str


@dataclass(frozen=True)
class Segment:
    zh: str
    en: str
    old: str
    source: str
    matched: bool


@dataclass(frozen=True)
class Translation:
    name: str
    segments: tuple[Segment, ...]
    split_zh: str
    en: str
    en_upper: str

    @property
    def has_gap(self) -> bool:
        return any(not segment.matched for segment in self.segments)

    @property
    def old_diffs(self) -> tuple[Segment, ...]:
        return tuple(
            segment
            for segment in self.segments
            if segment.matched and segment.old and segment.old != segment.en
        )


def with_digits(roots: dict[str, Root]) -> dict[str, Root]:
    digits = {
        digit: Root(digit, digit, digit, "附加术语")
        for digit in "0123456789"
        if digit not in roots
    }
    return {**digits, **roots}


def load_roots(path: Path) -> dict[str, Root]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    roots = {
        item["zh"]: Root(item["zh"], item["en"], item.get("old", ""), item.get("source", ""))
        for item in payload["roots"]
        if item.get("zh") and item.get("en")
    }
    return with_digits(roots)


def translate_name(name: str, roots: dict[str, Root]) -> Translation:
    cleaned = name.strip(OUTER_SPACE)
    segments = _segment(cleaned, roots)
    split_zh, en = _join(segments)
    return Translation(cleaned, segments, split_zh, en, en.upper())


def _segment(name: str, roots: dict[str, Root]) -> tuple[Segment, ...]:
    segments: list[Segment] = []
    gap: list[str] = []
    index = 0
    while index < len(name):
        matched = _longest(name, index, roots)
        if matched is None:
            gap.append(name[index])
            index += 1
            continue
        if gap:
            segments.append(_gap("".join(gap)))
            gap = []
        segments.append(matched)
        index += len(matched.zh)
    if gap:
        segments.append(_gap("".join(gap)))
    return tuple(segments)


def _longest(name: str, index: int, roots: dict[str, Root]) -> Segment | None:
    for length in range(len(name) - index, 0, -1):
        text = name[index : index + length]
        root = roots.get(text)
        if root is None:
            continue
        return Segment(root.zh, root.en, root.old, root.source, True)
    return None


def _gap(text: str) -> Segment:
    return Segment(text, "??", "", "", False)


def _join(segments: tuple[Segment, ...]) -> tuple[str, str]:
    zh_parts = [segment.zh if segment.matched else f"?{segment.zh}?" for segment in segments]
    en_parts = [segment.en.lower() if segment.matched else "??" for segment in segments]
    return "_".join(zh_parts), "_".join(en_parts)


def format_table(rows: tuple[Translation, ...]) -> str:
    lines = ["| 中文字段 | 切分 | 英文 | 大写 | 旧词根差异 |", "|---|---|---|---|---|"]
    lines.extend(_table_row(row) for row in rows)
    return "\n".join(lines)


def _table_row(row: Translation) -> str:
    diffs = _diff_text(row) or "—"
    return (
        f"| {_cell(row.name)} | {_cell(row.split_zh)} | `{row.en}` | "
        f"`{row.en_upper}` | {_cell(diffs)} |"
    )


def _diff_text(row: Translation) -> str:
    return "；".join(f"{item.zh}: {item.en}（旧 {item.old}）" for item in row.old_diffs)


def _cell(text: str) -> str:
    return text.replace("|", "\\|")


def extract_roots(xlsm: Path, dest: Path) -> int:
    import openpyxl

    workbook = openpyxl.load_workbook(xlsm, read_only=True, data_only=False)
    try:
        sheet = workbook["SVN术语表"]
        roots = _first_roots(sheet.iter_rows(min_row=2, max_col=4, values_only=True))
    finally:
        workbook.close()
    _write_snapshot(dest, roots)
    return len(roots)


def _write_snapshot(dest: Path, roots: tuple[Root, ...]) -> None:
    payload = {
        "source": SOURCE_LABEL,
        "extracted": date.today().isoformat(),
        "count": len(roots),
        "roots": [
            {"zh": item.zh, "en": item.en, "old": item.old, "source": item.source}
            for item in roots
        ],
    }
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _first_roots(rows) -> tuple[Root, ...]:
    seen: dict[str, Root] = {}
    for zh, en, old, source in rows:
        key = "" if zh is None else str(zh).strip()
        english = "" if en is None else str(en).strip()
        if not key or not english or key in seen:
            continue
        seen[key] = Root(
            key,
            english,
            "" if old is None else str(old).strip(),
            "" if source is None else str(source).strip(),
        )
    return tuple(seen.values())


def _read_names(args: list[str]) -> tuple[str, ...]:
    if args:
        return tuple(name for name in args if name.strip(OUTER_SPACE))
    return tuple(line for line in sys.stdin.read().splitlines() if line.strip(OUTER_SPACE))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="按信达词根库翻译中文字段名")
    parser.add_argument("names", nargs="*", help="中文字段名，多个分开写")
    parser.add_argument("--roots", type=Path, default=DEFAULT_ROOTS)
    parser.add_argument("--json", action="store_true", help="输出 JSON 而不是表")
    parser.add_argument("--old", action="store_true", help="改用旧英文词根")
    parser.add_argument("--extract", type=Path, help="从 xlsm 刷新 data/roots.json")
    parsed = parser.parse_args(argv)
    if parsed.extract:
        count = extract_roots(parsed.extract, parsed.roots)
        print(f"写入 {parsed.roots} ，{count} 条")
        return 0
    names = _read_names(parsed.names)
    if not names:
        print("没有字段名。传入参数，或从标准输入一行一个。", file=sys.stderr)
        return 2
    roots = load_roots(parsed.roots)
    if parsed.old:
        roots = _prefer_old(roots)
    rows = tuple(translate_name(name, roots) for name in names)
    print(_render(rows, as_json=parsed.json))
    return 0


def _prefer_old(roots: dict[str, Root]) -> dict[str, Root]:
    return {
        key: Root(item.zh, item.old, item.en, item.source) if item.old else item
        for key, item in roots.items()
    }


def _render(rows: tuple[Translation, ...], as_json: bool) -> str:
    if as_json:
        return json.dumps([_as_dict(row) for row in rows], ensure_ascii=False, indent=2)
    return format_table(rows)


def _as_dict(row: Translation) -> dict:
    return {
        "name": row.name,
        "split_zh": row.split_zh,
        "en": row.en,
        "en_upper": row.en_upper,
        "has_gap": row.has_gap,
        "old_diffs": [
            {"zh": item.zh, "en": item.en, "old": item.old} for item in row.old_diffs
        ],
    }


if __name__ == "__main__":
    raise SystemExit(main())
