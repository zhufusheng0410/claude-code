# -*- coding: utf-8 -*-
"""DWD 管线共享路径与系统常量。

``REPO`` / ``SCRIPTS`` 是可变状态：``tools/dwd-pipeline.py`` 被按路径加载后，
测试会改这两个属性；入口把赋值写穿到本模块，路径函数才看得到补丁。
"""
import os
import re
import sys
from pathlib import Path

# tools/dwd/ns.py → parents[2] = 仓库根（原脚本在 tools/ 下，是 parents[1]）
REPO = Path(__file__).resolve().parents[2]
if str(REPO) not in sys.path:
    sys.path.insert(0, str(REPO))

_CAND_DELIVERY = [
    Path(os.environ["DW_DELIVERY"]) if os.environ.get("DW_DELIVERY") else None,
    Path('/mnt/d/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档'),
    Path(r'D:\项目\信达澳亚数仓\信达澳亚投研数据集市交付文档'),
]
DELIVERY = next((p for p in _CAND_DELIVERY if p and (p / '05-脚本').is_dir()),
                _CAND_DELIVERY[-1])
JF = DELIVERY / '05-脚本/02-脚本/01-DWD执行脚本'
JF_DDL = DELIVERY / '05-脚本/01-建表语句/01-DWD建表脚本.sql'
MAP_ROOT = DELIVERY / '04-源与目标映射MAPPING/01-DWD'

SCRIPTS = REPO / 'scripts'
SYS = ('HSFA', 'HSZTA', 'O32')
GROUPS = SYS + ('主数据',)
ALIAS = {'01-ZTA': 'HSZTA', '02-O32': 'O32', '03-HSFA': 'HSFA'}

# ★ 2026-11-13（评审 L2）：`safe_sysname` 移入 `tools/core/safe_paths.py`。
#   它原先只在这里定义，导致 `tools/dws/` 为了用它反向依赖 DWD 包。
#   本模块继续 re-export，历史调用方（含 facade）不需要改。
from tools.core.safe_paths import safe_sysname  # noqa: E402,F401


def etl_dir(sysname):
    """DWD 脚本目录（主数据归 MASTER）。"""
    safe_sysname(sysname)
    scripts = SCRIPTS
    return (scripts / 'MASTER/dwd/02_etl') if sysname == '主数据' else scripts / sysname / 'dwd/02_etl'


def ddl_dir(sysname):
    """DDL 目录（主数据归 MASTER）。"""
    safe_sysname(sysname)
    return (SCRIPTS / 'MASTER/dwd/ddl') if sysname == '主数据' \
        else (SCRIPTS / sysname / 'dwd/ddl')


def dws_etl_dir(sysname):
    """DWS 脚本目录（scripts/<系统>/dws/02_etl）。"""
    safe_sysname(sysname)
    return SCRIPTS / sysname / 'dws/02_etl'


def ddl_main(sysname):
    safe_sysname(sysname)
    return (SCRIPTS / 'MASTER/dwd/01_ddl.sql') if sysname == '主数据' \
        else (SCRIPTS / sysname / 'dwd/01_ddl.sql')


TAB_RE = re.compile(r'^DWD_[A-Z0-9_]+$')
SCHEDULE_EXCLUDE = {'DWD_CMM_STD_DICT_CDVAL_MAP'}
# 脚本 INSERT 目标表。解析（_parse_script）与 DDL 落盘共用，必须在两边都可见。
TGT = re.compile(
    r'INSERT\s+(?:OVERWRITE|INTO)\s+(?:TABLE\s+)?(?:[A-Za-z0-9_]+\.)?([A-Za-z][A-Za-z0-9_]*)',
    re.I)

#: 由 REPO / SCRIPTS **派生**的路径：按需求值，不在 import 时固化。
#: ★ 2026-11-10（评审复审）：这些名字若写成模块级常量，改 `ns.SCRIPTS` 后
#:   它们仍指向真实仓库 ⇒ 沙箱（测试）里读写的其实是仓库文件。
#:   改为 PEP 562 的模块级 `__getattr__`：`_ns.MASTER` 始终跟随当前值。
_DERIVED_PATHS = {
    'MASTER': lambda: SCRIPTS / 'MASTER/dwd/02_etl',
    'OWNER_JSON': lambda: REPO / 'tools/.dx-tmp/dwd_owner_map.json',
    'DEPCFG_OUT': lambda: REPO / 'tools/ds-deploy/dep-config-proscript',
    'PREVDAY_OUT': lambda: REPO / 'tools/_prev_day_deps.json',
}


def __getattr__(name):
    """按当前 REPO/SCRIPTS 现算派生路径（PEP 562）。"""
    fn = _DERIVED_PATHS.get(name)
    if fn is not None:
        return fn()
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
