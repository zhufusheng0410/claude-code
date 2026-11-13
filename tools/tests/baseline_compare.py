#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""产物基线比对（默认不启用；`DW_BASELINE=1` 才执行）。

为什么需要
    重构（例如拆分 `tools/dw-pipeline.py`）的验收要求「产物与基线一致，
    或每处差异都有说明」。只比文件数看不出内容变化 —— 这里按
    **相对路径 + sha256** 逐文件比对。

用法
    # 1) 重构前存基线（基线不入库，放 gitignore 的目录）
    DW_BASELINE=1 python3 tools/tests/baseline_compare.py \
        --save tools/.dx-tmp/baseline-dws.json scripts/HSFA/dws

    # 2) 重构后比对
    DW_BASELINE=1 python3 tools/tests/baseline_compare.py \
        tools/.dx-tmp/baseline-dws.json scripts/HSFA/dws

约定
    - 基线**不入库**（`tools/.dx-tmp/` 已 gitignore）；项目规则：不记临时结果。
    - 需要甲方交付文档（`/mnt/d`）的比对只能在本机跑；CI 无该挂载，只跑合成夹具。
    - 退出码：0 = 一致；1 = 有差异；2 = 未启用（未设 `DW_BASELINE=1`）。
"""
from __future__ import annotations

import hashlib
import json
import os
import sys
from pathlib import Path

#: 不参与比对的内容（缓存、版本库、临时产物、归档）。
SKIP_DIRS = {".git", "__pycache__", ".dx-tmp", ".archive", ".venv"}


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def snapshot(root: Path) -> dict:
    """把目录树拍成 ``{相对路径(POSIX): sha256}``；跳过 :data:`SKIP_DIRS`。"""
    root = Path(root)
    out = {}
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        for name in sorted(filenames):
            p = Path(dirpath) / name
            out[p.relative_to(root).as_posix()] = _sha256(p)
    return out


def compare(old: dict, new: dict) -> dict:
    """比较两份快照，返回 ``{added, removed, changed}``（均已排序）。"""
    old_keys, new_keys = set(old), set(new)
    return {
        "added": sorted(new_keys - old_keys),
        "removed": sorted(old_keys - new_keys),
        "changed": sorted(k for k in old_keys & new_keys if old[k] != new[k]),
    }


def is_empty(diff: dict) -> bool:
    return not any(diff.values())


def _load(path: Path) -> dict:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def _save(path: Path, data: dict) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=0, sort_keys=True),
                    encoding="utf-8")


def main(argv=None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if not os.environ.get("DW_BASELINE"):
        print("未设置 DW_BASELINE=1，跳过产物比对（这是默认行为）")
        return 2
    if not argv:
        print(__doc__)
        return 2

    if argv[0] == "--save":
        if len(argv) != 3:
            print("用法: --save <基线文件> <产物目录>", file=sys.stderr)
            return 2
        baseline_path, root = Path(argv[1]), Path(argv[2])
        data = snapshot(root)
        _save(baseline_path, data)
        print(f"已存基线 {len(data)} 个文件 -> {baseline_path}")
        return 0

    if len(argv) != 2:
        print("用法: <基线文件> <产物目录>", file=sys.stderr)
        return 2
    baseline_path, root = Path(argv[0]), Path(argv[1])
    if not baseline_path.is_file():
        print(f"基线文件不存在: {baseline_path}", file=sys.stderr)
        return 2
    diff = compare(_load(baseline_path), snapshot(root))
    if is_empty(diff):
        print(f"一致：{root}")
        return 0
    for kind in ("added", "removed", "changed"):
        if diff[kind]:
            print(f"{kind} ({len(diff[kind])}):")
            for name in diff[kind][:50]:
                print(f"  {name}")
            if len(diff[kind]) > 50:
                print(f"  … 其余 {len(diff[kind]) - 50} 个")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
