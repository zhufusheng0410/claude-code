# -*- coding: utf-8 -*-
"""子进程与文件同步原语（DWS 管线共用）。

★ 所有路径一律通过 ``st.REPO`` / ``st.SCRIPTS`` **调用时**取值，
  不要 `from tools.dws.state import SCRIPTS` —— 那是快照，测试改路径后会失效。
"""
import shutil
import subprocess
import time
from pathlib import Path

from tools.dws import state as st


def run(cmd, capture=False):
    """跑子进程；返回 (returncode, 输出)。

    ★ 捕获输出时固定 UTF-8 + errors=replace：Windows 下子进程的中文日志按
      locale（cp936）解码会抛 UnicodeDecodeError —— 与 `shell_syntax` 里
      已经修过的是同一类坑，只是主执行路径原先没跟上（本机 UTF-8 侥幸不炸）。
    ★ 统一超时（`DW_RUN_TIMEOUT`，默认 1800s）：DS API 挂住时不留无限等待；
      超时按失败返回 124，不抛异常，调用方统一走 rc 判定。
    """
    cmd = [str(x) for x in cmd]
    print("$", " ".join(cmd), flush=True)
    timeout = st.RUN_TIMEOUT
    try:
        if capture:
            p = subprocess.run(cmd, cwd=str(st.REPO), text=True, capture_output=True,
                               encoding="utf-8", errors="replace", timeout=timeout)
            out = (p.stdout or "") + (p.stderr or "")
            print(out, flush=True)
            return p.returncode, out
        p = subprocess.run(cmd, cwd=str(st.REPO), timeout=timeout)
        return p.returncode, ""
    except subprocess.TimeoutExpired:
        print(f"  ✗ 超时（{timeout}s）已中止：{' '.join(cmd[:3])} …", flush=True)
        return 124, ""


def backup_dir(src: Path):
    """把 ``src`` 下的 ``*.sh`` 备份到 ``tools/.dx-tmp/``；目录空则返回 None。"""
    src = Path(src)
    if not src.is_dir() or not any(src.glob("*.sh")):
        return None
    ts = time.strftime("%Y%m%d-%H%M%S")
    base = f"backup-{src.parent.parent.name}-{src.name}-{ts}"
    dst = st.REPO / "tools/.dx-tmp" / base
    n = 0
    while dst.exists():
        n += 1
        dst = st.REPO / "tools/.dx-tmp" / f"{base}-{n}"
    shutil.copytree(src, dst)
    print(f"  备份 {src} -> {dst}")
    return dst


def sync_files(src: Path, dst: Path, apply: bool, pattern="*.sh", prune=False,
               backup=False, label=""):
    """把 ``src`` 下匹配 ``pattern`` 的文件同步到 ``dst``；``apply=False`` 只统计。"""
    src, dst = Path(src), Path(dst)
    if not src.is_dir():
        print(f"  {src} 不存在，跳过")
        return 0
    srcs = {p.name: p for p in sorted(src.glob(pattern)) if p.is_file()}
    if not srcs:
        print(f"  {src} 无 {pattern}，跳过")
        return 0
    dsts = {p.name: p for p in dst.glob(pattern)} if dst.is_dir() else {}
    add = sorted(set(srcs) - set(dsts))
    upd = sorted(n for n in set(srcs) & set(dsts)
                 if srcs[n].read_bytes() != dsts[n].read_bytes())
    stale = sorted(set(dsts) - set(srcs)) if prune else []
    print(f"  {label or src}: 新增 {len(add)} / 更新 {len(upd)} / 删除 {len(stale)}")
    if apply:
        if backup and (add or upd or stale):
            backup_dir(dst)
        dst.mkdir(parents=True, exist_ok=True)
        for n in add + upd:
            shutil.copy2(srcs[n], dst / n)
        for n in stale:
            (dst / n).unlink()
    return len(srcs)


def gen_temp(prefix):
    """`scripts/.<prefix>-<时间戳>` 临时目录（生成器产物先落这里，再同步）。"""
    ts = time.strftime("%Y%m%d-%H%M%S")
    p = st.SCRIPTS / f".{prefix}-{ts}"
    print(f"生成临时目录: {p}")
    return p


def shell_syntax(p, text=None):
    """`bash -n` 语法检查：'ok' / 'bad' / 'skip'（skip = 环境拦住 bash，无法判定）。

    ``text`` 可传入**已读到的脚本文本**，避免调用方为别的检查再读一次盘。

    ★ 四个坑（全部实测过，别退回单一写法）：
      ① 沙箱/安全策略拦住 bash 启动时，stderr 是 UTF-16LE 的「拒绝访问」（含 \\x00），
         这不是脚本语法问题 ⇒ 记为跳过，不算失败；
      ② 甲方交付的 DWS .sh **24/24 都是 CRLF**，bash 会把行尾 `\\r` 当语法错误
         （`unexpected token $'\\r'`）⇒ 先归一化到 LF，本地结论才与实跑一致
         （DS 侧 rawScript 也是 `\\r\\n`→`\\n` 后执行的）。不要改仓库 .sh 本身：
         口径要求与甲方逐字节一致；
      ③ 不能用文件路径：**cygwin 版 bash 由 Windows 原生进程启动时会把 `C:\\a\\b`
         里的反斜杠吃掉**（实测 rc=127 `C:Users…: No such file`）⇒ 24 个脚本全被判
         "语法失败"。故改为 `bash -n -` 从 stdin 读脚本；
      ④ stdin 必须传 **bytes**：`text=True` 在 Windows 会把 `\\n` 反向翻译成 `\\r\\n`，
         CRLF 又回来了、照样 `$'\\r'` 报错（这个坑最隐蔽）。
    """
    if text is None:
        try:
            text = st.ds_deploy()[1].read_script(p)
        except OSError:
            return "skip"
    try:
        r = subprocess.run(["bash", "-n", "-"], input=text.encode("utf-8"),
                           capture_output=True, timeout=60)
    except (OSError, subprocess.SubprocessError):
        return "skip"
    if r.returncode == 0:
        return "ok"
    err = (r.stderr or b"").decode("utf-8", "replace")
    return "skip" if ("\x00" in err or "拒绝" in err) else "bad"
