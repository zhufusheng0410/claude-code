#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""★ 把**全部 DWD 作业按主题**落进 DolphinScheduler（11 个工作流 / 103 张表）。

做的事
------
1. 读 `tools/dep-config-lineage/`（来自 `dwd/lineage`，**映射表已排除**）
2. 按 `own_workflow`（`DWD_<主题>`）分组 ⇒ 每个主题一个工作流
3. **先把所有 DWD_* 工作流删干净**，再**按拓扑序**重建

★★★ 为什么必须「先全删、再按拓扑序建」
--------------------------------------
- DS **拒绝删除被别的 DEPENDENT 引用的工作流**（`10000 used by other tasks`）。
  `DWD_PROD` 依赖 `DWD_CHNL` ⇒ 不先删 `DWD_PROD` 就删不掉 `DWD_CHNL`。
  逐个删会撞上互相引用 ⇒ **一次性全删**最省事。
- 反过来，**创建**时必须上游先存在（要拿它的 `definitionCode` 写进 dep 节点）
  ⇒ 按「工作流之间的依赖图」拓扑序建。
- ★ 2026-10-15 晚：跨工作流依赖回归**作业级**（DEPENDENT_ON_TASK 指到上游
  工作流里的具体作业，dateValue=today；gate_ods_fresh 门禁已删除）⇒
  工作流之间**重新互相引用** ⇒「先全删 + 按拓扑序建」从纯保险升级为**必需**。

用法
----
    python tools/ds-deploy-all-dwd.py --dry-run     # 只打印计划
    python tools/ds-deploy-all-dwd.py               # 真跑（删光 + 按拓扑序重建）
    python tools/ds-deploy-all-dwd.py --delete-only # ★ 只删光 DWD_*，不重建
"""
import argparse
import collections
import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_config import ds_admin_password, ds_admin_user  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name):
    """按**文件路径**导入（文件名带连字符 ⇒ 不能 `import ds-deploy-...`）。"""
    import importlib.util
    spec = importlib.util.spec_from_file_location(name, os.path.join(HERE, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


D = _load("ds-deploy-dwd-workflow")             # 复用它的 neutralize_selfdeps
# ★★★ 2026-10-26：`dep-config-*` 已从 `D:\datax\tools` **迁入本目录**（仓库内自包含）。
#   历史：2026-10-10 曾因「生产方 `ds-build-dependent-from-lineage.py` 的 OUT 与
#   本文件的 DEPCFG 不一致」而改成指向仓库外 `D:\datax\tools\dep-config-lineage`，
#   导致部署报「缺 …/dep-config-lineage」跑不起来。现在生产方与消费方都统一到
#   `tools/ds-deploy/dep-config-*`，用 `D.DEPCFG` 单一来源，仍支持 `DW_DEPCFG` 覆盖。
DEPCFG = os.environ.get("DW_DEPCFG", D.DEPCFG)
DEPCFG_DWS = os.environ.get("DW_DEPCFG_DWS", D.DEPCFG_DWS)
DEPLOY = os.path.join(HERE, "ds-deploy-dwd-workflow.py")
PY = sys.executable
LAYER = "DWD"

DS = "http://localhost:12345/dolphinscheduler"
USER = ds_admin_user()
PWD = ds_admin_password()
PROJECT = "dw"
SID = None


def raw(method, path, params=None, form=None, _auth=True, _cookie=True):
    url = DS + path + ("?" + urllib.parse.urlencode(params) if params else "")
    h = {"Accept": "application/json"}
    # ★★★ 2026-10-11 根因修复：登录请求【绝不能带 Cookie】。
    #   原实现无条件 `if SID: h["Cookie"]=...`，连 POST /login 也带上一个**已失效**的
    #   sessionId ⇒ DS 直接回 401，而 login() 是 _auth=False（不重试）⇒ `raise` 崩进程。
    #   实测：删 DWD 到第 6 个（DWD_PTY）时正是这样挂掉的，只删掉 5 个。
    #   首次登录之所以没事，纯粹是当时 SID 还是 None（没 Cookie 可带）。
    if SID and _cookie:
        h["Cookie"] = "sessionId=" + SID
    data = None
    if form is not None:
        data = urllib.parse.urlencode(form, doseq=True).encode()
        h["Content-Type"] = "application/x-www-form-urlencoded"
    try:
        with urllib.request.urlopen(urllib.request.Request(url, data=data, headers=h,
                                                           method=method), timeout=180) as r:
            b = r.read().decode("utf-8", "replace")
            return json.loads(b) if b else {}
    except urllib.error.HTTPError as e:
        # ★★★ 2026-10-10：补 401 重登。本工具原先只在 main() 开头 login 一次，
        #   而创建 11 个工作流耗时较长，中途会话失效就直接抛 401 崩掉
        #   （实测：`[2] 按拓扑序创建` 到 (1/11) 时挂掉，白跑一遍）。
        #   ⇒ 与 ds_client.py 保持一致：401 时重新登录并重试一次。
        if e.code == 401 and _auth:
            sys.stderr.write("[ds-deploy-all-dwd] 会话失效(401) %s %s → 重新登录并重试\n"
                             % (method, path))
            login()
            return raw(method, path, params, form, _auth=False)
        raise


def login():
    """登录并刷新全局 SID。★ 自身不重试（_auth=False），避免 401 时无限递归。
    ★ 且**不带 Cookie**（_cookie=False）：旧 SID 失效后若还带着它去 /login，
      DS 直接 401 ⇒ 这里又不重试 ⇒ 进程当场崩（2026-10-11 实测根因）。"""
    global SID
    r = raw("POST", "/login", form={"userName": USER, "userPassword": PWD},
            _auth=False, _cookie=False)
    if r.get("code") != 0:
        sys.exit("登录失败")
    SID = r["data"]["sessionId"]
    return SID


def lst_of(res):
    d = res.get("data")
    return d.get("totalList") if isinstance(d, dict) else (d or [])


def load_groups():
    groups = collections.defaultdict(list)
    wf_deps = collections.defaultdict(set)          # 工作流 → 它依赖的其它同层工作流
    prefixes = ("DWD_", "MASTER_") if LAYER == "DWD" else ("DWS_",)
    for f in sorted(os.listdir(DEPCFG)):
        if not f.endswith(".dep.json"):
            continue
        c = json.load(open(os.path.join(DEPCFG, f), encoding="utf-8"))
        wf = c["own_workflow"]
        if wf == "(未知)":
            continue
        groups[wf].append(c["target"])
        for g in c.get("cross_workflow", []):
            if g["workflow"].startswith(prefixes) and g["workflow"] != wf:
                wf_deps[wf].add(g["workflow"])
    return groups, wf_deps


def topo_order(groups, wf_deps):
    """Kahn：上游工作流排在前面。有环就按剩余顺序兜底（不至于死循环）。"""
    indeg = {w: len({x for x in wf_deps.get(w, ()) if x in groups}) for w in groups}
    q = sorted(w for w, d in indeg.items() if d == 0)
    out = []
    while q:
        w = q.pop(0)
        out.append(w)
        for v in sorted(groups):
            if w in wf_deps.get(v, ()):
                indeg[v] -= 1
                if indeg[v] == 0:
                    q.append(v)
        q.sort()
    for w in sorted(groups):
        if w not in out:
            out.append(w)                            # 环 ⇒ 兜底
    return out


def main():
    # ★★★ 2026-10-14 修复潜伏 bug：main() 内 `SID = D.SID`（取回 D 模块 401 重登后的
    #   新会话）使 SID 成为 main() **局部变量** ⇒ 删除循环里 `D.SID = SID`（赋值前读取）
    #   直接 UnboundLocalError。以前从未暴露是因为首次部署前 DS 里 DWD_* 就是 0 个、
    #   删除循环空转；一旦要删已有工作流（重建场景）必崩。
    global SID, DEPCFG, LAYER
    ap = argparse.ArgumentParser()
    ap.add_argument("--layer", choices=["DWD", "DWS"], default="DWD")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--only", default="", help="只部署这几个工作流（逗号分隔，调试用）")
    # ★ 2026-10-11：只删不建。删完②就返回，不进入③重建。
    ap.add_argument("--delete-only", action="store_true",
                    help="只删光 DS 里所有同层工作流，不重建（删完回读复核）")
    # ★ 2026-10-14（用户要求）：执行期失败的表也配空脚本（依赖边保留，DAG 完整）。
    #   单工作流工具默认已含 5 张指定排除表，这里追加运行期失败表。
    ap.add_argument("--empty-tables", default="",
                    help="追加配空脚本的表（逗号分隔；与默认 5 张排除表取并集）")
    args = ap.parse_args()
    LAYER = args.layer
    if LAYER == "DWS":
        DEPCFG = DEPCFG_DWS
    PREFIXES = ("DWD_", "MASTER_") if LAYER == "DWD" else ("DWS_",)

    if not os.path.isdir(DEPCFG):
        sys.exit(f"缺 {DEPCFG} ⇒ 先跑 python tools/ds-build-dependent-from-lineage.py"
                 if LAYER == "DWD" else
                 f"缺 {DEPCFG} ⇒ 先跑 python tools/ds-deploy/ds-build-dws-dependent-from-lineage.py")

    groups, wf_deps = load_groups()
    order = topo_order(groups, wf_deps)
    if args.only:
        want = {x.strip() for x in args.only.split(",") if x.strip()}
        order = [w for w in order if w in want]

    print(f"主题工作流 {len(order)} 个（共 {sum(len(v) for v in groups.values())} 张表）")
    for w in order:
        dep = sorted(x for x in wf_deps.get(w, ()) if x in groups)
        print(f"   {w:12s} {len(groups[w]):3d} 张表"
              + (f"   依赖上游工作流 {dep}" if dep else ""))

    if args.dry_run:
        print("\n拓扑序（创建顺序）:")
        for i, w in enumerate(order, 1):
            print(f"   {i:2d}. {w}")
        print("\n--- dry-run，不动 DS ---")
        return 0

    login()
    projs = raw("GET", "/projects/list", params={"pageSize": 100, "pageNo": 1}).get("data")
    projs = projs if isinstance(projs, list) else (projs or {}).get("totalList", [])
    pcode = next((p["code"] for p in projs if p["name"] == PROJECT), None)
    print(f"\n项目 {PROJECT} code={pcode}")

    # ---------- ① 跑批必须为 0 ----------
    insts = lst_of(raw("GET", f"/projects/{pcode}/workflow-instances",
                       params={"pageNo": 1, "pageSize": 200}))
    # ★★★ 2026-10-10 修正：原来只认 6/7（FAILURE/SUCCESS）为「已结束」，
    #   把**手工停止**(5 STOP) 和 **KILL**(8) 也算成在跑 ⇒ 只要有人取消过一次跑批，
    #   本工具就永远拒绝启动（实测被 `DWD_SCR-20261010155747620` state=5 挡住）。
    #   ⇒ 补上 5/8；真正的判据是 **end_time 为空**（未写结束时间 = 还在跑）。
    DONE = (5, 6, 7, 8, "STOP", "FAILURE", "SUCCESS", "KILL")
    busy = [i for i in insts if i.get("state") not in DONE and i.get("end_time") is None]
    # ★ 2026-10-26：原先是「任何实例在跑就拒」，但 ODS 抽数跑几个小时是常态，
    #   这时重建 DWD/DWS 工作流本身是安全的（删的是本层定义，ODS 实例在别的工作流里）。
    #   ⇒ 只拦**本层**未结束实例；其他层在跑只告警。
    mine = [i for i in busy if str(i.get("name", "")).startswith(PREFIXES)]
    if mine:
        sys.exit(f"★ 本层有 {len(mine)} 个未结束的实例，先等跑完再动："
                 f"{[i.get('name') for i in mine][:3]}")
    if busy:
        print(f"[0] ⚠ 其他层有 {len(busy)} 个实例在跑（如 {busy[0].get('name')}），"
              f"不挡本层重建")
    stopped = [i for i in insts if i.get("state") in (5, 8, "STOP", "KILL")]
    print(f"[0] 跑批实例 {len(insts)} 个，本层未结束 {len(mine)}"
          + (f"（另有 {len(stopped)} 个已停止/KILL，视为结束）" if stopped else "") + " ✓")

    # ---------- ② 一次性删光所有同层工作流 ----------
    existing = {x["name"]: x["code"] for x in lst_of(
        raw("GET", f"/projects/{pcode}/workflow-definition",
            params={"pageNo": 1, "pageSize": 500})) if x["name"].startswith(PREFIXES)}
    print(f"\n[1] 现有 {LAYER}_* 工作流 {len(existing)} 个，全部删除（释放互相的 DEPENDENT 引用）")
    # ★★★ 必须按**逆拓扑序**删（下游先删）：DS 拒绝删除被 DEPENDENT 引用的工作流，
    #   按字母序会先撞上 DWD_CHNL（它被 DWD_PROD 引用着）。
    # ★ 2026-10-11：DS 里可能有本地 dep-config **不认识**的 DWD_*（例如手工/别工具部署的），
    #   只按 `reversed(order)` 遍历会**漏删** ⇒ 补上「order 里没有的，按名字逆序」兜底。
    order_set = set(order)
    del_order = [w for w in reversed(order) if w in existing]
    del_order += sorted((n for n in existing if n not in order_set), reverse=True)
    only = {x.strip() for x in args.only.split(",") if x.strip()}
    # ★★★ 2026-10-15 预中和：逆拓扑序删除只对**新配置**成立；旧部署的跨流残留
    #   引用方向可能不同（实测：旧态 DWD_PTY_OPER_FUND_PRVL_PFD 挂在 DWD_PROD 下、
    #   DWD_PTY 的 dep 节点反向引用它 ⇒ 按新拓扑先删 PROD 时被 PTY 残留项挡死）。
    #   反正被删的工作流全部重建 ⇒ DELETE 前先把它们的全部 DEPENDENT 项清空。
    for w in del_order:
        if only and w not in only:
            continue
        login()
        D.SID = SID
        n = D.neutralize_selfdeps(pcode, existing[w], mode="all")
        if n:
            print(f"      预中和 {w} 的 {n} 条依赖项（跨流残留防挡删，2026-10-15）")
            SID = D.SID
    for w in del_order:
        c = existing[w]
        if only and w not in only:
            print(f"      {w} 不在 --only 范围，跳过删除")
            continue
        # ★★★ 2026-10-11 根因修复②：**每轮换一个新会话**。
        #   DS 的 t_ds_session 对【同一用户】只保留 1 条 —— 本脚本与
        #   ds-deploy-dwd-workflow.py 各自持有 SID、又各自在 401 时重登，
        #   于是互相把对方的会话顶掉（实测：中和 DWD_PTY 的 7 条自引用后，
        #   主脚本的 DELETE 立刻 401）。⇒ 每轮开头重新登录，并把新 SID 同步给 D。
        login()
        D.SID = SID
        raw("POST", f"/projects/{pcode}/workflow-definition/{c}/release",
            form={"releaseState": "OFFLINE"})
        # ★★★ 自引用依赖（dep 节点里 DEPENDENT_ON_TASK 指向自己）会挡住 DELETE
        #   ⇒ 先借单工作流工具里的 `neutralize_selfdeps` 中和掉
        n = D.neutralize_selfdeps(pcode, c)
        if n:
            print(f"      中和 {w} 的 {n} 条自引用依赖（否则删不掉）")
            # D 模块内部若因 401 重登过，SID 已变 ⇒ 取回来，否则下面的 DELETE 还是 401
            SID = D.SID
        rr = raw("DELETE", f"/projects/{pcode}/workflow-definition/{c}")
        if rr.get("code") != 0:
            sys.exit(f"      ❌ 删 {w} 失败: {json.dumps(rr, ensure_ascii=False)[:300]}")
        print(f"      {w} 已删")

    # ---------- 只删不建：到此为止，回读复核 ----------
    if args.delete_only:
        final = {x["name"]: x for x in lst_of(
            raw("GET", f"/projects/{pcode}/workflow-definition",
                params={"pageNo": 1, "pageSize": 500})) if x["name"].startswith(PREFIXES)}
        print(f"\n[delete-only] {LAYER}_* 工作流残留 {len(final)} 个"
              + (f"：{sorted(final)}" if final else " ✓ 全部删净"))
        return 0

    # ---------- ③ 按拓扑序逐个建 ----------
    print(f"\n[2] 按拓扑序创建 {len(order)} 个工作流")
    codes = {}
    for i, w in enumerate(order, 1):
        print(f"\n----- ({i}/{len(order)}) {w} -----")
        cmd = [PY, DEPLOY, "--layer", LAYER, "--workflow", w]
        if args.empty_tables.strip():
            cmd += ["--empty-tables", args.empty_tables.strip()]
        p = subprocess.run(cmd, capture_output=True, timeout=900)
        so = p.stdout.decode("utf-8", errors="replace")
        se = p.stderr.decode("utf-8", errors="replace")
        print(so.strip())
        if p.returncode != 0:
            print(se.strip()[:1500])
            sys.exit(f"❌ 部署 {w} 失败（rc={p.returncode}）")
        codes[w] = True

    # ---------- ④ 复核 ----------
    print("\n[3] 复核")
    final = {x["name"]: x for x in lst_of(
        raw("GET", f"/projects/{pcode}/workflow-definition",
            params={"pageNo": 1, "pageSize": 500})) if x["name"].startswith(PREFIXES)}
    for w in order:
        x = final.get(w)
        print(f"   {w:12s} {'ONLINE' if x and x.get('releaseState') == 'ONLINE' else '缺失/未上线'}")
    print(f"\n{LAYER}_* 工作流合计 {len(final)} 个")
    return 0


if __name__ == "__main__":
    sys.exit(main())
