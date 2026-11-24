#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/.dx-tmp 运行产物保留与清理工具（默认 dry-run，加 --apply 才删除）。

规则
----
- 保护清单（默认永不删除）：``ds-sessions``、``ds-recovery``、``dwd_owner_map.json``。
- 保留策略（两者取并集）：
  1. ``--max-age-days N``（默认 90）：修改时间早于 N 天的顶层条目进入待清理列表；
  2. ``--max-items M``（默认 200）：非保护顶层条目数超过 M 时，按最旧优先裁掉超出部分。
- 仅操作目标目录内的直接子项，不跟随符号链接越界删除。

用法
----
    python3 tools/cleanup_tmp.py                           # dry-run，只列出待清理项
    python3 tools/cleanup_tmp.py --max-age-days 30         # 预览 30 天前的旧产物
    python3 tools/cleanup_tmp.py --max-age-days 90 --apply # 真正清理
"""
import argparse
import os
import shutil
import sys
import time
from pathlib import Path
from typing import Iterable, List, Optional, Sequence, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_TMP_DIR = REPO_ROOT / "tools" / ".dx-tmp"

# 运行期必需或用于灾备恢复的条目，清理工具默认跳过。
PROTECTED_NAMES = frozenset({
    "backup",
    "ds-sessions",
    "ds-recovery",
    "dwd_owner_map.json",
})


def _entry_mtime(path: Path) -> float:
    """返回条目自身最后修改时间（不跟随符号链接）。"""
    return path.lstat().st_mtime


def _entry_size(path: Path) -> int:
    """估算条目占用字节数（仅用于报告，不跟随符号链接）。"""
    try:
        st = path.lstat()
    except OSError:
        return 0
    if path.is_symlink() or not path.is_dir():
        return st.st_size
    total = 0
    for root, _dirs, files in os.walk(path, followlinks=False):
        for fn in files:
            fp = os.path.join(root, fn)
            try:
                total += os.lstat(fp).st_size
            except OSError:
                continue
    return total


def select_candidates(
    root: Path,
    *,
    max_age_days: int = 90,
    max_items: int = 200,
    now: Optional[float] = None,
    protected: Iterable[str] = PROTECTED_NAMES,
) -> Tuple[List[Path], List[Path]]:
    """按保留策略筛选待清理条目。

    返回 ``(candidates, skipped_protected)``，均按路径稳定排序。
    """
    if max_age_days < 0:
        raise ValueError("max_age_days 不能为负数")
    if max_items < 0:
        raise ValueError("max_items 不能为负数")

    root_path = Path(root)
    if not root_path.is_dir():
        return [], []

    now_ts = time.time() if now is None else float(now)
    cutoff = now_ts - max_age_days * 86400
    protected_set = set(protected)

    protected_found: List[Path] = []
    regular: List[Tuple[float, Path]] = []

    for child in sorted(root_path.iterdir(), key=lambda p: p.name):
        if child.name in protected_set:
            protected_found.append(child)
            continue
        try:
            mtime = _entry_mtime(child)
        except OSError:
            continue
        regular.append((mtime, child))

    # 规则 1：超过保留天数
    to_remove = {p for mtime, p in regular if mtime < cutoff}

    # 规则 2：超出最大条数（按最旧优先）
    remaining = [(m, p) for m, p in regular if p not in to_remove]
    if len(remaining) > max_items:
        remaining.sort(key=lambda item: (item[0], item[1].name))
        overflow = len(remaining) - max_items
        for _m, p in remaining[:overflow]:
            to_remove.add(p)

    return sorted(to_remove, key=lambda p: p.name), protected_found


def cleanup_tmp(
    root: Path = DEFAULT_TMP_DIR,
    *,
    max_age_days: int = 90,
    max_items: int = 200,
    apply: bool = False,
    now: Optional[float] = None,
) -> dict:
    """执行（或预览）清理，返回统计摘要字典。"""
    root_path = Path(root).resolve()
    candidates, protected_found = select_candidates(
        root_path,
        max_age_days=max_age_days,
        max_items=max_items,
        now=now,
    )

    removed: List[str] = []
    failed: List[Tuple[str, str]] = []
    reclaimed_bytes = 0

    for item in candidates:
        # 严格校验条目确实位于 root_path 之内
        if item.parent.resolve() != root_path:
            failed.append((item.name, "越界路径，拒绝删除"))
            continue
        size = _entry_size(item)
        if not apply:
            reclaimed_bytes += size
            continue
        try:
            if item.is_symlink() or not item.is_dir():
                item.unlink()
            else:
                shutil.rmtree(item)
            removed.append(item.name)
            reclaimed_bytes += size
        except OSError as e:
            failed.append((item.name, str(e)))

    return {
        "root": str(root_path),
        "apply": apply,
        "candidates": [p.name for p in candidates],
        "protected": [p.name for p in protected_found],
        "removed": removed,
        "failed": failed,
        "reclaimed_bytes": reclaimed_bytes,
    }


def _fmt_bytes(n: int) -> str:
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return f"{n:.1f} {unit}" if unit != "B" else f"{n} B"
        n /= 1024.0
    return f"{n} B"


def build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(
        description="清理 tools/.dx-tmp 下的过期运行产物（默认 dry-run，加 --apply 才删除）"
    )
    ap.add_argument(
        "--root",
        default=str(DEFAULT_TMP_DIR),
        help="目标临时目录（默认 tools/.dx-tmp）",
    )
    ap.add_argument(
        "--max-age-days",
        type=int,
        default=90,
        help="保留天数，超过则纳入清理（默认 90）",
    )
    ap.add_argument(
        "--max-items",
        type=int,
        default=200,
        help="非保护条目最大保留个数，超出按最旧优先清理（默认 200）",
    )
    ap.add_argument(
        "--apply",
        action="store_true",
        help="真正执行删除（不加则仅预览）",
    )
    return ap


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    summary = cleanup_tmp(
        Path(args.root),
        max_age_days=args.max_age_days,
        max_items=args.max_items,
        apply=args.apply,
    )
    mode = "APPLY" if args.apply else "DRY-RUN"
    print(f"[{mode}] 目录: {summary['root']}")
    print(f"  保护跳过 ({len(summary['protected'])}): {', '.join(summary['protected']) or '无'}")
    print(
        f"  待清理 ({len(summary['candidates'])})，预计释放 {_fmt_bytes(summary['reclaimed_bytes'])}"
    )
    for name in summary["candidates"]:
        mark = "已删" if args.apply and name in summary["removed"] else "拟删"
        print(f"    - [{mark}] {name}")
    if summary["failed"]:
        for name, err in summary["failed"]:
            print(f"    ✗ 失败 {name}: {err}", file=sys.stderr)
        return 1
    if not args.apply and summary["candidates"]:
        print("（当前为 dry-run，未删除任何文件；确认无误后加 --apply 执行）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
