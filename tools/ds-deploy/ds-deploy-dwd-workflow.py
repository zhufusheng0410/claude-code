#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把一个 DWD 工作流的**全部依赖**落进 DolphinScheduler，并做「零交叉」布局。

★ 本工具处理**整个工作流**（如 DWD_PROD 的 18 张表），是 DWD 落地的**现役唯一入口**。
  历史上曾有一个只处理**单表**的 `ds-deploy-dwd-dependent.py`，其能力已被本工具完全覆盖并
  于 2026-10-15 退役（备份 `backup/retired-20261015-T2/`）；单表增量加表请用 `ds-add-dwd-table.py`。

★ 依赖节点粒度：**每张表一个** DEPENDENT 节点，节点内含该表**完整的** dependItemList。
   （「每个上游工作流一个节点」在依赖密集时会产生大量跨列长边，实测交叉 79 条。）

★★★ 零交叉布局的三个关键
------------------------
1. **依赖节点放在表的正上方**（同列、上一格）⇒ dep→表 的边是**竖线**。
   竖线只占 `x = 表所在列` 这一条线，而「同工作流边」都是**跨 1 列的斜线**
   （见第 3 点），斜线只在**端点**碰到该 x ⇒ 竖线与斜线**零相交**。
   （放左一列做水平边会被跨行斜线大量横穿，实测 15 条，压不下去。）
2. 行序是唯一的自由变量。对**真实交叉数**做「爬山 + 随机重启」（固定种子，可复现）。
3. **传递归约**：去掉冗余的跨层长边 —— `NUM_MAPP → ROLE_INFO` 可以通过
   `BASIC_INFO` 间接到，直接连会形成跨 2 列的斜线，横穿中间所有边
   （实测交叉数从 0 飙到 123）。归约后所有边的层差都等于 1。
   另：甲方依赖表里有 2-环（`BASIC_INFO ↔ NUM_MAPP`）会让 DS 报
   `50019 workflow node has cycle`，需先打断。

★★★ 部署顺序（踩过的坑）
------------------------
必须先**删本工作流**释放它对上游的 DEPENDENT 引用，再重建上游工作流。
否则 DS 会拒绝删除被引用的工作流：
`10000 ... used by other tasks: <wf>:dep_on_xxx`。

# ★★★ 跨工作流依赖（2026-10-15 晚修正：回归【作业级】）
# -----------------------------------------------------------------
# 口径变迁（四次反复，教训记录在这里）：
#   ① 10-05/06 起：依赖一律【作业级】——每个 dep 节点里的跨工作流项
#      DEPENDENT_ON_TASK 直接指到上游 ods_* 工作流里的**具体 ODS 作业**
#      （`ds-convert-deps-task-level.py` 同款），`dateValue=today`。
#      README 记载的既定口径，实测可用。
#   ② 10-14 用户要求放宽成「上游最近 N 天成功过一次」⇒ 改
#      DEPENDENT_ON_WORKFLOW + `dateValue="last N days"` ⇒ **全线秒败**
#      （枚举白名单只认 25 个无空格驼峰值；且 `last N days` 语义是
#      「窗口内每天都要有成功实例」，任一空 → WAITING 永久轮询；
#      `"last 3 days"`/`"last 30 days"`/`"last 5 days"` 三轮全废）。
#   ③ 10-15 白天绕道 `gate_ods_fresh`（SHELL 查 ODS 分区新鲜度），
#      并把 dep 节点里的跨工作流项清空 ⇒「依赖以作业级维护」被破坏。
#   ④ 10-15 晚用户拍板**回归 ①**：ODS 当天没跑 ⇒ DWD 一直 WAITING
#      是合理批次语义。⇒ 本工具恢复作业级写法，gate_ods_fresh 删除。
#
# 跨工作流项形态（每张表的 dep 节点内，与同工作流项并存）：
#   {"projectCode": pcode, "definitionCode": <上游工作流code>,
#    "depTaskCode": <该源表在上游工作流里的作业code>,
#    "cycle": "day", "dateValue": "today",
#    "dependentType": "DEPENDENT_ON_TASK", "parameterPassing": False}
#
# ★ 无法解析成作业的源表（甲方维表 / ODS 未部署）自动跳过并打印清单——
#   「没有作业就不等」是作业级口径的必然结果。

用法
----
    python tools/ds-deploy-dwd-workflow.py --workflow DWD_PROD --dry-run
    python tools/ds-deploy-dwd-workflow.py --workflow DWD_PROD
    # 依赖一律作业级：跨工作流项 DEPENDENT_ON_TASK → 上游具体 ODS 作业
"""
import argparse
import collections
import json
import math
import os
import random
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dw_paths  # noqa: E402
from ds_client import task_definitions  # noqa: E402
from ds_config import ds_admin_password, ds_admin_user  # noqa: E402
from ds_text import read_script  # noqa: E402

# ★ 全部支持环境变量覆盖：脚本同步到生成器侧（`…\claude-code\tools\ds-deploy\`）后，
#   仍默认指向本集群；要指向别的 DS/别的产物目录，设对应环境变量即可。
DS = os.environ.get("DW_DS", "http://localhost:12345/dolphinscheduler")
# ★ 2026-10-22：口令不再有源码缺省值。DW_DS_USER/DW_DS_PWD 仍可覆盖，
#   否则回落到 ds_config（环境变量 / .env.local / ~/.dw-secrets.env）；
#   都缺失则抛 SecretMissingError 并提示配置方式。
USER = os.environ.get("DW_DS_USER") or ds_admin_user()
PWD = os.environ.get("DW_DS_PWD") or ds_admin_password()
PROJECT = os.environ.get("DW_DS_PROJECT", "dw")
def _wsl_path(p):
    r"""Windows 路径在 WSL 里不存在时回退 `/mnt/<盘>/...`（本工具两种环境都跑）。"""
    if os.path.isdir(p) or ":" not in p:
        return p
    drive, _, rest = p[0], p[1:3], p[3:].replace("\\", "/")
    alt = "/mnt/" + drive.lower() + "/" + rest.lstrip("/")
    return alt if os.path.isdir(alt) else p


REPO = _wsl_path(dw_paths.REPO)
# 依赖配置：`dep-config-proscript` —— 来自 `scripts/DWD_依赖关系.xlsx`（配置表排除），
# 与当前 DS 的 112 张表 / 10 个工作流口径一致。
# （旧口径 `dep-config-lineage` 仅保留作历史回退，可用 `--dep-dir` 指向。）
# ★ 2026-10-26：`dep-config-*` 已从 `D:\datax\tools` 迁入本目录（仓库内自包含）。
#   用相对脚本目录的路径 ⇒ Windows / WSL 两种环境都正确，不再依赖 D 盘绝对路径。
_DEPCFG_HOME = os.path.dirname(os.path.abspath(__file__))
DEPCFG = _wsl_path(os.environ.get("DW_DEPCFG", os.path.join(_DEPCFG_HOME, "dep-config-proscript")))
DEPCFG_DWS = _wsl_path(os.environ.get("DW_DEPCFG_DWS", os.path.join(_DEPCFG_HOME, "dep-config-dws")))
# 当前处理层级：DWD（默认）或 DWS。由 `--layer` 在 main() 里设置。
LAYER = "DWD"
TENANT, EXEC = "dolphinscheduler", "SERIAL_WAIT"
CHUNK = 20
COL_W, ROW_H, X0, Y0 = 500, 120, 40, 80
# ★ 2026-10-20（用户要求）：作业描述用**表中文名**（scripts/DWD_表中文名.json，
#   取自甲方 DWD 建表脚本的表级 COMMENT；INIT 表按基表名 +「初始化」补全）。
_CN_CACHE = {}


def cn_name(table):
    if not _CN_CACHE:
        p = os.path.join(REPO, "scripts", "DWD_表中文名.json")
        if LAYER == "DWS":
            p = os.path.join(REPO, "scripts", "DWS_表中文名.json")
        try:
            _CN_CACHE.update(json.load(open(p, encoding="utf-8")))
        except Exception:
            pass
    return _CN_CACHE.get(table) or f"{LAYER} 加工 {table}"
# ★★ 2026-10-15：COL_W 340 → **500**，与全仓口径对齐。
#   340 < 节点宽 350 ⇒ dep 节点与它的作业左右叠 10px；而
#   `ds-relayout.py dwd` / `ds-deploy-api.py --col-w` 的默认值
#   全是 500（对间另 +120 ⇒ PAIR_W=1120、分隔 620）。本模块是 `ds-deploy-all-dwd.py` 的
#   现役落地器，只有它还是 340 ⇒ 导入出的图与"排版要求"不一致、事后还得再跑一次 relayout。
#   改为 500 后「导入即最终排版」。命令行 `--col-w` 可再覆盖（改的是模块全局，供 layout 函数读）。

# ★★★ 2026-10-14（用户要求）：脚本有问题的表**不配真实脚本、改配空脚本**，
#   但**保留全部依赖边**（DAG 完整性优先，下游表等它瞬间通过）。
#   ★ 2026-10-27（J-36）：SALE_FEER / WARN_HIS / TAIL 三张已通过逐条 EXPLAIN
#   （18 条 INSERT 全绿、TMP1/TMP2 已预建）并同步 DS 转正 ⇒ 占位集合清空。
#   执行期失败的表仍可由 `--empty-tables` 追加（逗号分隔，大小写不敏感）。
#   ★ 主数据（`scripts/MASTER/` 下脚本）**2026-10-23 起跑真实脚本**（用户要求）；
#     `--master-placeholder` 回滚 2026-10-15「主数据不跑」的占位口径。
#     （2026-10-15 口径，见下方 MASTER_EMPTY_TPL 与 `_raw_of`）。
DEFAULT_EMPTY = set()
# ★ 2026-10-20（用户口径）：配置表（无 ETL 作业）**不配调度依赖**。
#   生成端 dep-config-proscript 已过滤；部署端再兜底，避免旧配置重建占位任务。
SCHEDULE_EXCLUDE = {"DWD_CMM_STD_DICT_CDVAL_MAP"}
EMPTY_TPL = (
    "#!/bin/bash\n"
    "# [占位] {t} 脚本有问题（编译/执行未通过），按用户要求配置空脚本、保持依赖完整\n"
    'echo "SKIP {t}: placeholder (script invalid, keeps DAG intact)"\n'
)
# ★ 2026-10-15（用户要求）：映射表（编码映射/码表，无 ETL 脚本、手工维护）也要
#   配进工作流——**只配依赖边、脚本给空**。目的：DAG 完整（引用映射表的表有明确
#   前驱），且空脚本秒过，不会像真实脚本那样不通过/一直等待。
MAP_EMPTY_TPL = (
    "#!/bin/bash\n"
    "# [占位] {t} 是映射表（编码映射/码表，无 ETL 脚本，手工维护/独立刷新）\n"
    "#   按用户 2026-10-15 要求：配空脚本、保持依赖完整\n"
    'echo "SKIP {t}: mapping-table placeholder (no ETL script, keeps DAG intact)"\n'
)
# ★★★ 2026-10-15（用户要求，MASTER 口径）：主数据（MASTER）脚本**直取甲方**
#   （建表+ETL 存档于 `scripts/MASTER/dwd/`，血缘由甲方 ETL 手工梳理进
#   `scripts/MASTER/dwd/lineage/`），当时口径是**跑 DWD 时主数据不跑**。
#   ★ 2026-10-23（用户要求）：改为**恢复正常脚本**，主数据随 DWD 批次真实执行。
#     下方 MASTER_EMPTY_TPL 仅由 `--master-placeholder` 使用（回滚旧口径）。
MASTER_EMPTY_TPL = (
    "#!/bin/bash\n"
    "# [占位] {t} 是主数据（MASTER）：脚本直取甲方、存档于 scripts/MASTER/dwd/02_etl/\n"
    "#   按用户 2026-10-15 要求：跑 DWD 时主数据不跑（甲方/手工维护，空脚本保依赖）\n"
    'echo "SKIP {t}: master-data placeholder (DWD 批次不跑主数据, keeps DAG intact)"\n'
)

# ★★★ 2026-10-15：DEPENDENT 的 dateValue **只有这 25 个合法值**（反汇编
#   `DependentUtils.getDateIntervalList` 的 lookupswitch 实锤，无空格驼峰）。
#   写任何其它值（如 "last 5 days"）→ 空区间列表 → 秒判 FAILED。
#   本工具任何地方要写 dateValue 都必须过这道闸（见 build_dep_task）。
VALID_DATE_VALUES = {
    "currentHour", "last1Hour", "last2Hours", "last3Hours", "last24Hours",
    "today", "last1Days", "last2Days", "last3Days", "last7Days",
    "thisWeek", "lastWeek",
    "lastMonday", "lastTuesday", "lastWednesday", "lastThursday",
    "lastFriday", "lastSaturday", "lastSunday",
    "thisMonth", "thisMonthBegin", "thisMonthEnd",
    "lastMonth", "lastMonthBegin", "lastMonthEnd",
}


SID = None


# --------------------------------------------------------------------------- #
# DS API
# --------------------------------------------------------------------------- #
def _raw(method, path, params=None, form=None):
    url = DS + path + ("?" + urllib.parse.urlencode(params) if params else "")
    h = {"Accept": "application/json"}
    if SID:
        h["Cookie"] = "sessionId=" + SID
    data = None
    if form is not None:
        data = urllib.parse.urlencode(form, doseq=True).encode()
        h["Content-Type"] = "application/x-www-form-urlencoded"
    with urllib.request.urlopen(urllib.request.Request(url, data=data, headers=h, method=method),
                                timeout=300) as r:
        b = r.read().decode("utf-8", "replace")
        return json.loads(b) if b else {}


def call(method, path, params=None, form=None, _retry=True):
    try:
        return _raw(method, path, params, form)
    except urllib.error.HTTPError as e:
        if e.code == 401 and _retry:
            login()
            return _raw(method, path, params, form)
        raise


def login():
    global SID
    res = call("POST", "/login", form={"userName": USER, "userPassword": PWD}, _retry=False)
    if res.get("code") != 0:
        sys.exit("登录失败")
    SID = res["data"]["sessionId"]


def wf_list(pcode, search=""):
    r = call("GET", f"/projects/{pcode}/workflow-definition",
             params={"pageNo": 1, "pageSize": 500, "searchVal": search})
    d = r.get("data") or {}
    return d.get("totalList") if isinstance(d, dict) else d


def wf_code(pcode, name):
    for it in wf_list(pcode, name) or []:
        if it["name"] == name:
            return it["code"]
    return None


def neutralize_selfdeps(pcode, wf_code, mode="self"):
    """★★★ 自引用依赖会把工作流**焊死**，删之前必须先中和。

    把同工作流依赖放进 dep 节点后，那些节点的 `definitionCode` = **本工作流自己的 code**。
    DS 的删除校验不区分"引用方是不是自己人" ⇒ 直接报：

        10000 workflow definition cannot be deleted because it has dependent,
              ... used by other tasks: DWD_SCR:dep_DWD_SCR_BOND_INFO_PFD, …

    **那些 `dep_xxx` 就是它自己的节点。** ⇒ 对策：DELETE 前先 PUT 一版
    「去掉所有 `definitionCode == 自己` 的 DEPENDENT_ON_TASK 项」的定义，再删。

    ★ `mode="all"`（2026-10-15）：连**别的 DWD 工作流**指进来的跨流残留项也一并清空。
      旧部署的拓扑可能与新依赖配置不一致（实测：旧态 DWD_PTY_OPER_FUND_PRVL_PFD
      挂在 DWD_PROD 下、DWD_PTY 的 dep 节点反向引用它 ⇒ 按新拓扑逆序删时
      PROD 先删就被 PTY 的残留项挡死）。反正 DWD_* 全部删重建 ⇒ 一刀切清空再删。
    """
    g = call("GET", f"/projects/{pcode}/workflow-definition/{wf_code}")["data"]
    wd = g["workflowDefinition"]
    # ★ 2026-10-22：改用共用的 task_definitions（防御性取值 + 兼容 JSON 字符串），
    #   原为 g["taskDefinitionList"] 裸取键 ⇒ DS 返回结构异常时 KeyError。
    tds = task_definitions(g)
    rels = g["workflowTaskRelationList"]
    rels = json.loads(rels) if isinstance(rels, str) else rels
    changed = 0
    for t in tds:
        if t.get("taskType") != "DEPENDENT":
            continue
        dep = (t.get("taskParams") or {}).get("dependence") or {}
        for grp in dep.get("dependTaskList", []):
            before = grp.get("dependItemList", []) or []
            if mode == "all":
                after = []
            else:
                after = [i for i in before
                         if not (i.get("dependentType") == "DEPENDENT_ON_TASK"
                                 and int(i.get("definitionCode") or 0) == int(wf_code))]
            changed += len(before) - len(after)
            grp["dependItemList"] = after
    if not changed:
        return 0
    locs = wd["locations"]
    locs = json.loads(locs) if isinstance(locs, str) else locs
    call("POST", f"/projects/{pcode}/workflow-definition/{wf_code}/release",
         form={"releaseState": "OFFLINE"})
    res = call("PUT", f"/projects/{pcode}/workflow-definition/{wf_code}", form={
        "name": wd["name"], "description": wd.get("description") or "",
        "globalParams": wd.get("globalParams") or global_params(),
        "locations": json.dumps(locs), "timeout": 0,
        "tenantCode": TENANT, "taskRelationJson": json.dumps(rels),
        "taskDefinitionJson": json.dumps(tds, ensure_ascii=False),
        "executionType": wd.get("executionType") or EXEC, "releaseState": "OFFLINE"})
    if res.get("code") != 0:
        sys.exit(f"中和 {wd['name']} 的自引用依赖失败: "
                 f"{json.dumps(res, ensure_ascii=False)[:300]}")
    return changed


def drop_wf(pcode, name):
    """删同名工作流。★ 必须校验返回码：被别的 DEPENDENT 引用时 DS 会拒绝删除，
    静默放过会导致后面 create 报 `10168 already exists`。"""
    for it in wf_list(pcode, name) or []:
        if it.get("name") != name:
            continue
        call("POST", f"/projects/{pcode}/workflow-definition/{it['code']}/release",
             form={"releaseState": "OFFLINE"})
        # ★ 自引用（DEPENDENT_ON_TASK 指向自己）同样会挡住 DELETE ⇒ 先中和
        n = neutralize_selfdeps(pcode, it["code"])
        if n:
            print(f"      中和 {name} 的 {n} 条自引用依赖（否则删不掉）")
        res = call("DELETE", f"/projects/{pcode}/workflow-definition/{it['code']}")
        if res.get("code") != 0:
            sys.exit(f"删除 {name} 失败: {json.dumps(res, ensure_ascii=False)[:260]}\n"
                     f"   → 多半被别的 DEPENDENT 引用，先删引用方")


def global_params():
    """★★★ DWD 工作流的全局参数（2026-10-10 补）。

    为什么必须有：DWD 脚本里到处是 `P_DT = '${p_end_dt}'`，而 `${p_end_dt}`
    是 **DS 自己**在派发时替换的（不是 shell 变量）。工作流 `globalParams` 为空时
    DS **不做替换** ⇒ 脚本原样带着 `${p_end_dt}` 送进 beeline，
    实测报 `Table not found` 之外的第二重错：`P_DT = '${p_end_dt}'` 被当字面量写分区。

    ★ 踩过的坑：10-10 用 `fix-dwd-globalparams.py` 单独补过一次 globalParams，
      但 `ds-deploy-all-dwd.py` 重建工作流时这里硬编码 `"[]"` ⇒ **把补的又冲掉了**，
      导致整轮跑批全挂。⇒ 参数必须写进**部署工具本身**，不能靠事后打补丁。
    """
    return json.dumps([
        {"prop": "p_start_dt", "direct": "IN", "type": "VARCHAR",
         "value": "${system.biz.date}"},
        {"prop": "p_end_dt", "direct": "IN", "type": "VARCHAR",
         "value": "${system.biz.date}"},
        # ★★ 2026-10-24 补：P_BATCH_DT 必须常驻这里。
        #   DWD_ACCT(7) + DWD_PTY(10) + DWD_PROD(1) 共 18 个脚本用
        #   `P_DT = '${P_BATCH_DT}'`，且**脚本内不自赋值**（不像 HSFA DWS 那样有
        #   `P_BATCH_DT=$begin_date`）⇒ 完全依赖 DS 注入。缺了它 DS 不做替换，
        #   `P_DT=''` 静默写 0 行、作业还报 SUCCESS。
        #   10-10 曾用 fix-dwd-globalparams.py 单独补过一次，被重建冲掉；
        #   2026-10-24 00:30-00:38 用 ds-deploy-api.py 重部署 13 个工作流时
        #   又被冲掉一次（同一个坑踩两遍）⇒ 必须写进部署工具本身。
        {"prop": "P_BATCH_DT", "direct": "IN", "type": "VARCHAR",
         "value": "${system.biz.date}"},
    ], ensure_ascii=False)


def create_wf(pcode, name, desc, tasks, rels, locs):
    drop_wf(pcode, name)
    res = call("POST", f"/projects/{pcode}/workflow-definition", form={
        "name": name, "description": desc, "globalParams": global_params(),
        "locations": json.dumps(locs), "timeout": 0, "tenantCode": TENANT,
        "taskRelationJson": json.dumps(rels),
        "taskDefinitionJson": json.dumps(tasks, ensure_ascii=False),
        "executionType": EXEC, "releaseState": "OFFLINE",
    })
    if res.get("code") != 0:
        sys.exit(f"建 {name} 失败: {json.dumps(res, ensure_ascii=False)[:300]}")
    return res["data"]["code"]


# --------------------------------------------------------------------------- #
# 依赖解析
# --------------------------------------------------------------------------- #
def load_cfgs(dep_dir):
    if not os.path.isdir(dep_dir):
        sys.exit(f"依赖配置目录不存在：{dep_dir}\n"
                 f"  → 先跑 python tools/ds-build-dependent-from-lineage.py")
    out = {}
    for f in sorted(os.listdir(dep_dir)):
        if f.endswith(".dep.json"):
            c = json.load(open(os.path.join(dep_dir, f), encoding="utf-8"))
            out[c["target"]] = c
    return out


def script_of(table):
    layer_dir = "dws" if LAYER == "DWS" else "dwd"
    for s in sorted(os.listdir(os.path.join(REPO, "scripts"))):
        p = os.path.join(REPO, "scripts", s, layer_dir, "02_etl", table + ".sh")
        if os.path.isfile(p):
            return p
    return None


def ods_chunks(sys_name):
    d = os.path.join(REPO, "scripts", sys_name, "ods", "etl_sh")
    if not os.path.isdir(d):
        return []
    files = sorted(f[:-3] for f in os.listdir(d)
                   if f.endswith(".sh") and not f.startswith(".") and "deploy-to-worker" not in f)
    return [(i // CHUNK + 1, files[i:i + CHUNK]) for i in range(0, len(files), CHUNK)]


def locate_ods(sys_name, table):
    """源表 → `ods_<sys>_etl_NN`。表不存在时用 difflib 找最相近的兄弟表所在批次。"""
    chunks = ods_chunks(sys_name)
    for n, ts in chunks:
        if table in ts:
            return f"ods_{sys_name.lower()}_etl_{n:02d}"
    import difflib
    allt = [t for _, ts in chunks for t in ts]
    close = difflib.get_close_matches(table, allt, n=1, cutoff=0.6)
    if close:
        for n, ts in chunks:
            if close[0] in ts:
                return f"ods_{sys_name.lower()}_etl_{n:02d}"
    return None


def resolve_upstream(dep_name, sources, overrides):
    if dep_name in overrides:
        return overrides[dep_name], "手工指定"
    if dep_name.startswith(("DWD", "MASTER", "DWS")):
        return dep_name, f"{dep_name.split('_')[0]} 工作流（自动创建/已部署）"
    src = sources[0] if sources else ""
    if src.startswith("ODS_"):
        wf = locate_ods(src.split("_")[1], src)
        if wf:
            return wf, f"{src} 所在批次"
    return None, f"无法解析（{dep_name} / {src}）"


# --------------------------------------------------------------------------- #
# 图处理
# --------------------------------------------------------------------------- #
def transitive_reduce(nodes, edges):
    """去掉冗余边：若 a→b 还有另一条 a→…→b 的路径，则 a→b 可省（避免跨层长斜线）。"""
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b)

    def reachable(src, skip):
        seen, stack = set(), [src]
        while stack:
            x = stack.pop()
            for y in adj[x]:
                if (x, y) == skip or y in seen:
                    continue
                seen.add(y)
                stack.append(y)
        return seen

    return {(a, b) for a, b in edges if b not in reachable(a, (a, b))}


def auto_per_row(n, lo=3, hi=6):
    """★ 自动挑「每排几对」：优先**不留空格**，其次接近正方形，最后行数少。

    11 个主题工作流的规模从 1 张到 26 张不等，写死每排 3 对会让大工作流排得又高又窄、
    小工作流末排只剩一个 ⇒ 逐个手调不现实，交给这个函数。
    """
    if n <= lo:
        return max(1, n)
    best, key = None, None
    for p in range(lo, hi + 1):
        rows = math.ceil(n / p)
        k = (rows * p - n, abs(rows - p), rows)   # ① 空格数 ② 长宽比偏差 ③ 行数
        if key is None or k < key:
            best, key = p, k
    return best


def _find_simple_cycles(adj, maxlen=10):
    """枚举全部简单环（限制长度，避免组合爆炸）。"""
    cycles, seen = [], set()

    def dfs(path, inpath):
        for nxt in sorted(adj.get(path[-1], ())):
            if nxt == path[0]:
                key = tuple(sorted(path))
                if key not in seen:
                    seen.add(key)
                    cycles.append(list(path))
            elif nxt not in inpath and len(path) < maxlen:
                inpath.add(nxt)
                path.append(nxt)
                dfs(path, inpath)
                path.pop()
                inpath.discard(nxt)

    for s in sorted(adj):
        dfs([s], {s})
    return cycles


def break_cycles(nodes, edges):
    """打断环：返回 (无环边集, 被切断的边列表)。

    ★ 2026-10-22 修 bug（评审 HIGH-5）：原实现只处理 **2-环**（互为前后的
      `(a,b)` / `(b,a)`）—— 而血缘图里出现长度 ≥3 的环（A→B→C→A）时，
      2-环检测找不到任何东西，环**原样留在图里** ⇒ DS 建图直接报
      `50019 workflow node has cycle`，部署中断且无法自动恢复。
      （`ds-deploy-all-dwd.py` 的 topo_order 只把环内节点追加到末尾，
      并不真正解决环。）

      ⇒ 改为「枚举全部简单环 + 贪心切边」：每次切掉**落在最多环里**的那条边
      （切一条顶多条），直到无环。
      该算法与 `ds-build-dependent-from-lineage.py::break_wf_cycles` 同源
      （那边已在 DWD 全量建边上实测：6 个环只需切 2 条）。
    """
    adj = collections.defaultdict(set)
    edge_set = set(edges)
    for a, b in edge_set:
        adj[a].add(b)

    dropped = []
    while True:
        cycles = _find_simple_cycles(adj)
        if not cycles:
            break
        cnt = collections.Counter()
        for c in cycles:
            for i in range(len(c)):
                e = (c[i], c[(i + 1) % len(c)])
                if e in edge_set:
                    cnt[e] += 1
        if not cnt:
            break                      # 环上的边不在原边集里（理论上不该发生）
        # 选落在最多环里的边切断；同次数时按边名稳定排序（保证可复现）
        best = min(cnt, key=lambda e: (-cnt[e], e))
        edge_set.discard(best)
        dropped.append(best)
        adj[best[0]].discard(best[1])
    return edge_set, dropped


def _seg(x1, y1, x2, y2, x3, y3, x4, y4):
    """两线段是否真交叉（共用端点不算）。"""
    def cr(ax, ay, bx, by, cx, cy):
        return (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
    d1 = cr(x3, y3, x4, y4, x1, y1)
    d2 = cr(x3, y3, x4, y4, x2, y2)
    d3 = cr(x1, y1, x2, y2, x3, y3)
    d4 = cr(x1, y1, x2, y2, x4, y4)
    return (d1 * d2 < 0) and (d3 * d4 < 0)


def count_cross(edges, locs):
    segs = [(locs[a]["x"], locs[a]["y"], locs[b]["x"], locs[b]["y"]) for a, b in edges]
    n = 0
    for i in range(len(segs)):
        for j in range(i + 1, len(segs)):
            if _seg(*segs[i], *segs[j]):
                n += 1
    return n


def pair_grid_layout(members, edges, dep_of, restarts=40, per_row=3,
                     order_mode="crossing", logical=None):
    """★ 成对网格布局：`[依赖][作业]` 横向成一对，每排 `per_row` 对。

    参数
    ----
    edges   : **画出来的**边（同源工作流依赖改成 dep 项后，这里只剩 `dep→表`）
    logical : **逻辑上的**依赖边（含那些已挪进 dep 节点的同工作流依赖）。
              `base`（依赖层）/ 逆序边 / 跨度 **都按它算** —— 这样即使不画线，
              排布顺序仍然是「上游在上、下游在下」的可读顺序。默认 = `edges`。

    order_mode:
      · `crossing`（默认）— 对 (交叉数, 逆序边, 跨度) 做爬山 + 随机重启
      · `topo`            — 严格按「依赖层 + 表名」排，不爬山
    """
    logical = set(logical if logical is not None else edges)
    base = {t: 0 for t in members}
    for _ in range(len(members)):
        ch = False
        for a, b in logical:
            if base[b] < base[a] + 1:
                base[b] = base[a] + 1
                ch = True
        if not ch:
            break
    PAIR_W = 2 * COL_W + 120          # 一对的横向跨度（含间隙）

    def build(seq):
        grow = {t: i for i, t in enumerate(seq)}
        locs, col, row = {}, {}, {}
        for i, t in enumerate(seq):
            r, c = divmod(i, per_row)
            x0 = X0 + c * PAIR_W
            y = Y0 + r * ROW_H
            # ★ `dep_of` 可能是**部分**映射：依赖集为空的表不挂 depend 控件
            #   （空的 dependItemList 在 DS 里行为未定义）⇒ 该格只放表，但**仍占右侧列**，
            #   整列的对齐不被打乱。
            if t in dep_of:
                locs[dep_of[t]] = {"x": x0, "y": y}
                col[dep_of[t]] = 2 * c
                row[dep_of[t]] = r
            locs[t] = {"x": x0 + COL_W, "y": y}
            col[t] = 2 * c + 1
            row[t] = r
        ae = set(edges) | {(d, t) for t, d in dep_of.items()}
        # 逆序边 / 跨度都按**逻辑边**算（不画线的依赖也算进去），
        # 否则"依赖挪进 dep 节点"后这两个指标恒为 0，排布会退化成纯字母序。
        back = sum(1 for a, b in logical if grow[a] > grow[b])
        span = sum(abs(grow[a] - grow[b]) for a, b in logical)
        #                 交叉, 逆序边, 跨度
        return locs, count_cross(ae, locs), col, row, back, span

    def score(r):
        """布局优劣 = (交叉数, 逆序边数, 跨度)。
        ① 交叉数是硬指标；相同交叉下 ② 逆序边越少越「自上而下可读」；
        ③ 再相同则跨度越小越「聚拢」，长斜线越少。"""
        return (r[1], r[4], r[5])

    def climb(seq):
        best = build(seq)
        improved = True
        while improved:
            improved = False
            for i in range(len(seq) - 1):
                for j in range(i + 1, len(seq)):
                    seq[i], seq[j] = seq[j], seq[i]
                    trial = build(seq)
                    if score(trial) < score(best):
                        best, improved = trial, True
                    else:
                        seq[i], seq[j] = seq[j], seq[i]
        return best

    start = sorted(members, key=lambda t: (base[t], t))
    if order_mode == "topo":
        return build(start)                       # 纯依赖层序，不爬山
    best = climb(start)
    # ★ 不设「交叉=0 就停」的早退：交叉为 0 的排法有很多，还要在它们之间
    #   继续挑「逆序边更少 / 更聚拢」的那个，否则看起来仍然乱。
    if restarts > 0:
        rnd = random.Random(20261005)
        for _ in range(restarts):
            seq = start[:]
            rnd.shuffle(seq)
            t = climb(seq)
            if score(t) < score(best):
                best = t
    return best


def grid_layout(members, edges, dep_of, restarts=40):
    """零交叉布局：依赖节点在表正上方；行序用「爬山 + 随机重启」优化真实交叉数。"""
    base = {t: 0 for t in members}
    for _ in range(len(members)):
        ch = False
        for a, b in edges:
            if base[b] < base[a] + 1:
                base[b] = base[a] + 1
                ch = True
        if not ch:
            break

    def build(seq):
        grow = {t: i for i, t in enumerate(seq)}
        locs, col, row = {}, {}, {}
        for t in members:
            col[t] = base[t] + 1
            row[t] = 2 * grow[t] + 1              # 表占奇数格
            locs[t] = {"x": X0 + col[t] * COL_W, "y": Y0 + row[t] * ROW_H}
        for t, d in dep_of.items():               # ★ 可能只是部分表（依赖集为空的不挂控件）
            col[d] = col[t]                       # 与表同列
            row[d] = 2 * grow[t]                  # 上一格 ⇒ 边是竖线
            locs[d] = {"x": X0 + col[d] * COL_W, "y": Y0 + row[d] * ROW_H}
        ae = set(edges) | {(d, t) for t, d in dep_of.items()}
        return locs, count_cross(ae, locs), col, row, 0, 0

    def climb(seq):
        best = build(seq)
        improved = True
        while improved:
            improved = False
            for i in range(len(seq) - 1):
                for j in range(i + 1, len(seq)):
                    seq[i], seq[j] = seq[j], seq[i]
                    trial = build(seq)
                    if trial[1] < best[1]:
                        best, improved = trial, True
                    else:
                        seq[i], seq[j] = seq[j], seq[i]
        return best

    start = sorted(members, key=lambda t: (base[t], t))
    best = climb(start)
    if best[1] > 0 and restarts > 0:
        rnd = random.Random(20261005)             # 固定种子 ⇒ 结果可复现
        for _ in range(restarts):
            seq = start[:]
            rnd.shuffle(seq)
            t = climb(seq)
            if t[1] < best[1]:
                best = t
            if best[1] == 0:
                break
    return best


# --------------------------------------------------------------------------- #
# 任务构造
# --------------------------------------------------------------------------- #
def build_job_index(pcode):
    """全项目作业索引：作业名(大写) → (工作流名, 工作流code, 作业code)。

    只收 ods_* / DWD_* / MASTER_* 工作流里的 SHELL 任务（真实作业）。
    DEPENDENT、门禁、占位一律不进——等它们没有「数据就绪」语义。
    ★ 2026-10-15 晚：漏了 MASTER_ 前缀 ⇒ DWD_PROD 全量表的 NUM_MAPP 跨工作流
    依赖被静默跳过（WARN_HIS 唯一依赖即 NUM_MAPP，dep 节点直接被掏空）。
    """
    idx = {}
    for it in wf_list(pcode) or []:
        nm, wc = it.get("name"), it.get("code")
        if not str(nm).startswith(("ods_", "DWD_", "MASTER_", "DWS_")):
            continue
        g = call("GET", f"/projects/{pcode}/workflow-definition/{wc}")
        tds = (g.get("data") or {}).get("taskDefinitionList") or []
        if isinstance(tds, str):
            tds = json.loads(tds)
        for t in tds:
            if t.get("taskType") != "SHELL":
                continue
            idx[str(t.get("name", "")).upper()] = (nm, wc, t.get("code"))
    return idx


def cross_items_for(t, wf_name, cfgs, job_index, pcode):
    """跨工作流**作业级**依赖项（2026-10-15 晚回归口径）。

    cfgs[t]["cross_workflow"] 的每个源表 → 一条 DEPENDENT_ON_TASK：
    definitionCode = 上游工作流 code，depTaskCode = 该源表作业的 code，
    dateValue = "today"（等上游**当天**成功实例；ODS 当天没跑就一直
    WAITING——用户拍板的批次语义）。

    跳过并记录（没有作业就不等）：
      · 源表不在 DS 作业索引里（ODS 未部署/无脚本，如 ODS_HSFA_TXM_XX_PTD）
      · 源表作业不在其组声明的工作流里（配置漂移）
      · 组声明的就是本工作流（那是同工作流依赖，走 task_ref，不进这里）
    返回 (items, skipped, drifted)。
    """
    c = cfgs[t]
    dwd_etl = {x for x in cfgs if script_of(x)}
    items, skipped, drifted, seen = [], [], [], set()
    for g in c.get("cross_workflow") or []:
        up_name = g.get("workflow") or ""
        if up_name == wf_name:
            continue
        for s in g.get("sources") or []:
            job = str(s.get("source") or "").upper()
            if not job:
                continue
            real = job.startswith("ODS_") or job in dwd_etl
            hit = job_index.get(job)
            if not hit:
                skipped.append((job, "DS 无此作业（未部署/无脚本）" if real
                                else "非作业表（甲方维表/映射表）"))
                continue
            if hit[0] != up_name:
                # ★★★ 2026-10-16 行为变更：**采信 DS 现实，不再丢边**。
                #   旧行为：组声明（dep.json 的 workflow 字段）与 DS 实际不符就 `continue`
                #   ⇒ 依赖边**静默丢失**，DWD 不等上游直接跑（实测丢 2 条：
                #   ODS_O32_TRATIOLOG_PTD / ODS_O32_TBANKACCOUNT_PFD 本地分块算出
                #   etl_05、DS 实际在 etl_08 —— 昨晚后补部署留下的漂移）。
                #   「作业到底在哪」的唯一权威是 DS（job_index 就是按 DS 建的），
                #   dep.json 只是预测 ⇒ 采信 hit[0]，仅告警。
                drifted.append((job, up_name, hit[0]))
            key = (hit[1], hit[2])
            if key in seen:
                continue
            seen.add(key)
            items.append({"projectCode": pcode, "definitionCode": hit[1],
                          "depTaskCode": hit[2], "cycle": "day",
                          "dateValue": "today",
                          "dependentType": "DEPENDENT_ON_TASK",
                          "parameterPassing": False})
    return items, skipped, drifted


def build_task(code, name, raw, desc):
    return {"code": code, "name": name, "version": 1, "description": desc,
            "delayTime": 0, "taskType": "SHELL",
            "taskParams": {"rawScript": raw, "localParams": [], "resourceList": [],
                           "dependence": {}},
            "flag": "YES", "taskPriority": "MEDIUM", "workerGroup": "default",
            "environmentCode": -1, "failRetryTimes": 0, "failRetryInterval": 1,
            "timeoutFlag": "CLOSE", "timeoutNotifyStrategy": "", "timeout": 0,
            "resourceIds": "", "dependence": {}, "waitStartTimeout": {},
            "conditionResult": {"successNode": [], "failedNode": []}}


def build_dep_task(code, name, items):
    # ★★★ 回归防护（2026-10-15 事故）：dateValue 非法值 → 空区间列表 →
    #   9ms 秒判 FAILED，且与窗口大小无关。只认 VALID_DATE_VALUES 白名单。
    for it in items:
        dv = it.get("dateValue")
        if dv not in VALID_DATE_VALUES:
            sys.exit(f"❌ dateValue 非法值 {dv!r}（表 {name}）\n"
                     f"   合法值仅：{sorted(VALID_DATE_VALUES)}\n"
                     f"   → 想要『最近 N 天成功过一次』的语义请用 gate_ods_fresh，"
                     f"不要写自由文本")
    return {"code": code, "name": name, "version": 1,
            "description": "依赖上游工作流（自动生成）",
            "delayTime": 0, "taskType": "DEPENDENT",
            "taskParams": {"localParams": [], "resourceList": [], "rawScript": "",
                           "dependence": {"relation": "AND",
                                          "dependTaskList": [{"relation": "AND",
                                                              "dependItemList": items}],
                                          "checkInterval": 60,
                                          "failurePolicy": "DEPENDENT_FAILURE_FAILURE",
                                          "failureWaitingTime": 0}},
            "flag": "YES", "taskPriority": "MEDIUM", "workerGroup": "default",
            "environmentCode": -1, "failRetryTimes": 0, "failRetryInterval": 1,
            "timeoutFlag": "CLOSE", "timeoutNotifyStrategy": "", "timeout": 0,
            "resourceIds": "", "dependence": {}, "waitStartTimeout": {},
            "conditionResult": {"successNode": [], "failedNode": []}}


def rel(pre, post):
    return {"name": "", "preTaskCode": pre, "preTaskVersion": (1 if pre else 0),
            "postTaskCode": post, "postTaskVersion": 1,
            "conditionType": "NONE", "conditionParams": {}}


def plan(workflow, cfgs, overrides, inherit=False):
    members = sorted(t for t, c in cfgs.items()
                     if c["own_workflow"] == workflow and script_of(t))
    if not members:
        sys.exit(f"{workflow} 没有可用成员")
    mset = set(members)
    raw_edges = set()
    for t in members:
        for s in cfgs[t]["same_workflow_predecessors"]:
            if s["source"] in mset:
                raw_edges.add((s["source"], t))
    edges, dropped = break_cycles(members, raw_edges)
    before = len(edges)
    edges = transitive_reduce(members, edges)
    trimmed = before - len(edges)

    up, tbl2up = {}, {t: set() for t in members}
    for t in members:
        for g in cfgs[t]["cross_workflow"]:
            nm, why = resolve_upstream(g["workflow"], [s["source"] for s in g["sources"]], overrides)
            if not nm:
                print(f"   ⚠ {t}: {why} —— 跳过该依赖")
                continue
            up.setdefault(nm, {"sources": set(), "why": why})
            up[nm]["sources"].update(s["source"] for s in g["sources"])
            tbl2up[t].add(nm)

    # 「继承前置表的跨工作流依赖」（`--inherit` 才开）
    # ----------------------------------------------------
    # ★★★ **默认关闭**。原来开着的理由是「让每个作业都挂一个依赖控件」，
    #   但现在**同工作流依赖本身也会进 dep 节点**（`--same-wf dep-node`），
    #   表只要有任何依赖就一定有控件；继承只剩下「多等一层已经卡住的 ODS 批次」，
    #   是纯冗余等待（前置表早就把它等过了）。
    #   ⇒ 想要旧的「每个作业一个控件、哪怕冗余」行为就加 `--inherit`。
    inherited = []
    if inherit:
        for _ in range(len(members)):
            changed = False
            for t in members:
                if tbl2up[t]:
                    continue
                for s in cfgs[t]["same_workflow_predecessors"]:
                    p = s["source"]
                    if p in tbl2up and tbl2up[p]:
                        tbl2up[t] |= tbl2up[p]
                        changed = True
            if not changed:
                break
        inherited = sorted(t for t in members if not any(
            g for g in cfgs[t]["cross_workflow"]))
    return members, edges, dropped, trimmed, up, tbl2up, inherited


# --------------------------------------------------------------------------- #
def main():
    global LAYER
    ap = argparse.ArgumentParser(description="把一个 DWD/DWS 工作流的全部依赖落地 + 零交叉布局")
    ap.add_argument("--workflow", required=True)
    ap.add_argument("--layer", choices=["DWD", "DWS"], default="DWD")
    ap.add_argument("--dep-dir", default=None,
                    help="依赖配置目录（DWD 默认 tools/dep-config-lineage；DWS 默认 tools/dep-config-dws）")
    ap.add_argument("--map", default="", help="甲方工作流名=实际DS工作流名，逗号分隔")
    ap.add_argument("--restarts", type=int, default=40, help="布局爬山搜索的随机重启次数")
    ap.add_argument("--layout", choices=["pair-grid", "dep-above"], default="pair-grid",
                    help="pair-grid=[依赖][作业]成对横向排、每排 3 对（默认）；dep-above=依赖在表正上方")
    ap.add_argument("--per-row", default="3",
                    help="pair-grid 每排几对；默认 **3**（= 排版要求 / ds-relayout.py dwd 的目标版式）。"
                         "传 `auto` 可按表数自动取近似矩形（3~6，优先不留空格、其次接近正方形）"
                         "—— ★ 但 auto 与 relayout 的固定 3 不一致（12/13/15 表时会取 4~5 对），"
                         "用 auto 就得接受「导完再补一次 relayout」")
    ap.add_argument("--order-mode", choices=["crossing", "topo"], default="crossing",
                    help="pair-grid 的排布顺序：crossing=爬山搜「交叉最少 + 逆序边最少」(默认)；"
                         "topo=严格按依赖层+表名排（自上而下可读，可能留交叉）")
    ap.add_argument("--same-wf", choices=["dep-node", "lines"], default="dep-node",
                    help="同工作流依赖怎么表达：dep-node=**放进 dep 节点**（DEPENDENT_ON_TASK，"
                         "不画线，默认，用户要求「避免牵线太多」）；lines=画成表→表连线（旧行为）")
    ap.add_argument("--inherit", action="store_true",
                    help="给「无跨工作流依赖」的表**继承**前置表的跨工作流等待（冗余，默认关）")
    ap.add_argument("--empty-tables", default="",
                    help="这些表配空脚本（不配真实 ETL），依赖边保留；"
                         "逗号分隔。默认已含 5 张指定排除表")
    ap.add_argument("--master-placeholder", action="store_true",
                    help="回滚 2026-10-15 旧口径：主数据（scripts/MASTER/）配空脚本不跑。"
                         "默认已改为跑真实脚本（2026-10-23 用户要求）")
    ap.add_argument("--col-w", type=int, default=None,
                    help="列间距（列宽>节点宽，DWD 建议 500，默认取模块常量 500）；"
                         "与 ds-relayout.py dwd 默认一致")
    ap.add_argument("--dry-run", action="store_true")
    # ★ 2026-10-16：dry-run 时打印每个 dep 节点的期望组成（增量核对，不重建）
    ap.add_argument("--dump-items", action="store_true",
                    help="配合 --dry-run：打印各 dep 节点期望的 dependItemList 组成")
    ap.add_argument("--dump-json", default="",
                    help="配合 --dry-run --dump-items：把期望态写成 JSON（供比对脚本消费）")
    args = ap.parse_args()
    LAYER = args.layer
    if not args.dep_dir:
        args.dep_dir = DEPCFG_DWS if LAYER == "DWS" else DEPCFG

    if args.col_w:
        globals()["COL_W"] = args.col_w

    empty_set = (set(DEFAULT_EMPTY) if LAYER == "DWD" else set()) | {
        x.strip().upper() for x in args.empty_tables.split(",") if x.strip()}
    # ★ 2026-10-23（用户要求）：主数据恢复正常脚本。`--master-placeholder` 可回滚旧口径。
    master_placeholder = bool(args.master_placeholder) and LAYER == "DWD"

    args.dep_dir = _wsl_path(args.dep_dir)
    cfgs = load_cfgs(args.dep_dir)
    print(f"依赖配置：{args.dep_dir}（{len(cfgs)} 张表）")
    overrides = {}
    for kv in [x for x in args.map.split(",") if x.strip()]:
        k, _, v = kv.partition("=")
        overrides[k.strip()] = v.strip()

    members, edges, dropped, trimmed, up, tbl2up, inherited = plan(
        args.workflow, cfgs, overrides, inherit=args.inherit)
    print(f"工作流 {args.workflow}：{len(members)} 张表")
    print(f"同工作流依赖 {len(edges)} 条 → "
          + ("**放进 dep 节点**（不画线）" if args.same_wf == "dep-node" else "画成表→表连线")
          + (f"（传递归约去掉 {trimmed} 条冗余）" if trimmed else "")
          + (f"；打断环丢弃 {dropped}" if dropped else ""))
    print(f"上游工作流 {len(up)} 个：")
    for w, info in sorted(up.items()):
        n = sum(1 for t in members if w in tbl2up[t])
        print(f"   {w:24s} 供 {n:2d} 张表   ({info['why']})")

    if inherited:
        print(f"\n无跨工作流依赖、改为**继承前置表依赖**的表（{len(inherited)} 张）:")
        for t in inherited:
            print(f"   {t}  ← 继承 {sorted(tbl2up[t])}")
    # ★ 2026-10-15 晚：dep 节点承载**全部**依赖——同工作流前驱、本工作流
    #   映射表占位、跨工作流上游**作业**（作业级口径回归，见文档串）。
    #   ⚠ 空的 dependItemList 在 DS 3.4.2 里行为未定义（可能挂死）——
    #     构造保证 dep 节点必有 DEPENDENT_ON_TASK 项（无任何依赖的表不建节点）。
    # 2026-10-15：归属本工作流的映射表（被本工作流表引用的编码映射/码表，
    #   无 ETL 脚本）→ 空脚本占位任务。依赖走**每个作业一个 DEPENDENT 节点**
    #   （用户要求「一个作业一个依赖、按 DWD 格式排版」）：映射表依赖并入该表
    #   的 dep 节点，不再画 map->表 直接边。
    map_ref = {}          # 映射表 -> 引用它的本工作流表
    for t in members:
        for md in cfgs[t].get("mapping_deps") or []:
            m = md.get("source")
            # 2026-10-20（用户口径）：配置表（无作业）在生成依赖配置时已过滤；
            #   这里再兜一层，旧 dep.json 也不会重建占位任务/依赖边。
            if LAYER == "DWD" and m in SCHEDULE_EXCLUDE:
                continue
            if m and md.get("owner_workflow") == args.workflow:
                map_ref.setdefault(m, []).append(t)
    tbl_map = {t: sorted(m for m, ts in map_ref.items() if t in ts)
               for t in members}   # 表 -> 它引用的本工作流映射表
    if map_ref:
        print(f"\n映射表空脚本占位（无 ETL 脚本，只配依赖、脚本给空，2026-10-15）"
              f"{len(map_ref)} 张：")
        for m in sorted(map_ref):
            print(f"   {m:42s} ← 本工作流 {len(set(map_ref[m]))} 张表引用")
    else:
        print("\n（本工作流无被同工作流引用的映射表）")

    task_ref = {t: sorted({a for a, b in edges if b == t}) for t in members}
    # ---------- 会话 + 全项目作业索引（dry-run 也执行：只读，不影响） ----------
    login()
    r = call("GET", "/projects/list", params={"searchVal": PROJECT, "pageSize": 50, "pageNo": 1})
    d = r.get("data")
    plist = d.get("totalList") if isinstance(d, dict) else d
    pcode = next((p["code"] for p in plist or [] if p["name"] == PROJECT), None)
    if not pcode:
        sys.exit(f"项目 {PROJECT} 不存在")
    print(f"      {PROJECT} code={pcode}")
    job_index = build_job_index(pcode)
    print(f"      作业索引：{len(job_index)} 个 SHELL 作业（ods_*/DWD_*）")
    # ★★★ 2026-10-15 晚：跨工作流依赖回归【作业级】（口径变迁见文档串）。
    #   每个源表 → DEPENDENT_ON_TASK（definitionCode=上游工作流，
    #   depTaskCode=具体作业，dateValue=today）。ODS 当天没跑就一直
    #   WAITING——用户拍板的批次语义。
    cross_items, skipped, drifted = {}, {}, {}
    for t in members:
        cross_items[t], skipped[t], drifted[t] = cross_items_for(
            t, args.workflow, cfgs, job_index, pcode)
    n_cross = sum(len(v) for v in cross_items.values())
    n_with_cross = sum(1 for v in cross_items.values() if v)
    print(f"跨工作流作业级依赖：{n_cross} 条，覆盖 {n_with_cross}/{len(members)} 张表")
    for t in members:
        if cross_items[t]:
            print(f"   {t:46s} {len(cross_items[t])} 条跨工作流等待")
    if any(skipped.values()):
        print("   ⚠ 无作业可等、已跳过的源表（『没有作业就不等』）：")
        for t in members:
            for job, why in skipped[t]:
                print(f"      {t:46s} ← {job}（{why}）")
    if any(drifted.values()):
        print("   ⚠ 组声明与 DS 实际不符 ⇒ **已采信 DS**（2026-10-16 起不再丢边）：")
        for t in members:
            for job, declared, real in drifted[t]:
                print(f"      {t:46s} ← {job}（声明 {declared} / 实际 {real}）")
    # 归属别的工作流的映射表/甲方维表：无 ETL 作业 ⇒ 不算当日上游，不建依赖
    map_cross = sorted({(t, m.get("source")) for t in members
                        for m in (cfgs[t].get("mapping_deps") or [])
                        if m.get("owner_workflow") != args.workflow and m.get("source")})
    if map_cross:
        print(f"   ℹ {len(map_cross)} 项映射表/甲方维表跨工作流引用无作业，跳过"
              f"（例：{map_cross[0][1]} ← {map_cross[0][0]}）")

    dep_of = ({t: f"dep_{t}" for t in members
               if task_ref[t] or tbl_map.get(t) or cross_items[t]}
              if args.same_wf == "dep-node" else {})
    bare = [t for t in members if t not in dep_of]
    if bare:
        print(f"\n无任何依赖、直连虚拟根的表（{len(bare)} 张）：")
        for t in bare:
            print(f"   {t}（无同工作流前驱、无映射表、无跨工作流作业）")
    nodes = list(members) + sorted(dep_of.values())
    # 画出来的边：`dep-node` 模式下**没有**表→表连线，只有 dep→表
    drawn = set(edges) if args.same_wf == "lines" else set()
    all_edges = drawn | {(d, t) for t, d in dep_of.items()}
    per_row = (auto_per_row(len(members)) if args.per_row == "auto" else int(args.per_row))
    if args.layout == "pair-grid":
        locs, cross, col, row, back, span = pair_grid_layout(
            members, drawn, dep_of, restarts=args.restarts, per_row=per_row,
            order_mode=args.order_mode, logical=edges)
    else:
        locs, cross, col, row, back, span = grid_layout(members, drawn, dep_of,
                                                       restarts=args.restarts)
    print(f"\n布局：{len(nodes)} 个节点，{len(all_edges)} 条连线，"
          f"**交叉 {cross} 条**，逆序边 {back} 条，跨度 {span}"
          + (f"（顺序模式 {args.order_mode}，每排 {per_row} 对）"
             if args.layout == "pair-grid" else ""))

    if args.dry_run:
        for r in sorted(set(row.values())):
            ns = sorted([n for n in nodes if row[n] == r], key=lambda n: col[n])
            print(f"   第{r}排: " + "  ".join(f"[{n}]" if n.startswith("dep_") else f"{n}"
                                              for n in ns))
        # ★ 2026-10-16：增量核对用。打印每个 dep 节点的**期望**组成
        #   （同流前驱 + 映射表占位 + 跨流作业级），便于与 DS 现状逐项 diff，
        #   不必删工作流重建（重建会让别的工作流里指向本工作流作业 code 的
        #   跨流引用悬空）。
        if args.dump_items:
            print("\n=== [dump] 各 dep 节点期望组成 ===")
            _dump = {}
            for t in sorted(dep_of):
                same = task_ref.get(t, [])
                maps = tbl_map.get(t, [])
                cr = cross_items.get(t, [])
                if not (same or maps or cr):
                    continue
                print(f"\n dep_{t}")
                for p in same:
                    print(f"    同流  {p}")
                for m in maps:
                    print(f"    映射  {m}")
                for it in cr:
                    print(f"    跨流  def={it.get('definitionCode')} "
                          f"task={it.get('depTaskCode')} {it.get('dateValue')}")
                print(f"    合计 {len(same)} + {len(maps)} + {len(cr)}"
                      f" = {len(same) + len(maps) + len(cr)} 项")
                _dump[t] = {"same": list(same), "maps": list(maps),
                            "cross": [[it.get("definitionCode"), it.get("depTaskCode")]
                                      for it in cr],
                            "n": len(same) + len(maps) + len(cr)}
            if args.dump_json:
                # ★ 2026-10-22：用 with 管理文件句柄（原写法
                #   json.dump(..., open(path,"w")) 依赖 GC 关闭句柄）
                with open(args.dump_json, "w", encoding="utf-8") as fh:
                    json.dump({"workflow": args.workflow, "dep": _dump},
                              fh, ensure_ascii=False, indent=1)
                print(f"\n期望态已写出 → {args.dump_json}")
        print("\n--- dry-run，不动 DS ---")
        return 0


    # ★★★ 先删本工作流，释放它对上游的 DEPENDENT 引用，否则上游删不掉
    print(f"\n[1/5] 先删 {args.workflow}（释放对上游的引用）")
    drop_wf(pcode, args.workflow)

    up_auto = sorted(
        w for w in up
        if ((w.startswith(("DWD_", "MASTER_")) if LAYER == "DWD"
             else w.startswith("DWS_")) and w != args.workflow))
    print(f"\n[2/5] 准备上游 {LAYER} 工作流: {up_auto or '(无)'}")
    # ★ 2026-10-18（评审 #2）：原实现这段循环写了两遍（第一遍只收集 created_up、
    #   第二遍才真正建），重复打印 + 重复查询；合并为一遍，语义不变。
    created_up = []
    if LAYER == "DWS":
        # DWS 上游工作流必须是**已完整部署**的同层工作流（含它自己的依赖/排版），
        # 不能在这里临时建一个只有 SHELL 任务的浅层版本。
        missing = [w for w in up_auto if not wf_code(pcode, w)]
        if missing:
            sys.exit(f"★ 上游 DWS 工作流不存在: {missing}\n"
                     f"  → 请先按拓扑序部署上游 DWS 工作流，再重跑本工作流")
        for w in up_auto:
            print(f"      {w} 已存在，保留不重建")
    else:
        for w in up_auto:
            if wf_code(pcode, w):
                print(f"      {w} 已存在，保留不重建")
                continue
            created_up.append(w)
            mem = [(t, script_of(t)) for t, c in cfgs.items()
                   if c["own_workflow"] == w and script_of(t)]
            b = int(time.time() * 1000) % 10 ** 9
            if not mem:
                # ★ 依赖表里该工作流名下没有带脚本的表（如 DWD_PUB = 公共层，其表都被标成「手工表」）。
                #   DS 不允许建 0 任务的工作流（50017 data [] not valid）⇒ 建一个**显式占位任务**，
                #   名字里带 placeholder，成功退出（不阻塞下游），但一眼能看出是缺口。
                print(f"      ⚠ {w} 名下 0 张带脚本的表 ⇒ 建占位任务（依赖表把它列为上游工作流）")
                tk = [build_task(b + 1, f"placeholder_{w}_暂无脚本",
                                 f'#!/bin/sh\necho "[警告] 工作流 {w} 尚未生成任何脚本，'
                                 f'本任务仅为占位；上游 {w} 的数据依赖实际未满足" >&2\nexit 0\n',
                                 f"{w} 占位（无脚本）")]
            else:
                # ★ 2026-10-22：改用共用的 ds_text.read_script（统一 CRLF→LF，
                #   避免 Windows 源的 CRLF 进 DS rawScript 后 Linux worker 报错）
                tk = [build_task(b + i + 1, t, read_script(p),
                                 cn_name(t)) for i, (t, p) in enumerate(mem)]
            cd = [x["code"] for x in tk]
            ls = [{"taskCode": c, "x": X0 + COL_W, "y": Y0 + i * ROW_H} for i, c in enumerate(cd)]
            wc = create_wf(pcode, w, f"DWD {w}（{len(mem)} 张表）", tk, [rel(0, c) for c in cd], ls)
            print(f"      {w}: {len(mem)} 张表 code={wc}")
        if created_up:
            sys.exit("★ 新建了上游工作流 %s——它们的作业 code 不在本次索引里，"
                     "跨工作流依赖会漏配。请重跑一次本工具（上游已存在、索引完整）"
                     % created_up)

    print("\n[3/5] 解析上游工作流 code")
    up_code = {}
    for w in sorted(up):
        c = wf_code(pcode, w)
        if not c:
            sys.exit(f"上游工作流 {w} 不存在（ODS 工作流请先跑 ds-deploy-ods-all.py）")
        up_code[w] = c
        print(f"      {w:24s} code={c}")

    print(f"\n[4/5] 创建 {args.workflow}")
    b = int(time.time() * 1000) % 10 ** 9
    code_of = {t: b + i + 1 for i, t in enumerate(members)}
    code_of.update({dep_of[t]: b + 5000 + i for i, t in enumerate(sorted(dep_of))})

    def build_all(self_code):
        """组装任务/连线/坐标。

        ★★★ `self_code` = **本工作流自己的 code**，只有 DEPENDENT_ON_TASK 需要它
        （依赖「本工作流内的某个任务」）。而 code 是 DS **建好之后**才分配的
        ⇒ 必须两遍走：① 先建（占位 0）→ ② PUT 回填真实 code。
        这条链路已用 `tools/ds-probe-selfdependent.py` 实测（POST→PUT→GET 回读 ✓，
        且 SERIAL_WAIT 下**不会**因为等后面的任务而死锁）。
        """
        def _raw_of(t):
            # ★ 2026-10-23（用户要求）：主数据（MASTER）**恢复正常脚本**，直接读
            #   scripts/MASTER/dwd/02_etl/ 下的脚本参与跑批（不再空跑占位）。
            #   旧口径（2026-10-15「跑 DWD 时主数据不跑」）用 --master-placeholder 回滚。
            #   优先级仍高于 empty_set（问题表占位）。
            p = script_of(t)
            if master_placeholder and p and p.replace("\\", "/").startswith(
                    (REPO.rstrip("/") + "/scripts/MASTER/")):
                return MASTER_EMPTY_TPL.format(t=t)
            # 问题表（编译/执行未通过）→ 空脚本占位，依赖边不动
            if t in empty_set:
                return EMPTY_TPL.format(t=t)
            if not p:
                sys.exit(f"❌ {LAYER} 表 {t} 缺少脚本（scripts/*/{LAYER.lower()}/02_etl/{t}.sh）")
            # ★ 2026-10-22：改用共用的 ds_text.read_script（统一 CRLF→LF 行尾）。
            #   原为 open(...).read() 原文内联，Windows 源的 CRLF 会带到 Linux
            #   worker 上报 bad interpreter / 命令未找到。
            return read_script(p)

        tk = [build_task(code_of[t], t, _raw_of(t),
                         cn_name(t)) for t in members]
        empty_hit = [t for t in members if t in empty_set]
        if empty_hit:
            print(f"      ⚠ {len(empty_hit)} 张表配空脚本（依赖边保留）："
                  + ", ".join(sorted(empty_hit)))
        if LAYER == "DWD" and master_placeholder:
            master_hit = [t for t in members
                          if (lambda p: p and p.replace("\\", "/").startswith(
                              (REPO.rstrip("/") + "/scripts/MASTER/")))(script_of(t))]
            if master_hit:
                print(f"      ★ {len(master_hit)} 张主数据（MASTER）占位不跑"
                      f"（脚本存档 scripts/MASTER/dwd/02_etl，2026-10-15 口径）")
        # ★★★ 2026-10-15 晚：跨工作流依赖不再有门禁。改为**作业级**
        #   DEPENDENT_ON_TASK 项，直接并进各表的 dep 节点（见下方组装）。
        # ★★★ 2026-10-15（用户要求）：归属本工作流的映射表（被本工作流表引用的
        #   编码映射/码表，无 ETL 脚本）建【空脚本占位任务】，并配**同工作流**
        #   依赖边（引用表 -> 映射表任务）——只配依赖、脚本给空，防止脚本不通过
        #   一直等待。跨工作流的映射表引用没有作业可等，跳过（作业级口径）。
        # map_ref 已在外层算好（dry-run 也能显示）；这里只分配 code
        map_code = {m: b + 7000 + i for i, m in enumerate(sorted(map_ref))}
        for m in sorted(map_ref):
            n_ref = len(map_ref[m])
            why = (f"被本工作流 {n_ref} 张表的 dep 节点依赖" if n_ref
                   else "暂无同工作流引用（占位，机制已就绪）")
            tk.append(build_task(map_code[m], m, MAP_EMPTY_TPL.format(t=m),
                                 f"映射表占位 {m}（无 ETL 脚本，空脚本保依赖，2026-10-15；{why}）"))
        n_same = 0
        for t in sorted(dep_of):
            # dep 节点装三类 **DEPENDENT_ON_TASK**：
            #   ① 同工作流前驱（definitionCode=本工作流自己，第二遍回填真实 code）
            #   ② 本工作流映射表占位任务
            #   ③ 跨工作流上游作业（definitionCode=上游工作流、dateValue=today；
            #      ODS 当天没跑就一直 WAITING——2026-10-15 晚用户拍板的批次语义）
            items = [{"projectCode": pcode, "definitionCode": self_code,
                      "depTaskCode": code_of[p], "cycle": "day", "dateValue": "today",
                      "dependentType": "DEPENDENT_ON_TASK", "parameterPassing": False}
                     for p in task_ref[t]]
            # 2026-10-15：映射表占位任务也并进本表的 dep 节点（一个作业一个依赖节点）
            items += [{"projectCode": pcode, "definitionCode": self_code,
                        "depTaskCode": map_code[m], "cycle": "day", "dateValue": "today",
                        "dependentType": "DEPENDENT_ON_TASK", "parameterPassing": False}
                       for m in tbl_map.get(t, [])]
            # 2026-10-15 晚：跨工作流作业级依赖并入（回归作业级口径）
            items += cross_items.get(t, [])
            n_same += len(items)
            tk.append(build_dep_task(code_of[dep_of[t]], dep_of[t], items))
        rs = [rel(code_of[a], code_of[bb]) for a, bb in all_edges]
        # 虚拟根 0 直连每个 dep 节点 / 无依赖表 / 映射表占位。
        # （0 的入边不能省，否则任务不进关系表、DS 建图误报 50019 cycle。）
        rs += [rel(0, code_of[d]) for d in sorted(dep_of.values())]
        rs += [rel(0, code_of[t]) for t in bare]
        # 映射表占位：根放行后跑（秒过）；引用关系已并入各表 dep 节点，
        # 不再画 map->表 直接边（一个作业一个 DEPENDENT 节点，DWD 格式）
        for m in sorted(map_ref):
            rs.append(rel(0, map_code[m]))
        # 坐标：布局原样；映射表占位放整张网格下方，避免与第一排重叠
        ls = [{"taskCode": code_of[n], "x": locs[n]["x"], "y": locs[n]["y"]}
              for n in nodes]
        y_max = max((locs[n]["y"] for n in nodes), default=Y0)
        for i, m in enumerate(sorted(map_ref)):
            ls.append({"taskCode": map_code[m], "x": X0 + COL_W * i, "y": y_max + ROW_H})
        return tk, rs, ls, n_same, len(map_ref)

    n_intra = sum(len(task_ref.get(t, ())) + len(tbl_map.get(t, ())) for t in dep_of)
    n_cross_all = sum(len(cross_items.get(t, ())) for t in members)
    desc = (f"{LAYER} {args.workflow}（{len(members)} 张表 + {len(dep_of)} 个依赖节点："
            f"同工作流/映射表 {n_intra} 项 + 跨工作流作业级 {n_cross_all} 项"
            + (f"；{len(bare)} 张表无依赖直连根" if bare else "") + "）")
    tk, rs, ls, n_same, n_map = build_all(0)   # 第一遍：占位
    wc = create_wf(pcode, args.workflow, desc, tk, rs, ls)
    print(f"      {args.workflow} code={wc}  任务 {len(tk)}  连线 {len(rs)}")
    if n_same:
        tk, rs, ls, _, _ = build_all(wc)       # 第二遍：回填自身 code
        up = call("PUT", f"/projects/{pcode}/workflow-definition/{wc}", form={
            "name": args.workflow, "description": desc, "globalParams": global_params(),
            "locations": json.dumps(ls), "timeout": 0, "tenantCode": TENANT,
            "taskRelationJson": json.dumps(rs),
            "taskDefinitionJson": json.dumps(tk, ensure_ascii=False),
            "executionType": EXEC, "releaseState": "OFFLINE"})
        if up.get("code") != 0:
            sys.exit(f"      ❌ 回填 DEPENDENT_ON_TASK 失败: "
                     f"{json.dumps(up, ensure_ascii=False)[:400]}")
        print(f"      第二遍 PUT 回填自身 code ✓（{n_same} 条依赖项含 self_code）")

    print("\n[5/5] 上线")
    for w in [args.workflow] + up_auto:
        c = wf_code(pcode, w)
        if c:
            res = call("POST", f"/projects/{pcode}/workflow-definition/{c}/release",
                       form={"releaseState": "ONLINE"})
            print(f"      {w}: {'ONLINE' if res.get('code') == 0 else '失败'}")
    print("\n完成。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
