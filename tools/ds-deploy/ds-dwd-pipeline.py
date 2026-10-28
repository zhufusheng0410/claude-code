#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""★★ DWD 全链管线：血缘梳理 → 调度依赖差异 → 调度依赖配置 → 调度排版，**一个脚本**。

为什么要有这个脚本（2026-10-16）
--------------------------------
这四件事以前散在 4 个入口 + 2 个临时核对脚本里，链路长、口径还容易漂：

    血缘梳理   docs/DWD血缘关系清单-*.xlsx / DWD血缘与ODS配置核对-*.xlsx
                （_build_lineage_inventory_xlsx.py + _check_lineage_vs_ods.py，两份 JSON）
    依赖差异   tools/_diff_expect_vs_ds.py（拿 _expect/*.json 与 DS 逐项 diff）
    依赖配置   ds-deploy/ds-build-dependent-from-lineage.py → tools/dep-config-lineage/*.dep.json
    部署+排版  ds-deploy/ds-deploy-dwd-workflow.py（重建）/_patch_pty_dep_nodes.py（手工增量）
                + ds-relayout.py dwd + ds-schedule.py switch --id … --online

副作用：一次口径变更要在脑子里串 5 步，中间任何一步没跑 → 「血缘改了、DS 没改」。

四条子命令（可单独跑，也可 `all` 一键）
--------------------------------------
  lineage   血缘梳理：读 4 份 DWD_lineage.xlsx → 去重分类 → ODS 就绪度
             → **中文名校验**（同名不同中文 / 同中文不同名，专治 VOU 脚本头注释污染）
  diff      调度依赖差异：血缘期望 vs dep.json(配置产物) vs DS 实际，**三方**比对，
             精确到每个 dep 节点的 dependItemList（definitionCode/depTaskCode 逐项）
  config    调度依赖配置：由血缘重新生成 dep.json（复用 build 逻辑，不重造轮子）。
             ★ 固定带 2026-10-16 用户口径的两张排除名单（CDVAL 码表 + 上一日分区边），
               缺它们会污染 96 张表的 mapping_deps（详见 stage_config 注释）。
  deploy    配置同步到 DS + 调度排版：**默认增量**只改差异 dep 节点（不重建工作流），
             改完自动 relayout + 恢复定时；`--rebuild` 才走整工作流重建

安全边界
--------
· 任何阶段都没有 `--apply` 就**绝不写任何东西**（DS 与 dep.json 都不动；config 的
  dry-run 重生到临时目录比对后即删）。
· 写之前自动备份：dep.json 整目录 + 各工作流定义 JSON。
· PUT 必带 locations / globalParams（单工作流 GET 实测会返回，元库作兜底）。
· 改定义必然级联把定时拍成 OFFLINE ⇒ 提交后按 **schedule id** 逐个补回
  （不用 `--prefix`，否则可能误开那 16 条故意 OFFLINE 的 ODS 定时）。
· 期望 dependItemList 为空的节点**不提交**、只告警（空依赖项在 DS 3.4.2 行为未定义）。

用法
----
    python ds-dwd-pipeline.py lineage                 # 只看血缘
    python ds-dwd-pipeline.py diff                    # 三方差异（不写任何东西）
    python ds-dwd-pipeline.py config                  # 重生计划（临时目录比对，**不碰现盘**）
    python ds-dwd-pipeline.py config --apply          # 备份 + 落盘 dep.json + 复算差异
    python ds-dwd-pipeline.py deploy                  # 增量同步（dry-run）
    python ds-dwd-pipeline.py deploy --apply          # 同步 + 排版 + 恢复定时
    python ds-dwd-pipeline.py all                     # 全链 dry-run 体检
    python ds-dwd-pipeline.py all --apply             # 一键：配置→同步→排版→恢复→报告

报告：`/mnt/d/datax/docs/DWD全链核对-<日期>-<时分>.xlsx`
      ★ --keep N 控制保留份数（默认 3）：超出的旧报告自动归档到
      `/mnt/d/datax/backup/docs-report-archive/`，防止 docs 一天攒几十份；--keep 0 = 不清理。
      JSON 明细在 `tools/_pipeline/latest.json`（不进 docs）。
"""
import argparse
import collections
import contextlib
import glob
import importlib.util
import io
import json
import os
import re
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ds_config import ds_admin_password, ds_admin_user, pg_conn  # noqa: E402
from ds_client import project_code  # noqa: E402
from ds_text import normalize_newlines  # noqa: E402


def _load(name, f):
    s = importlib.util.spec_from_file_location(name, os.path.join(HERE, f))
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


# 三个既有脚本作为「构件」，逻辑全部复用、不重抄（重抄=双份口径必漂）
D = _load("DWDDEPLOY", "ds-deploy-dwd-workflow.py")      # 布局 / job index / cross_items_for
B = _load("DSBUILD", "ds-build-dependent-from-lineage.py")  # dep.json 生成器
R = _load("DSRELAY", "ds-relayout.py")                   # 排版（DWD pair-grid）
SYNC = _load("DSSYNC", "ds-sync-dwd-scripts.py")         # 调度快照 / 恢复

REPO = os.environ.get("DW_REPO", D.REPO)
DEPCFG = os.environ.get("DW_DEPCFG", D.DEPCFG)
BACKUP = "/mnt/d/datax/backup/pipeline"
REPORT_DIR = os.environ.get("DW_REPORT_DIR", "/mnt/d/datax/docs")
REPORT_ARCHIVE = os.environ.get("DW_REPORT_ARCHIVE", "/mnt/d/datax/backup/docs-report-archive")
KEEP_REPORTS = 3
WORK = os.path.join(os.path.dirname(DEPCFG), "_pipeline")   # tools/_pipeline/
PCODE = None
SYS_ORDER = ["HSFA", "HSZTA", "MASTER", "O32", "HSFTA", "HSDS", "JY", "OA", "OFFW", "WIND"]


def log(*a):
    print(*a)


def rule(t=""):
    print(("─" * 78) + (("\n" + t) if t else ""))


# ---------------------------------------------------------------- 公共：血缘读取
def norm(t):
    s = str(t or "").strip()
    if "." in s:
        s = s.rsplit(".", 1)[-1]
    return s.upper()


SUFFIX_RE = re.compile(r"_(PTD|PFD|PTM|PFS)$", re.I)


def bare(t):
    return SUFFIX_RE.sub("", norm(t))


def load_lineage():
    """读 4 份 DWD_lineage.xlsx 的「表级血缘(扁平)」→ (pairs, meta, sys_of)"""
    pairs, meta, sys_of = set(), {}, {}
    for d in sorted(glob.glob(os.path.join(REPO, "scripts", "*", "dwd", "lineage"))):
        f = os.path.join(d, "DWD_lineage.xlsx")
        if not os.path.exists(f):
            continue
        sysn = os.path.basename(os.path.dirname(os.path.dirname(d)))
        import openpyxl
        ws = openpyxl.load_workbook(f, read_only=True, data_only=True)["表级血缘(扁平)"]
        rows = list(ws.iter_rows(values_only=True))
        for i, row in enumerate(rows):
            if i == 0:
                continue
            t, u = norm(row[0]) if row else "", norm(row[4]) if len(row) > 4 else ""
            if not t.startswith("DWD_") or not u or u in ("NAN", "NONE"):
                continue
            pairs.add((t, u))
            meta.setdefault(t, str(row[1]) if len(row) > 1 and row[1] else "")
            meta.setdefault(u, str(row[5]) if len(row) > 5 and row[5] else "")
            sys_of.setdefault(t, sysn)
            sys_of.setdefault(u, sysn)
    return pairs, meta, sys_of


def load_cfgs():
    return D.load_cfgs(DEPCFG)


_JOB_INDEX = None


def ds_job_index():
    """全项目作业索引：表名(大写) → (工作流名, 工作流code, 作业code)。

    只收 ods_/DWD_/MASTER_ 工作流里的 **SHELL** 任务（真实作业）。
    进程内缓存：一次 `all` 会在 lineage / diff / deploy / 报告里各取一次，
    每次都要 GET 全部工作流详情；作业 code 在增量同步中不变，取一遍即可。
    """
    global _JOB_INDEX
    if _JOB_INDEX is not None:
        return _JOB_INDEX
    P = pcode()
    idx = {}
    for it in D.wf_list(P) or []:
        nm, wc = it.get("name"), it.get("code")
        if not str(nm).startswith(("ods_", "DWD_", "MASTER_")):
            continue
        g = D.call("GET", f"/projects/{P}/workflow-definition/{wc}").get("data") or {}
        tds = g.get("taskDefinitionList") or []
        if isinstance(tds, str):
            tds = json.loads(tds)
        for t in tds:
            if t.get("taskType") != "SHELL":
                continue
            idx[str(t.get("name", "")).upper()] = (nm, wc, t.get("code"))
    _JOB_INDEX = idx
    return idx


def pcode():
    global PCODE
    if PCODE is None:
        res = D.call("GET", "/projects", params={"pageNo": 1, "pageSize": 100})
        PCODE = project_code(res, "dw")
    return PCODE


def schedule_ids_of(wcode):
    """该工作流派生/关联的定时 id 列表（级联下线后要逐个补回）。"""
    import psycopg2
    try:
        c = psycopg2.connect(**pg_conn())
        c.autocommit = True
        cur = c.cursor()
        cur.execute("select id from t_ds_schedules where workflow_definition_code=%s"
                    " order by id", (wcode,))
        out = [r[0] for r in cur.fetchall()]
        cur.close()
        c.close()
        return out
    except Exception as e:
        log(f"  ⚠ 查定时失败：{e}")
        return []


# ================================================================ stage 1 血缘梳理
def stage_lineage(args):
    rule("① 血缘梳理（scripts/*/dwd/lineage/DWD_lineage.xlsx）")
    pairs, meta, sys_of = load_lineage()
    lin_ods = {p for p in pairs if p[1].startswith("ODS_")}
    lin_dwd = pairs - lin_ods
    log(f"血缘 {len(pairs)} 边 = DWD→ODS {len(lin_ods)} + DWD→DWD {len(lin_dwd)}")
    log(f"覆盖系统：{sorted(set(sys_of.values()))}")

    # ---- 中文名校验（专治 VOU 脚本头注释污染）----
    cn_of = {}
    for (t, u) in pairs:
        if meta.get(t):
            cn_of.setdefault(t, set()).add(meta[t])
        if meta.get(u):
            cn_of.setdefault(u, set()).add(meta[u])
    multi_cn = {k: v for k, v in cn_of.items() if len(v) > 1}
    by_cn = collections.defaultdict(set)
    for t, s in cn_of.items():
        for c in s:
            by_cn[c].add(t)
    dwd_names = {t for t in cn_of if t.startswith("DWD_")}
    # ★ 只看 **DWD 层内**重名：VOU 污染就是 5 张 DWD 表共用一个中文名。
    #   DWD ↔ ODS 同名是常态（`证券信息表` 两家 ODS 都有），只作提示不告警。
    dup_cn = {c: sorted(ts) for c, ts in by_cn.items()
              if len([x for x in ts if x.startswith("DWD_")]) > 1}
    cross_cn = {c: sorted(ts) for c, ts in by_cn.items()
                if len(ts) > 1 and c not in dup_cn}
    log(f"中文名校验：DWD 层内重名 {len(dup_cn)} 处 / 一表多名 {len(multi_cn)} 处"
        f" / DWD↔ODS 同名 {len(cross_cn)} 处（后者为常态，仅提示）")
    for c, ts in sorted(dup_cn.items()):
        log(f"    ⚠ 中文名「{c}」被 {len(ts)} 张 DWD 表共用：{', '.join(ts)}")
    for t, s in sorted(multi_cn.items()):
        log(f"    ⚠ 表 {t} 出现多个中文名：{sorted(s)}")

    # ---- 目标表 / 上游 ODS 就绪度 ----
    job_index = ds_job_index()
    gen = set()
    for d in sorted(os.listdir(os.path.join(REPO, "scripts"))):
        p = os.path.join(REPO, "scripts", d, "ods", "ddl")
        if os.path.isdir(p):
            for f in os.listdir(p):
                if f.endswith(".sql"):
                    gen.add(f[:-4].upper())
    ods_tables = {u for (_, u) in lin_ods}
    ready = {t for t in ods_tables if t in gen and t in job_index}
    missing = sorted(ods_tables - ready)
    log(f"血缘引用 ODS 表 {len(ods_tables)} 张；已配好 {len(ready)} 张；"
        f"缺失 {len(missing)} 张：{', '.join(missing) or '无'}")
    for t in missing:
        log(f"    缺 {t}: 生成器DDL={'有' if t in gen else '无'} "
            f"DS作业={'有' if t in job_index else '无'}")

    cfgs = load_cfgs()
    own = {t: (cfgs.get(t, {}) or {}).get("own_workflow", "(无dep.json)")
           for t in sorted({t for t, _ in pairs})}
    out = {
        "pairs": sorted([list(p) for p in pairs]),
        "meta": {k: sorted(v) for k, v in cn_of.items()},
        "sys_of": sys_of,
        "summary": {
            "edges": len(pairs), "dwd_ods": len(lin_ods), "dwd_dwd": len(lin_dwd),
            "ods_tables": len(ods_tables), "ods_ready": len(ready),
            "ods_missing": missing,
            "cn_dup": dup_cn, "cn_multi": {k: sorted(v) for k, v in multi_cn.items()},
            "cn_cross": {k: v for k, v in cross_cn.items()},
            "target_tables": len({t for t, _ in pairs}),
        },
        "own_workflow": own,
    }
    _dump(out, "lineage.json")
    log(f"→ {os.path.join(WORK, 'lineage.json')}")
    return out


# ================================================================ stage 2 差异
def _items_of(task):
    """DS 里某个 dep 节点实际的 dependItemList → {(definitionCode, depTaskCode)}"""
    tp = task.get("taskParams")
    if isinstance(tp, str):
        try:
            tp = json.loads(tp)
        except Exception:
            tp = {}
    tp = tp or {}
    dep = tp.get("dependence") or {}
    out = []
    for grp in (dep.get("dependTaskList") or []):
        for it in (grp.get("dependItemList") or []):
            out.append((it.get("definitionCode"), it.get("depTaskCode")))
    return out


def expected_for(t, wf_name, cfgs, job_index, name2code_own, own_code, task_ref):
    """某张表的期望 dependItemList（与 ds-deploy-dwd-workflow.py 组装口径**逐字一致**）。

    三类，顺序与部署器相同：
      ① 同工作流前驱 —— 必须经过 `break_cycles` + `transitive_reduce`
         （dep.json 的 same_workflow_predecessors 是**血缘全量**，含传递冗余边；
          部署器的 `--same-wf dep-node` 只留归约后的，直接拿全量会虚报缺边）
      ② 本工作流映射表占位（mapping_deps 且 owner_workflow == 本工作流）
      ③ 跨工作流上游作业（D.cross_items_for，采信 DS 现实）
    返回 (set((definitionCode, depTaskCode)), [异常原因])。
    """
    items, why = [], []
    # ① 同工作流前驱（传递归约后）
    for p in task_ref.get(t, []):
        if p in name2code_own:
            items.append((own_code, name2code_own[p]))
        else:
            why.append(f"同流前驱 {p} 在本工作流无作业")
    # ② 映射表占位（只收归属本工作流的；DWD_CMM 的 CDVAL_MAP 不在本流）
    for m in (cfgs[t].get("mapping_deps") or []):
        nm = norm(m.get("source") if isinstance(m, dict) else m)
        owner = (m.get("owner_workflow") if isinstance(m, dict) else None) or wf_name
        if owner != wf_name:
            continue
        if nm in name2code_own:
            items.append((own_code, name2code_own[nm]))
        else:
            why.append(f"映射表 {nm} 占位任务不存在")
    # ③ 跨工作流上游作业
    for it in D.cross_items_for(t, wf_name, cfgs, job_index, pcode())[0]:
        items.append((it.get("definitionCode"), it.get("depTaskCode")))
    return set(items), why


@contextlib.contextmanager
def _quiet():
    """D.plan() 会打一串汇总，比对阶段只需要结果 ⇒ 临时吞掉。"""
    buf = io.StringIO()
    old = sys.stdout
    sys.stdout = buf
    try:
        yield
    finally:
        sys.stdout = old


def plan_ref(wf_name, cfgs):
    """复用部署器的 plan()：members / 传递归约后的同工作流边 / 破环丢弃数。"""
    with _quiet():
        members, edges, dropped, trimmed, up, tbl2up, inherited = D.plan(
            wf_name, cfgs, {}, inherit=False)
    task_ref = {t: sorted({a for a, b in edges if b == t}) for t in members}
    return members, task_ref, dropped, trimmed


def stage_diff(args, quiet=False, label="② 调度依赖差异（血缘 vs dep.json vs DS 实际，逐节点）"):
    rule(label)
    cfgs = load_cfgs()
    job_index = ds_job_index()
    P = pcode()
    wf_map = {t: (cfgs.get(t, {}) or {}).get("own_workflow") for t in cfgs}

    by_wf = collections.defaultdict(set)
    for t, w in wf_map.items():
        if w:
            by_wf[w].add(t)

    # ---- DS 实际 ----
    wf_lookup = {x["name"]: x for x in (D.wf_list(P) or [])}
    ds_actual = {}      # (wf, depnode) -> set(items)
    ds_nodes = {}
    anomalies = []
    for w, tables in sorted(by_wf.items()):
        it = wf_lookup.get(w)
        if not it:
            anomalies.append([w, "", "工作流在 DS 不存在"])
            continue
        g = D.call("GET", f"/projects/{P}/workflow-definition/{it['code']}").get("data") or {}
        tds = g.get("taskDefinitionList") or []
        n2c = {str(t.get("name", "")).upper(): t.get("code") for t in tds}
        ds_nodes[w] = (it["code"], n2c)
        for t in tds:
            if t.get("taskType") == "DEPENDENT":
                ds_actual[(w, str(t.get("name", "")))] = set(_items_of(t))

    # ---- 期望（每工作流一次 D.plan()，保证与部署器口径逐字一致）----
    miss, extra, wf_dirty = [], [], collections.defaultdict(list)
    for w, tables in sorted(by_wf.items()):
        own_code, n2c = ds_nodes.get(w, (None, {}))
        if own_code is None:
            continue
        _, task_ref, dropped, trimmed = plan_ref(w, cfgs)
        for t in sorted(tables):
            node = "dep_" + t
            exp, why = expected_for(t, w, cfgs, job_index, n2c, own_code, task_ref)
            act = ds_actual.get((w, node))
            if act is None:
                anomalies.append([w, node, "DS 无此 dep 节点"])
                continue
            if not exp:
                anomalies.append([w, node, "期望 dependItemList 为空："
                                 + ("; ".join(why) or "无任何可等上游")])
                continue
            m, e = exp - act, act - exp
            if m:
                miss.append([w, t, sorted(m), sorted(e)])
                wf_dirty[w].append(t)
            elif e:
                extra.append([w, t, [], sorted(e)])
                wf_dirty[w].append(t)

    # ---- 血缘 vs dep.json ----
    lin_pairs, _, _ = load_lineage()
    cfg_pairs = set()
    for t, c in cfgs.items():
        for g in c.get("cross_workflow") or []:
            for s in g.get("sources") or []:
                cfg_pairs.add((norm(t), norm(s.get("source"))))
        for s in c.get("same_workflow_predecessors") or []:
            cfg_pairs.add((norm(t), norm(s if isinstance(s, str) else s.get("source"))))
        for s in c.get("mapping_deps") or []:
            cfg_pairs.add((norm(t), norm(s.get("source") if isinstance(s, dict) else s)))
    lin_cfg_gap = sorted(lin_pairs - cfg_pairs)
    cfg_lin_gap = sorted(cfg_pairs - lin_pairs)

    log(f"dep.json 覆盖 {len(cfgs)} 张表；血缘 {len(lin_pairs)} 边 / dep.json {len(cfg_pairs)} 边")
    log(f"血缘有/配置无 {len(lin_cfg_gap)} 条；配置有/血缘无 {len(cfg_lin_gap)} 条")
    log(f"DS 节点差异：缺 {sum(len(m[2]) for m in miss)} 项 / 多 "
        f"{sum(len(m[3]) for m in miss) + sum(len(e[3]) for e in extra)} 项"
        f"，涉及 {len(wf_dirty)} 个工作流：{', '.join(sorted(wf_dirty)) or '无'}")
    for w, ts in sorted(wf_dirty.items()):
        log(f"  {w}: {', '.join(ts)}")
    for a in anomalies:
        log(f"  ⚠ 异常 [{a[0]}] {a[1]}: {a[2]}")
    if not miss and not extra and not anomalies:
        log("  ✅ 血缘 / dep.json / DS 三方一致（除下列口径性缺口外）")

    out = {"miss": miss, "extra": extra, "anomalies": anomalies,
           "lin_cfg_gap": [list(x) for x in lin_cfg_gap],
           "cfg_lin_gap": [list(x) for x in cfg_lin_gap],
           "dirty_workflows": sorted(wf_dirty)}
    if not quiet:
        _dump(out, "diff.json")
        log(f"→ {os.path.join(WORK, 'diff.json')}")
    return out


# ================================================================ stage 3 依赖配置
# ★ 2026-10-16 用户口径：血缘 → dep.json 必须带的两张「排除名单」（缺一即污染配置）
#   ① `--exclude-table DWD_CMM_STD_DICT_CDVAL_MAP`：码表/维表，不是每日批次产物，
#      却几乎被所有 DWD 脚本 JOIN ⇒ 剔「它作上游」的边，否则 96 张表的 mapping_deps
#      全挂上它（2026-10-16 实测：不带该开关重生 → mapping_deps 0→96，cfg_pairs 445→541）。
#   ② `--exclude-prev-day`：脚本读「上一日分区」的边等的是上游昨天的实例，当日实例
#      满足不了 ⇒ 整条剔除（名单由 tools/_scan_prev_day_deps.py 扫描脚本产出）。
#   ★ 教训：`tools/_diff_depcfg.py` 的 ups() 只数 cross+same、**不数 mapping_deps**
#     ⇒ 早前一次不带开关的重生污染了 mapping_deps 却报「0 份变化」。审核 dep.json
#     必须把 mapping_deps 算进去（本脚本 _cfg_sig 已覆盖）。
DEFAULT_EXCLUDE_TABLE = "DWD_CMM_STD_DICT_CDVAL_MAP"
DEFAULT_PREV_DAY = os.path.join(HERE, "_legacy", "_prev_day_deps.json")
# 与《DWD血缘关系清单-v4》的 EXCLUDE_TABLE 保持一致（报告排除原因措辞对齐用）
EXCLUDE_TABLE_SET = {DEFAULT_EXCLUDE_TABLE}


def _gen_flags(args):
    fl = []
    xt = getattr(args, "exclude_table", "") or ""
    if xt:
        fl += ["--exclude-table", xt]
    pf = getattr(args, "exclude_prev_day", "") or ""
    if pf and os.path.exists(pf):
        fl += ["--exclude-prev-day", pf]
    elif pf:
        log(f"  ⚠ 上一日清单不存在，跳过该排除：{pf}")
    return fl


def _cfg_sig(d):
    """dep.json 语义签名：跨流 + 同流 + 映射占位（mapping_deps 必须算，勿重蹈 10-16 覆辙）。"""
    cross = set()
    for g in (d.get("cross_workflow") or []):
        for s in (g.get("sources") or []):
            cross.add((g.get("workflow"), str(s.get("source")).upper()))
    same = tuple(sorted(str(s.get("source") if isinstance(s, dict) else s).upper()
                        for s in (d.get("same_workflow_predecessors") or [])))
    md = tuple(sorted((str(m.get("source")).upper(), m.get("owner_workflow"))
                      for m in (d.get("mapping_deps") or [])))
    return (frozenset(cross), same, md)


def _regen(flags, out_dir=None):
    """调生成器 B.main() 重生 dep.json。out_dir 非空 ⇒ 重生到临时目录（dry-run，不碰现场）。"""
    old_out, old_argv = B.OUT, sys.argv
    if out_dir:
        B.OUT = out_dir
    sys.argv = ["ds-build-dependent-from-lineage.py"] + flags
    try:
        B.main()
    finally:
        sys.argv = old_argv
        B.OUT = old_out


def _cmp_dirs(a, b):
    """两份 dep.json 目录语义比对 → (变更表列表, 每项 diff 描述)。"""
    fa = {os.path.basename(p)[:-9]: p for p in glob.glob(os.path.join(a, "*.dep.json"))}
    fb = {os.path.basename(p)[:-9]: p for p in glob.glob(os.path.join(b, "*.dep.json"))}
    out = []
    for t in sorted(set(fa) | set(fb)):
        if t not in fa:
            out.append((t, "仅新生有")); continue
        if t not in fb:
            out.append((t, "仅现盘有")); continue
        sa, sb = _cfg_sig(json.load(open(fa[t], encoding="utf-8"))), \
                 _cfg_sig(json.load(open(fb[t], encoding="utf-8")))
        if sa == sb:
            continue
        desc = []
        if sa[0] != sb[0]:
            desc.append(f"跨流 +{len(sa[0]-sb[0])}/-{len(sb[0]-sa[0])}")
        if sa[1] != sb[1]:
            desc.append(f"同流 +{len(set(sa[1])-set(sb[1]))}/-{len(set(sb[1])-set(sa[1]))}")
        if sa[2] != sb[2]:
            desc.append(f"映射占位 +{len(set(sa[2])-set(sb[2]))}/-{len(set(sb[2])-set(sa[2]))}"
                        f"（如 {sorted(set(sa[2])-set(sb[2]))[:2]}）")
        out.append((t, "；".join(desc)))
    return out


def stage_config(args):
    rule("③ 调度依赖配置（血缘 → dep.json）")
    flags = _gen_flags(args)
    if flags:
        log(f"排除名单（2026-10-16 用户口径）：{' '.join(flags)}")
    else:
        log("⚠ 未带任何排除名单——将生成含 CDVAL/上一日边的污染配置（勿用于 --apply）")
    if args.apply:
        os.makedirs(BACKUP, exist_ok=True)
        dst = os.path.join(BACKUP, "depcfg-%s" % time.strftime("%Y%m%d-%H%M%S"))
        if os.path.isdir(DEPCFG):
            shutil.copytree(DEPCFG, dst)
            log(f"已备份现盘 dep.json {len(glob.glob(os.path.join(DEPCFG, '*.dep.json')))} 份 → {dst}")
        _regen(flags)
        log("dep.json 已刷新（落盘）")
    else:
        # dry-run：重生到临时目录后与现盘语义比对，**不碰现场**
        #   ★ 固定名（每次覆盖，不堆积）；清理放在比对之后且**绝不让它中断流程**——
        #     本机安全删除机制会拦截「进程内一次性删 >50 文件」（rmtree 被 kill 过，
        #     2026-10-16 实测），故 best-effort：删不掉就留下并提示，下轮自动覆盖。
        tmp = os.path.join(WORK, "depcfg-dryrun-latest")
        os.makedirs(WORK, exist_ok=True)
        try:
            _regen(flags, out_dir=tmp)
            chg = _cmp_dirs(tmp, DEPCFG)
        except Exception as e:
            log(f"  ✗ 重生/比对失败：{e}")
            return stage_diff(args, quiet=True)
        if chg:
            log(f"将改动 {len(chg)} 份 dep.json（现盘未动，--apply 才落盘）：")
            for t, d in chg[:15]:
                log(f"    {t}: {d}")
            if len(chg) > 15:
                log(f"    ……另 {len(chg)-15} 份")
        else:
            log("✅ 重生结果与现盘语义一致，无需 --apply")
        # ★ 不自动删临时目录：本机安全删除机制按「轮」限额（>50 文件/轮即拦截，且会
        #   **直接 kill 进程**，try/except 都拦不住——2026-10-16 两次实测），故 dry-run
        #   只留固定名目录、下轮自动覆盖；清理在 shell 里 `rm -rf`（回收站通道 + 换轮有额度）。
        log(f"  ℹ 临时重生目录：{tmp}（下轮自动覆盖；清理：rm -rf 该目录）")
    return stage_diff(args, quiet=True, label="③-a 配置后复算差异（血缘 vs dep.json vs DS 实际，逐节点）")


# ================================================================ stage 4 部署+排版
def stage_deploy(args):
    rule("④ 配置同步到 DS + 调度排版")
    d = stage_diff(args, quiet=True, label="④-a 依赖差异（增量同步前先算清）")
    dirty = set(d["dirty_workflows"])
    if d["anomalies"]:
        for a in d["anomalies"]:
            log(f"  ⚠ [{a[0]}] {a[1]}: {a[2]}")
    if args.rebuild:
        log("⚠ --rebuild：整工作流删建（task code 重分配，跨流引用会悬空）")
        dirty = {str(x["name"]) for x in (D.wf_list(pcode()) or [])
                 if str(x["name"]).startswith("DWD_")}
    if not dirty:
        log("✅ 无需同步：DS 与 dep.json 已一致。排版仍会按需执行（见下）。")
    else:
        log(f"待同步工作流 {len(dirty)} 个：{', '.join(sorted(dirty))}")

    # ---------- 增量同步 dep 节点 ----------
    P = pcode()
    wf_lookup = {x["name"]: x for x in (D.wf_list(P) or [])}
    cfgs = load_cfgs()
    job_index = ds_job_index()
    commits = []

    for w in sorted(dirty | set(d["dirty_workflows"])):
        it = wf_lookup.get(w)
        if not it:
            log(f"  ✗ {w} 不在 DS"); continue
        own_code = it["code"]
        g = D.call("GET", f"/projects/{P}/workflow-definition/{own_code}").get("data") or {}
        wfd = g.get("workflowDefinition") or {}
        tds = g.get("taskDefinitionList") or []
        if isinstance(tds, str):
            tds = json.loads(tds)
        rels = g.get("taskRelationList") or g.get("workflowTaskRelationList") or []
        if isinstance(rels, str):
            rels = json.loads(rels)
        n2c = {str(t.get("name", "")).upper(): t.get("code") for t in tds}
        name2task = {str(t.get("name", "")): t for t in tds}

        changed = 0
        for t in sorted(cfgs):
            if (cfgs.get(t, {}) or {}).get("own_workflow") != w:
                continue
            node = "dep_" + t
            task = name2task.get(node)
            if task is None or task.get("taskType") != "DEPENDENT":
                continue
            exp, why = expected_for(t, cfgs, job_index, n2c, own_code)
            act = set(_items_of(task))
            if not exp:
                log(f"  ⚠ {node}: 期望为空，跳过（{'; '.join(why) or '无可等上游'}）")
                continue
            if exp == act:
                continue
            tp = task.get("taskParams")
            was_str = isinstance(tp, str)
            if was_str:
                tp = json.loads(tp)
            tp = tp or {}
            dep = tp.get("dependence") or {}
            grp = (dep.get("dependTaskList") or [{}])[0]
            items = grp.get("dependItemList") or []
            proto = {"projectCode": P, "cycle": "day", "dateValue": "today",
                     "dependentType": "DEPENDENT_ON_TASK", "parameterPassing": False}
            if items:
                proto.update({k: v for k, v in items[0].items()
                              if k in ("projectCode", "cycle", "dateValue",
                                       "dependentType", "parameterPassing")})
            keep = [it2 for it2 in items if (it2.get("definitionCode"),
                                             it2.get("depTaskCode")) not in exp]
            for dc, tc in sorted(exp - act):
                ni = dict(proto)
                ni["definitionCode"], ni["depTaskCode"] = dc, tc
                keep.append(ni)
            grp["dependItemList"] = keep
            dep["dependTaskList"] = [grp]
            tp["dependence"] = dep
            task["taskParams"] = json.dumps(tp, ensure_ascii=False) if was_str else tp
            changed += 1
            log(f"    {node}: {len(act)} → {len(keep)} 项")

        if args.rebuild:
            log(f"  [rebuild] {w}: 走 ds-deploy-dwd-workflow.py（自动备份+重建）")
            continue
        if not changed:
            log(f"  {w}: 无节点差异")
            continue
        if not args.apply:
            log(f"  [dry-run] {w}: 拟改 {changed} 个 dep 节点，未提交")
            continue

        sched_ids = schedule_ids_of(own_code)
        commits.append((w, own_code))
        # 备份
        os.makedirs(BACKUP, exist_ok=True)
        bf = os.path.join(BACKUP, "wfdef-%s-%s-%s.json" % (
            w, time.strftime("%Y%m%d-%H%M%S"), own_code))
        json.dump(g, open(bf, "w", encoding="utf-8"), ensure_ascii=False,
                  indent=1, default=str)
        log(f"    备份定义 → {bf}")

        # ★ locations/globalParams 必须带上，否则布局与 p_end_dt 被清空
        locs = wfd.get("locations")
        if isinstance(locs, str):
            try:
                locs = json.loads(locs)
            except Exception:
                locs = []
        gp = wfd.get("globalParams")
        if not isinstance(gp, str):
            gp = json.dumps(gp or [])
        ET = {"PARALLEL": "PARALLEL", "SERIAL_WAIT": "SERIAL_WAIT",
              "SERIAL_DISCARD": "SERIAL_DISCARD", "SERIAL_PRIORITY": "SERIAL_PRIORITY"}
        D.call("POST", f"/projects/{P}/workflow-definition/{own_code}/release",
               form={"releaseState": "OFFLINE"})
        # ★ 2026-10-22 修 bug（评审 HIGH-3）：原实现把 release ONLINE 放在
        #   `finally` 里**无条件**执行 ⇒ PUT 失败（依赖 code 未解析 / DS 返回 500）
        #   时虽然 raise 了 RuntimeError，但工作流仍被置 ONLINE —— 线上留下
        #   「定义残缺却可调度」的工作流，跑批时才不可预期地失败。
        #   另：原判定 `code not in (0, "0", None)` 把**缺失返回码 None 当成功**，
        #   PUT 实际失败也会走进「成功」分支。
        #   ⇒ 改为：仅 code == 0 才上线；否则保持 OFFLINE 并向上抛。
        up = D.call("PUT", f"/projects/{P}/workflow-definition/{own_code}", form={
            "name": w, "description": wfd.get("description") or "",
            "globalParams": gp, "locations": json.dumps(locs),
            "timeout": wfd.get("timeout") or 0,
            "tenantCode": wfd.get("tenantCode") or "dolphinscheduler",
            "taskRelationJson": json.dumps(rels),
            "taskDefinitionJson": json.dumps(tds, ensure_ascii=False),
            "executionType": wfd.get("executionType") or "SERIAL_WAIT",
            "releaseState": "OFFLINE"})
        if up.get("code") not in (0, "0"):
            log(f"    ✗ PUT 失败（code={up.get('code')!r}），保持 OFFLINE："
                f"{json.dumps(up, ensure_ascii=False)[:300]}")
            raise RuntimeError("PUT 失败 %s" % json.dumps(up, ensure_ascii=False)[:300])
        log(f"    PUT ok（{changed} 个 dep 节点）")
        D.call("POST", f"/projects/{P}/workflow-definition/{own_code}/release",
               form={"releaseState": "ONLINE"})

    # ---------- 排版 ----------
    if args.no_layout:
        log("（--no-layout：跳过排版）")
    else:
        rule("④-b 调度排版（ds-relayout dwd：3 列前置依赖 + 3 列作业）")
        import types
        ns = types.SimpleNamespace(apply=args.apply, only=",".join(sorted(
            dirty | set(d["dirty_workflows"]))) if dirty else "",
            force=args.force, col_w=D.COL_W)
        try:
            R.cmd_dwd(ns)
        except Exception as e:
            log(f"  ⚠ 排版失败：{e}")

    # ---------- 恢复定时 ----------
    if args.apply and commits:
        rule("④-c 恢复定时（改定义级联下线，按 schedule id 补回）")
        for w, own_code in commits:
            ids = schedule_ids_of(own_code)
            if not ids:
                log(f"  {w}: 无关联定时")
                continue
            # ★ 2026-10-22（评审 C2 延伸）：原用 os.system 拼串 → 走 shell 解析。
            #   虽然插入值目前都是整数/已知路径，但 `os.system` 的模式本身是注入面。
            #   ⇒ 改用 subprocess.run 的**列表参数**（不经 shell），并检查返回码。
            cmd = [sys.executable, os.path.join(HERE, "ds-schedule.py"),
                   "switch", "--id", ",".join(str(i) for i in ids),
                   "--online", "--apply"]
            r = subprocess.run(cmd, capture_output=True, text=True,
                               errors="replace")
            if r.returncode != 0:
                log(f"  ⚠ {w}: 定时 {ids} 恢复 ONLINE 失败（rc={r.returncode}）："
                    f"{(r.stderr or r.stdout or '')[:200]}")
            else:
                log(f"  {w}: 定时 {ids} → ONLINE")

    # ---------- 回读 ----------
    if args.apply:
        rule("④-d 回读校验")
        d2 = stage_diff(args, quiet=True)
        n_dirty = len(d2["dirty_workflows"])
        log(f"回读：仍有差异的工作流 {n_dirty} 个"
            + (" ✅" if not n_dirty and not d2["anomalies"] else " ⚠ 见 diff.json"))
        return d2
    return d


# ================================================================ 报告
def _dump(obj, name):
    os.makedirs(WORK, exist_ok=True)
    json.dump(obj, open(os.path.join(WORK, name), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1, default=str)


def prune_reports(keep):
    """只保留 REPORT_DIR 里最新的 keep 份 `DWD全链核对-*.xlsx`，其余移到归档目录。

    keep <= 0 = 不清理。文件名内嵌 YYYYMMDD-HHMM（定宽）⇒ 按名排序即按时间排序。
    """
    if keep <= 0:
        return
    files = sorted(glob.glob(os.path.join(REPORT_DIR, "DWD全链核对-*.xlsx")))
    excess = files[:-keep] if len(files) > keep else []
    if not excess:
        return
    os.makedirs(REPORT_ARCHIVE, exist_ok=True)
    for f in excess:
        dst = os.path.join(REPORT_ARCHIVE, os.path.basename(f))
        if os.path.exists(dst):
            stem, ext = os.path.splitext(os.path.basename(f))
            dst = os.path.join(REPORT_ARCHIVE, "%s_%s%s"
                               % (stem, time.strftime("%H%M%S"), ext))
        try:
            shutil.move(f, dst)
            log(f"  旧报告归档 → {dst}")
        except Exception as e:
            log(f"  ⚠ 旧报告归档失败（{os.path.basename(f)}）：{e}")


def build_report(stages, keep=None):
    """把各 stage 的结果汇成一个 Excel（多 sheet）。"""
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Font, PatternFill
    from openpyxl.utils import get_column_letter

    wb = Workbook()
    HDR = PatternFill("solid", fgColor="1F4E79")
    HF = Font(color="FFFFFF", bold=True, size=11)
    TF = Font(bold=True, size=13, color="1F4E79")
    WARN = PatternFill("solid", fgColor="FCE4D6")
    OK = PatternFill("solid", fgColor="E2EFDA")
    NF = Font(size=9, color="666666")

    def _cell(v):
        """openpyxl 不接受 tuple / set / dict ⇒ 统一转可读字符串。"""
        if isinstance(v, (tuple, set, list)):
            return ", ".join(_cell(x) for x in v)
        if isinstance(v, dict):
            return json.dumps(v, ensure_ascii=False)
        return v

    def sheet(name, headers, rows, widths, notes=None, fill=None, title=None):
        ws = wb.create_sheet(name[:28])
        ws.append([title or name]); ws.cell(row=1, column=1).font = TF
        ws.append([])
        for c, h in enumerate(headers, 1):
            cell = ws.cell(row=3, column=c, value=h)
            cell.fill = HDR; cell.font = HF
            cell.alignment = Alignment(horizontal="center", wrap_text=True)
        for r in rows:
            ws.append([_cell(x) for x in r])
            if fill:
                f = fill(r)
                if f:
                    for c in range(1, len(headers) + 1):
                        ws.cell(row=ws.max_row, column=c).fill = f
        for i, w in enumerate(widths, 1):
            ws.column_dimensions[get_column_letter(i)].width = w
        ws.freeze_panes = ws.cell(row=4, column=1)
        if notes:
            ws.append([])
            for n in notes:
                ws.append([n]); ws.cell(row=ws.max_row, column=1).font = NF
        return ws

    # ① 结论（版式/行项/措辞与《DWD血缘关系清单-*-v4.xlsx》对齐，两边可对照读）
    lin = stages.get("lineage", {})
    dif = stages.get("deploy", stages.get("diff", {}))
    pairs, meta, sys_of = load_lineage()
    cfgs = load_cfgs()
    prev_set = set()
    if os.path.exists(DEFAULT_PREV_DAY):
        prev_set = {(norm(a), norm(b)) for a, b, *_ in
                    json.load(open(DEFAULT_PREV_DAY, encoding="utf-8")).get("edges", [])}
    cfg_edges, own = set(), {}
    for t, c in cfgs.items():
        own[t] = (c or {}).get("own_workflow", "")
        for g in c.get("cross_workflow") or []:
            for s2 in g.get("sources") or []:
                cfg_edges.add((t, norm(s2.get("source"))))
        for s2 in c.get("same_workflow_predecessors") or []:
            cfg_edges.add((t, norm(s2.get("source") if isinstance(s2, dict) else s2)))
    # 排除原因：与 _build_lineage_inventory_xlsx.py **同一套措辞**（命中多条都写出来）
    excl = []
    for t, u in sorted(pairs):
        if (t, u) in cfg_edges:
            continue
        rs = []
        if u in EXCLUDE_TABLE_SET:
            rs.append("码表（用户口径 2026-10-16）")
        if (t, u) in prev_set:
            rs.append("上一日分区依赖（读 P_DT=p_end_dt-1）")
        if not rs:
            if not B.script_of(t):
                rs.append("目标表无 ETL 脚本")
            else:
                rs.append("破环切断/映射表规则/无法解析上游所在工作流")
        excl.append([t, u, "ODS" if u.startswith("ODS_") else ("DWD" if u.startswith("DWD_") else "其它"),
                     "排除：" + " + ".join(rs)])
    n_inc = len(pairs) - len(excl)
    # ---- v4 版式所需数据：上游就绪度 + 表级血缘全量行 + 上游表清单行 ----
    #    就绪度口径与 stage_lineage / v4 一致：ODS = 生成器DDL ∩ DS作业；DWD = 有 ETL 脚本。
    job_index = ds_job_index()
    gen = set()
    _sd = os.path.join(REPO, "scripts")
    for _d in sorted(os.listdir(_sd)):
        _p = os.path.join(_sd, _d, "ods", "ddl")
        if os.path.isdir(_p):
            for _f in os.listdir(_p):
                if _f.endswith(".sql"):
                    gen.add(_f[:-4].upper())

    def _ready(u):
        if u.startswith("ODS_"):
            return "已配好" if (u in gen and u in job_index) else "未配好"
        if u.startswith("DWD_"):
            return "有脚本" if B.script_of(u) else "无脚本"
        return "-"

    excl_map = {(e[0], e[1]): e[3] for e in excl}
    lin_rows = []
    for t, u in sorted(pairs):
        in_cfg = (t, u) in cfg_edges
        lin_rows.append([t, meta.get(t, ""), own.get(t, "(无配置)"), u, meta.get(u, ""),
                         "ODS" if u.startswith("ODS_") else ("DWD" if u.startswith("DWD_") else "其它"),
                         _ready(u), "是" if in_cfg else "否",
                         "" if in_cfg else excl_map.get((t, u), ""),
                         sys_of.get(t, "")])
    up_stat = collections.Counter(u for _, u in pairs)
    up_rows = []
    for u, n in up_stat.most_common():
        refs = sorted({t for t, uu in pairs if uu == u})
        up_rows.append([u, "ODS" if u.startswith("ODS_") else ("DWD" if u.startswith("DWD_") else "其它"),
                        _ready(u), n,
                        ",".join(refs[:8]) + ("…" if len(refs) > 8 else "")])
    s = lin.get("summary", {})
    # ★ `diff` 单独跑时 stages 里没有 lineage ⇒ summary 空；从上次 stage_lineage
    #   的产物 _pipeline/lineage.json 回填（中文名核对等地还要用）。
    if not s:
        _lj = os.path.join(WORK, "lineage.json")
        if os.path.exists(_lj):
            with open(_lj, encoding="utf-8") as _f:
                s = (json.load(_f) or {}).get("summary", {}) or {}
    # ★ 结论页的汇总数一律**从 pairs 现算**（不依赖 stage_lineage 是否跑过）——
    #   否则 `diff` 单独跑时 lin={} ⇒ 这些格子是 None（2026-10-16 实测）。
    n_lin_ods = sum(1 for _, u in pairs if u.startswith("ODS_"))
    n_lin_dwd = sum(1 for _, u in pairs if u.startswith("DWD_"))
    ods_ref = {u for _, u in pairs if u.startswith("ODS_")}
    ods_missing_c = sorted(t for t in ods_ref if _ready(t) == "未配好")
    rows = [
        ["血缘表级关系总数", len(pairs), "4 份 DWD_lineage.xlsx（HSFA/HSZTA/MASTER/O32）去重后"],
        ["　其中 DWD→ODS", n_lin_ods, ""],
        ["　其中 DWD→DWD", n_lin_dwd, "映射表/主题内依赖"],
        ["★ 最终纳入依赖配置", n_inc, "写入 dep.json 的边（跨流 + 同流）"],
        ["★ 被排除", len(excl), "见「排除项明细」sheet"],
        ["　- 码表 CDVAL_MAP", sum(1 for e in excl if e[3].startswith("排除：码表")),
         "用户口径：配置依赖时去掉"],
        ["　- 上一日分区依赖", sum(1 for e in excl if e[3].startswith("排除：上一日")),
         "用户口径：全部去掉"],
        ["dep.json 份数", len(cfgs), "覆盖表数"],
        ["DWD 工作流数", len({v for v in own.values() if str(v).startswith("DWD_")}), ""],
        ["上游表去重数", len({u for _, u in pairs}), ""],
        ["目标 DWD 表数", len({t for t, _ in pairs}), "去重后"],
        ["血缘引用 ODS 表", len(ods_ref), "已配好 %d / 缺失 %d"
         % (len(ods_ref) - len(ods_missing_c), len(ods_missing_c))],
        ["ODS 缺失清单", ", ".join(ods_missing_c) or "无",
         "缺一即未配好（生成器 DDL ∩ DS 作业）；注意≠依赖没配（占位作业可被依赖）"],
        ["DS 缺依赖项", sum(len(m[2]) for m in dif.get("miss") or []), "按 (工作流, 任务) 计"],
        ["DS 多依赖项", sum(len(m[3]) for m in dif.get("miss") or []) + sum(
            len(e[3]) for e in dif.get("extra") or []), "同上"],
        ["仍有差异的工作流", ", ".join(dif.get("dirty_workflows") or []) or "无",
         "空 = 血缘 / dep.json / DS 三方一致"],
        ["中文名层内重名", len(s.get("cn_dup") or {}), "只算 DWD 层内；DWD↔ODS 同名是常态"],
    ]
    sheet("结论", ["项目", "数值", "说明"], rows, [26, 12, 62],
          title="DWD 全链核对（%s 重解析）" % time.strftime("%Y-%m-%d"),
          notes=["生成：ds-dwd-pipeline.py（血缘梳理→差异→配置→同步→排版 全链）",
                 "解析命令：ds-build-dependent-from-lineage.py --exclude-table DWD_CMM_STD_DICT_CDVAL_MAP "
                 "--exclude-prev-day tools/_prev_day_deps.json",
                 "版式与《DWD血缘关系清单-*-v4.xlsx》对齐（结论/表级血缘全量/按工作流汇总/排除项明细/上游表清单），"
                 "后三个 sheet（依赖差异明细/异常告警/中文名核对）为本管线特有。",
                 "未加 --apply 时所有数字都是 dry-run 预演，DS 与 dep.json 均未改动。"],
          fill=lambda r: WARN if str(r[0]).startswith("★") else None)

    # ② 表级血缘全量（v4 同名同列；纳入=绿 / 排除=橙）
    sheet("表级血缘全量",
          ["目标DWD表", "目标中文名", "归属工作流", "上游表", "上游中文名", "上游层级",
           "上游就绪", "纳入配置", "排除原因", "来源系统"],
          lin_rows, [36, 18, 12, 36, 18, 8, 10, 8, 40, 10],
          title="表级血缘全量（%d 行）" % len(lin_rows),
          fill=lambda r: WARN if r[7] == "否" else OK)

    # ③ 按工作流汇总（与 v4 同名同列）
    by_wf = collections.defaultdict(lambda: [set(), 0, set()])
    for t, u in pairs:
        w = own.get(t, "(无配置)")
        by_wf[w][0].add(t); by_wf[w][1] += 1; by_wf[w][2].add(u)
    wf_rows = []
    for wf in sorted(by_wf):
        tbls, n, ups_ = by_wf[wf]
        wf_rows.append([wf, len(tbls), n, len(ups_),
                        sum(1 for t, u in pairs if own.get(t) == wf and (t, u) in cfg_edges),
                        sum(1 for t, u in pairs if own.get(t) == wf and (t, u) not in cfg_edges)])
    sheet("按工作流汇总", ["工作流", "表数", "血缘行数", "涉及上游表数", "纳入配置", "排除"],
          wf_rows, [14, 10, 12, 14, 12, 10], title="按 DWD 工作流汇总")

    # ④ 排除项明细（与 v4 同名同列 + 同样措辞）
    sheet("排除项明细", ["目标DWD表", "上游表", "上游层级", "排除原因"], excl,
          [36, 36, 10, 46],
          title="被排除的依赖边（%d 条）" % len(excl),
          notes=[
              "「上一日分区依赖」= 脚本里用 DATE_SUB(p_end_dt,1) 之类读上游**昨日分区**的边，"
              "等当日实例满足不了，按用户口径全部剔除。",
              "「码表」= DWD_CMM_STD_DICT_CDVAL_MAP，被大量脚本 JOIN 但无 ETL 脚本、非每日批次产物。",
              "「无法解析上游」= 生成器仓库无该系统脚本，定位不到 ods_*_etl_NN。",
          ],
          fill=lambda r: WARN)

    # ⑤ 上游表清单（v4 同名同列；未配好/无脚本=橙，就绪=绿）
    sheet("上游表清单", ["上游表", "层级", "就绪", "被引用次数", "被哪些DWD引用（<=8）"],
          up_rows, [36, 8, 10, 12, 90],
          title="上游表清单（去重 %d 张）" % len(up_rows),
          fill=lambda r: WARN if r[2] in ("未配好", "无脚本") else OK)

    # ⑥ 依赖差异明细（本管线特有：DS 侧逐节点核对）
    rows = [[m[0], m[1], m[2], m[3]] for m in (dif.get("miss") or [])]
    rows += [[e[0], e[1], e[2], e[3]] for e in (dif.get("extra") or [])]
    sheet("依赖差异明细", ["DWD工作流", "目标表", "DS缺少的(工作流Code,任务Code)",
                       "DS多出的(工作流Code,任务Code)"], rows, [14, 34, 44, 44],
          title="依赖差异明细（缺 %d / 多 %d）" % (
              sum(len(m[2]) for m in dif.get("miss") or []),
              sum(len(m[3]) for m in dif.get("miss") or [])
              + sum(len(e[3]) for e in dif.get("extra") or [])),
          notes=["以 dep 节点的 dependItemList 为粒度；(definitionCode, depTaskCode) 成对比较。",
                 "definitionCode = 上游工作流 code，depTaskCode = 上游作业 code。",
                 "空表 = DS 与 dep.json 完全一致。"])

    # ⑦ 异常
    rows = [[a[0], a[1], a[2]] for a in (dif.get("anomalies") or [])]
    sheet("异常告警", ["工作流", "节点", "原因"], rows, [14, 34, 70], fill=lambda r: WARN,
          title="异常告警（%d 条）" % len(rows))

    # ⑧ 中文名核对
    rows = []
    for t, cs in sorted((s.get("cn_multi") or {}).items()):
        rows.append([t, "/".join(cs), "一表多名（疑污染）"])
    for c, ts in sorted((s.get("cn_dup") or {}).items()):
        rows.append([c, ", ".join(ts), "一名多表（疑污染）"])
    sheet("中文名核对", ["表名/中文名", "涉及", "类型"], rows, [40, 60, 18],
          notes=["权威源：scripts/<SYS>/dwd/data_dict/DWD_dict.xlsx（仅 HSFA/HSZTA/O32/MASTER 有）。",
                 "0 行 = 干净。"], fill=lambda r: WARN)

    del wb["Sheet"]
    out = os.path.join(REPORT_DIR, "DWD全链核对-%s.xlsx"
                       % time.strftime("%Y%m%d-%H%M"))
    wb.save(out)
    _dump({"lineage": stages.get("lineage", {}), "diff": dif}, "latest.json")
    prune_reports(KEEP_REPORTS if keep is None else keep)
    return out


# ================================================================ main
def main():
    ap = argparse.ArgumentParser(
        description="DWD 血缘梳理 / 依赖差异 / 依赖配置 / 部署排版 四合一")
    ap.add_argument("stage", choices=["lineage", "diff", "config", "deploy", "all"])
    ap.add_argument("--apply", action="store_true",
                    help="真正落盘/提交 DS（默认 dry-run）")
    ap.add_argument("--rebuild", action="store_true",
                    help="整工作流删建（危险：task code 重分配，跨流引用会悬空）")
    ap.add_argument("--no-layout", action="store_true", help="跳过排版")
    ap.add_argument("--force", action="store_true", help="排版：已达标的也重排")
    ap.add_argument("--exclude-table", default=DEFAULT_EXCLUDE_TABLE,
                    help="config：这些表作上游的依赖边全部剔除"
                         "（默认 DWD_CMM_STD_DICT_CDVAL_MAP，2026-10-16 用户口径；传空则关）")
    ap.add_argument("--exclude-prev-day", default=DEFAULT_PREV_DAY,
                    help="config：上一日分区依赖边清单 JSON（tools/_scan_prev_day_deps.py 产物）")
    ap.add_argument("--report", action="store_true", default=True,
                    help="输出 Excel 报告（默认开）")
    ap.add_argument("--keep", type=int, default=KEEP_REPORTS,
                    help="docs 里只保留最新 N 份报告，其余自动归档到 backup/docs-report-archive/ "
                         "（默认 %d；0=不清理）" % KEEP_REPORTS)
    args = ap.parse_args()

    D.login()
    log("项目 dw code=%s" % pcode())

    stages = {}
    if args.stage == "lineage":
        stages["lineage"] = stage_lineage(args)
    elif args.stage == "diff":
        stages["diff"] = stage_diff(args)
    elif args.stage == "config":
        stages["lineage"] = stage_lineage(args) or {}
        stages["config"] = stage_config(args)
        stages["diff"] = stages["config"]
    elif args.stage == "deploy":
        stages["deploy"] = stage_deploy(args)
    elif args.stage == "all":
        stages["lineage"] = stage_lineage(args)
        d = stage_diff(args)
        stages["diff"] = d
        stages["config"] = stage_config(args)
        stages["deploy"] = stage_deploy(args)

    if args.stage != "deploy":
        stages.setdefault("deploy", stages.get("config") or stages.get("diff") or {})
    if args.report and stages:
        try:
            out = build_report(stages, keep=args.keep)
            log(f"\n📊 报告 → {out}")
        except Exception as e:
            log(f"  ⚠ 报告生成失败：{e}")

    # 统一收口：是否三方一致
    d = stages.get("deploy") or {}
    rule("总结")
    log(f"血缘 {len(d.get('lin_cfg_gap') or []) and ''}"
        f"缺口 {len(d.get('lin_cfg_gap') or [])} 条；"
        f"DS 差异 {len(d.get('dirty_workflows') or [])} 个工作流；"
        f"异常 {len(d.get('anomalies') or [])} 条")
    if not args.apply:
        log("（dry-run：DS 与 dep.json 均未改动；加 --apply 才会写）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
