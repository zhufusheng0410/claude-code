#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""CI 本地门：已跟踪 `.sh` 全部经 `bash -n` 检查。

口径与 `tools/dws/process.py::shell_syntax` 一致（顺手对齐
`AGENTS.md`「verify 的 bash -n 口径」三条原则）：

1. **先归一 CRLF→LF**：仓库里甲方交付的 DWS 脚本原文是 CRLF，不归一则
   `bash -n` 把行尾 `\r` 当语法错误；
2. **经 stdin 读脚本**（`bash -n -`），stdin 必须传 **bytes**（`text=True` 在
   Windows 会把 `\n` 翻译回 `\r\n`，又变回第一条的问题；二者在
   `tools/dws/process.py` 里有回归用例）；
3. **不拒绝环境拦截的 `skip`**：别的检查通常用失败兜底，这里只关心「真语法错误」。
"""
import subprocess
import sys

REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True, timeout=30).stdout.strip()


def main() -> int:
    out = subprocess.run(["git", "ls-files", "-z", "*.sh"],
                         capture_output=True, cwd=REPO).stdout
    files = [f for f in out.split(b"\0") if f]
    failed, checked = [], 0
    for f in files:
        checked += 1
        with open(REPO + "/" + f.decode("utf-8"), "rb") as fh:
            data = fh.read().replace(b"\r\n", b"\n")
        r = subprocess.run(["bash", "-n", "-"], input=data,
                           capture_output=True, timeout=120)
        if r.returncode != 0:
            failed.append(f.decode("utf-8", "replace"))
            err = r.stderr.decode("utf-8", "replace").strip()
            print(f"  FAIL: {f.decode('utf-8', 'replace')}\n        {err[:200]}")
    print(f"bash -n: 检查 {checked} 个已跟踪 .sh，失败 {len(failed)} 个")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
