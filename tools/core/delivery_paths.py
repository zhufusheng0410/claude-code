# -*- coding: utf-8 -*-
"""甲方交付目录定位与 scripts/ 子目录拼装（DWD / DWS 共用）。

★ 为什么单独一个模块
    交付目录的候选顺序、哨兵子目录，以及「主数据 → MASTER」的目录映射原先
    在 ``tools/dwd/ns.py`` 与 ``tools/dws/state.py`` 各存一份（语义相同，
    只差引号风格）。两份口径一旦漂移，DWD 与 DWS 就会指向不同交付源 ⇒
    统一到本模块，两边只保留各自的 ``DELIVERY`` 与派生路径常量。

★ 依赖面
    只依赖 ``os`` / ``pathlib`` 与 ``tools.core.safe_paths``（叶子，仅 ``re``）。
    不引入 pandas / openpyxl，保证 ``tools/dw-pipeline.py`` 复用它时不拖重依赖。
"""
import os
from pathlib import Path

from tools.core.safe_paths import safe_sysname

#: 甲方交付目录的哨兵子目录：候选目录必须含它，否则视为不可达。
_DELIVERY_SENTINEL = "05-脚本"

#: 主数据在甲方目录叫「主数据」，在 scripts/ 下归 MASTER。
_MASTER_SYSNAME = "主数据"
_MASTER_DIR = "MASTER"


#: 交付文档目录在项目根下的相对路径（供 config.py 探测 D 盘根用）。
_PROJECT_REL = os.path.join("项目", "信达澳亚数仓", "信达澳亚投研数据集市交付文档")


def detect_d_base():
    """探测 D 盘根：显式环境变量优先，否则取首个能命中交付文档目录的候选。

    全都不命中时返回首选候选，由调用方给出可读报错。
    """
    env = os.environ.get("DW_D_BASE")
    if env:
        return env
    cands = ["D:/", "E:/"] if os.name == "nt" else ["/mnt/d", "/d", "/data"]
    for c in cands:
        if os.path.isdir(os.path.join(c, _PROJECT_REL)):
            return c
    return cands[0]


def resolve_delivery() -> Path:
    """定位甲方交付目录根。

    顺序：``DW_DELIVERY`` 环境变量 → ``config.PROJECT_BASE`` → Windows 原生。
    ★ 不能只用 ``exists()`` 回退：Windows 会把 ``/mnt/d`` 解析成 ``\\mnt\\d``
      （当前盘符下），历史运行留下的镜像目录会让 ``exists()`` 假真 ⇒
      按哨兵子目录判定。
    """
    candidates = [
        Path(os.environ["DW_DELIVERY"]) if os.environ.get("DW_DELIVERY") else None,
        Path(detect_d_base()) / _PROJECT_REL,
        Path(r"D:\项目\信达澳亚数仓\信达澳亚投研数据集市交付文档"),
    ]
    return next((p for p in candidates if p and (p / _DELIVERY_SENTINEL).is_dir()),
                candidates[-1])


def _dwd_layer_dir(scripts: Path, sysname: str) -> Path:
    """DWD 系统目录；路径校验与主数据映射只保留这一份。"""
    safe_sysname(sysname)
    group = _MASTER_DIR if sysname == _MASTER_SYSNAME else sysname
    return scripts / group / "dwd"


def dwd_etl_dir(scripts: Path, sysname: str) -> Path:
    """DWD ETL 脚本目录（主数据归 scripts/MASTER/dwd/02_etl）。"""
    return _dwd_layer_dir(scripts, sysname) / "02_etl"


def dwd_ddl_dir(scripts: Path, sysname: str) -> Path:
    """DWD 单表 DDL 目录（主数据归 scripts/MASTER/dwd/ddl）。"""
    return _dwd_layer_dir(scripts, sysname) / "ddl"


def dwd_ddl_main(scripts: Path, sysname: str) -> Path:
    """DWD 合并 DDL 路径（主数据归 scripts/MASTER/dwd/01_ddl.sql）。"""
    return _dwd_layer_dir(scripts, sysname) / "01_ddl.sql"


def dws_etl_dir(scripts: Path, sysname: str) -> Path:
    """DWS 脚本目录 scripts/<系统>/dws/02_etl。"""
    safe_sysname(sysname)
    return scripts / sysname / "dws/02_etl"
