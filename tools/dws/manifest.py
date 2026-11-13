# -*- coding: utf-8 -*-
"""`_DWS搬移清单.json` 的完整性守卫与 source map。

清单是**外部数据**（可能被手工编辑或旧版本残留），其中的 ``group`` / ``name``
会拼进 `scripts/<group>/dws/02_etl/<name>`，因此一律先经 ``_safe_group`` 校验。
"""
import hashlib
import json
import os

from tools.dwd.ns import safe_sysname

from tools.dws import state as st


class StaleDwsManifest(RuntimeError):
    """`_DWS搬移清单.json` 的 sha256/bytes 与现盘不一致。不改清单本身。"""

    def __init__(self, mismatches):
        self.mismatches = list(mismatches)
        super().__init__(
            f"_DWS搬移清单.json 与现盘不一致 {len(self.mismatches)} 条")


def _safe_group(group):
    """清单里的 ``group`` 是外部数据，拼进路径前必须校验。

    ★ 2026-11-10（评审 H2）：`SCRIPTS / group / …` 直接用清单值，等于把
      `..`、`/` 之类交给调用方。`safe_sysname` 已实现这套拒绝规则，
      这里只做「非法 → None」的适配，避免各处重复 try/except。
    ★ 2026-11-10（评审复审）：**先验类型**。`safe_sysname` 内部走 re.match，
      传 int 会抛 TypeError 而不是 ValueError —— 畸形的外部 JSON 会直接崩，
      绕过 StaleDwsManifest 的「可报告」路径。
    """
    if not isinstance(group, str):
        return None
    try:
        return safe_sysname(group or "")
    except ValueError:
        return None


def dws_manifest_mismatches():
    """核对清单里已登记的 sha256/bytes。没有校验字段的条目不查。

    只读。不刷新、不重写 `_DWS搬移清单.json`。
    """
    manifest = st.SCRIPTS / "_DWS搬移清单.json"
    if not manifest.is_file():
        return []
    try:
        data = json.loads(manifest.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [f"清单不是合法 JSON（{type(exc).__name__}: {exc}）"]
    if not isinstance(data, dict):
        return [f"清单顶层不是 JSON 对象（{type(data).__name__}）"]
    bad = []
    for entry in data.get("files") or []:
        if not isinstance(entry, dict):
            bad.append(f"清单条目不是对象（{type(entry).__name__}）")
            continue
        name = entry.get("name")
        if not isinstance(name, str):
            # ★ 2026-11-10（评审复审）：name 非字符串时 `.endswith` 会抛
            #   AttributeError，畸形清单直接崩而非被当作不一致上报。
            bad.append(f"name 不是字符串（{type(name).__name__}）")
            continue
        name = name or "?"
        group = entry.get("group")
        # ★ 放在 sha 校验**之前**：没有校验值的条目同样会被拼进路径，
        #   只查「有 sha 的」等于给未登记项留后门。
        if name.endswith(".sh") and os.path.basename(name) != name:
            bad.append(f"{name}: 文件名含路径分隔，拒绝拼路径")
            continue
        if name.endswith(".sh") and group and _safe_group(group) is None:
            bad.append(f"{name}: group 非法（{group!r}），拒绝拼路径")
            continue
        if "sha256" not in entry and "bytes" not in entry:
            continue
        if not name.endswith(".sh") or not group:
            bad.append(f"{name}: 有校验值但缺 group/文件名，无法核对")
            continue
        path = st.SCRIPTS / _safe_group(group) / "dws" / "02_etl" / name
        if not path.is_file():
            bad.append(f"{name}: 清单有校验值但现盘无此脚本")
            continue
        blob = path.read_bytes()
        if "bytes" in entry and entry["bytes"] != len(blob):
            bad.append(f"{name}: bytes 不符（清单 {entry['bytes']} / 现盘 {len(blob)}）")
            continue
        if "sha256" in entry:
            digest = hashlib.sha256(blob).hexdigest()
            if str(entry["sha256"]).lower() != digest:
                bad.append(f"{name}: sha256 不符")
    return bad


_STALE_MANIFEST_WARNED = False


def _guard_dws_manifest(allow_stale=False):
    """sha/bytes 不符则抛 StaleDwsManifest；显式放行只告警，仍不改清单。"""
    global _STALE_MANIFEST_WARNED
    bad = dws_manifest_mismatches()
    if not bad:
        return
    if allow_stale:
        if not _STALE_MANIFEST_WARNED:
            _STALE_MANIFEST_WARNED = True
            print(f"  ⚠ _DWS搬移清单.json 与现盘不一致 {len(bad)} 条"
                  f"（--allow-stale-dws-manifest：仍用 group，不刷新清单）")
            for line in bad[:8]:
                print(f"    {line}")
            if len(bad) > 8:
                print(f"    … 其余 {len(bad) - 8} 条")
        return
    raise StaleDwsManifest(bad)


def fail_stale(exc):
    """把 StaleDwsManifest 打印成人话并返回退出码 1。"""
    print(f"  ✗ {exc}")
    for line in exc.mismatches[:8]:
        print(f"    {line}")
    if len(exc.mismatches) > 8:
        print(f"    … 其余 {len(exc.mismatches) - 8} 条")
    print("  加 --allow-stale-dws-manifest 可继续（不刷新清单、不覆盖脚本）")
    return 1


def dws_source_map(allow_stale=False):
    """DWS 脚本名（去 .sh）→ 所属系统；清单优先，缺失时回退目录扫描。"""
    _guard_dws_manifest(allow_stale)
    manifest = st.SCRIPTS / "_DWS搬移清单.json"
    if manifest.is_file():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            data = {}
        mapping = {}
        for f in data.get("files") or []:
            if not isinstance(f, dict):
                continue
            name = f.get("name", "")
            group = _safe_group(f.get("group"))
            if isinstance(name, str) and name.endswith(".sh") and group:
                mapping[name[:-3]] = group
        if mapping:
            return mapping
    return {p.stem: s for s in st.SYS for p in (st.SCRIPTS / s / "dws/02_etl").glob("*.sh")}
