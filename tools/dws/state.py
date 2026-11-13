# -*- coding: utf-8 -*-
"""DWS 管线的仓库路径、口径常量与共享状态。

★ 为什么单独一个模块
    路径常量必须**集中**到一处，且其它模块一律通过 ``st.SCRIPTS`` /
    ``st.REPO`` 在**调用时**取值。否则各模块会各自 `from ... import SCRIPTS`
    拷贝一份快照，测试把路径指向临时目录后仍会读写真实仓库
    （`tools/dwd/` 拆分时踩过，见 2026-11-10 评审 H1）。
"""
import os
import sys
from pathlib import Path

from tools.core.safe_paths import safe_sysname

# 仓库根入 sys.path，才能 import tools.core.loader（按绝对路径缓存，跨脚本同一份）。
REPO = Path(__file__).resolve().parents[2]
if str(REPO) not in sys.path:
    sys.path.insert(0, str(REPO))

SCRIPTS = REPO / "scripts"
SYS = ("HSFA", "HSZTA", "O32")
# ★ 2026-11-09（评审 C3）：DWD 侧还有主数据分组（脚本/DDL 落在 scripts/MASTER）。
#   与 tools/dwd-pipeline.py 的 GROUPS 保持一致；gen 模式仍不写 MASTER，
#   但「存在性检查 / 拼接副本修复」必须能看到它。
GROUPS = SYS + ("主数据",)

DWD_PIPE = REPO / "tools/dwd-pipeline.py"
GEN_MAIN = REPO / "tools/main.py"
DEPLOY_ALL = REPO / "tools/ds-deploy/ds-deploy-all-dwd.py"
DWS_DEPS = REPO / "tools/ds-deploy/ds-build-dws-dependent-from-lineage.py"
DWS_DEP_REPORT = REPO / "tools/dws-dep-report.py"
RELAYOUT = REPO / "tools/ds-deploy/ds-relayout.py"
DEPCFG_DWD = REPO / "tools/ds-deploy/dep-config-proscript"
DEPCFG_DWS = REPO / "tools/ds-deploy/dep-config-dws"
SH_REPAIR = REPO / "tools/core/sh_repair.py"
DDL_VERIFY = REPO / "tools/core/ddl_verify.py"
PY = sys.executable

# ★ 2026-10-26：原来写死 WSL 路径 /mnt/d，Windows 原生跑会判「不存在→跳过」。
#   注意不能只用 exists() 回退：Windows 会把 /mnt/d 解析成 `\mnt\d`（当前盘符下），
#   历史运行留下的镜像目录会让 exists() 假真 ⇒ 按哨兵子目录 `05-脚本` 判定。
_CAND_DELIVERY = [
    Path(os.environ["DW_DELIVERY"]) if os.environ.get("DW_DELIVERY") else None,
    Path("/mnt/d/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档"),
    Path(r"D:\项目\信达澳亚数仓\信达澳亚投研数据集市交付文档"),
]
DELIVERY = next((p for p in _CAND_DELIVERY if p and (p / "05-脚本").is_dir()),
                _CAND_DELIVERY[-1])
SRC_DWS_EXEC = DELIVERY / "05-脚本/02-脚本/02-DWS执行脚本"
SRC_DWS_DDL = DELIVERY / "05-脚本/01-建表语句/02-DWS建表脚本.sql"
SRC_DWD_DDL = DELIVERY / "05-脚本/01-建表语句/01-DWD建表脚本.sql"
# ★ 2026-10-22（评审 HIGH-11）：原先有模块级可变态全局 `FORCE_DWS_RAW`，
#   多次调用 / 测试之间会互相污染 ⇒ 已取消，改为直接读 args 上的开关。

VALID_LAYERS = {"DWD", "DWS"}

# ---- DWS 口径常量（口径变只改这里，别再散落魔数） ----
# ★ 原来 24 / 24 / 3 硬编码在 4 个地方，新增一张表就误报失败；
#   HSZTA→DWS_ZTA 是不规则映射，无法由 SYS 推导，故单独一张表统一维护。
DWS_EXPECT_SCRIPTS = 24      # scripts/{系统}/dws/02_etl/*.sh 合计
DWS_EXPECT_DEPS = 24         # tools/ds-deploy/dep-config-dws/*.dep.json
DWS_EXPECT_WORKFLOWS = 3     # DS 上 DWS_* 工作流个数
DWS_WF2SYS = {"DWS_HSFA": "HSFA", "DWS_ZTA": "HSZTA", "DWS_O32": "O32"}

# 子进程默认上限：DS API 挂住时不让整条管线无限等；需要更长可设 DW_RUN_TIMEOUT。
RUN_TIMEOUT = int(os.environ.get("DW_RUN_TIMEOUT", "1800"))


def ds_deploy():
    """惰性导入 ds-deploy 里的共用模块（该目录不在包路径上）。

    ★ 2026-10-26：原先在**模块顶层** `from ds_config import ...` —— 那会把
      `tools/ds-deploy` 目录当成包路径用，而它并没有加入 sys.path，
      于是任何 `python3 tools/dw-pipeline.py …` 启动都直接 ModuleNotFoundError。
      ⇒ 改为函数内导入，并顺便注入 sys.path（只做一次）。
    """
    d = str(REPO / "tools/ds-deploy")
    if d not in sys.path:
        sys.path.insert(0, d)
    import ds_client
    import ds_text
    return ds_client, ds_text


def dwd_etl_dir(sysname):
    """DWD 脚本目录（主数据归 scripts/MASTER，不是 scripts/主数据）。

    ★ 2026-11-10（评审 H2）：补 `safe_sysname` 校验。本函数是 `dwd.ns.etl_dir`
      的同规则副本，但此前漏了路径校验 —— 与 ns 那份不一致就等于没有防线。
    """
    safe_sysname(sysname)
    return (SCRIPTS / "MASTER/dwd/02_etl") if sysname == "主数据" \
        else (SCRIPTS / sysname / "dwd/02_etl")


def ddl_main(sysname):
    """DWD 合并 DDL 路径（主数据归 scripts/MASTER/dwd/01_ddl.sql）。"""
    safe_sysname(sysname)
    return (SCRIPTS / "MASTER/dwd/01_ddl.sql") if sysname == "主数据" \
        else (SCRIPTS / sysname / "dwd/01_ddl.sql")


def dws_etl_dir(sysname):
    """DWS 脚本目录 `scripts/<系统>/dws/02_etl`（带路径校验）。"""
    safe_sysname(sysname)
    return SCRIPTS / sysname / "dws/02_etl"
