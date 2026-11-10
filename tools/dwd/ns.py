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
MASTER = SCRIPTS / 'MASTER/dwd/02_etl'
SYS = ('HSFA', 'HSZTA', 'O32')
GROUPS = SYS + ('主数据',)
OWNER_JSON = REPO / 'tools/.dx-tmp/dwd_owner_map.json'
DEPCFG_OUT = REPO / 'tools/ds-deploy/dep-config-proscript'
ALIAS = {'01-ZTA': 'HSZTA', '02-O32': 'O32', '03-HSFA': 'HSFA'}

# ★ 2026-10-22（评审 HIGH-10）：系统简称的合法字符集。
#   sysname 源自 MAPPING 目录下的一级子目录名（**外部输入**），此前原样
#   拼进输出路径（SCRIPTS / sysname / 'dwd/02_etl'）—— 一个含 `..` 或路径
#   分隔符的目录名即可把文件写到 SCRIPTS 之外（路径遍历）。
#   标准简称是字母数字（HSFA / HSZTA / O32），MASTER 与「主数据」为特例。
_SYS_RE = re.compile(r'^[A-Za-z0-9_]+$')


def safe_sysname(name: str) -> str:
    """校验系统简称可安全用于路径拼接；不合法则抛 ValueError。

    允许的特例：``主数据``（中文，历史目录名）与 ``MASTER``。
    """
    if name in ('主数据', 'MASTER'):
        return name
    if not _SYS_RE.match(name or ''):
        raise ValueError(
            f"非法系统简称 {name!r}：只允许字母/数字/下划线"
            f"（含 '..'、路径分隔符等一律拒绝）")
    return name


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

PREVDAY_OUT = REPO / 'tools/_prev_day_deps.json'
