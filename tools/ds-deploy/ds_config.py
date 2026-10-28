#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""DS / PG / Hive 凭据集中读取 —— 全局唯一入口。

★★ 为什么需要这个模块
    2026-10-22 代码审查发现：16 个脚本各自硬编码了集群明文凭据
    （DS admin 密码、PG 密码、Hive 密码、Oracle 生产库密码），其中一份
    甚至进了暂存区。凭据一旦进入 git 历史就等于永久泄露——即便事后删除，
    `git log -S` 仍可翻出。
    ⇒ 统一收口到这里：**源码里只保留环境变量名，不保留任何口令字面量**。

优先级（先到先得）
    1. 进程环境变量
    2. ``tools/ds-deploy/.env.local``（仓库内、gitignore、chmod 600）
    3. ``~/.dw-secrets.env``（用户级、chmod 600）
    4. 都没有 → **抛错退出**，绝不回退到明文缺省值

用法
----
    from ds_config import ds_user, ds_password, pg_conn, require_secret

    ds = legacy_client(base=ds_base(), user=ds_user(),
                       password=ds_password(), allow_admin=True)

命令行
----
    export DS_PASSWORD='...'
    python tools/ds-deploy/ds-check-running.py
"""
from __future__ import annotations

import os
import pathlib

__all__ = [
    "ds_base", "ds_user", "ds_password", "ds_admin_user", "ds_admin_password",
    "ds_service_user", "ds_service_password",
    "pg_conn", "pg_password", "hive_user", "hive_password", "require_secret",
    "preflight", "SecretMissingError", "LOCAL_ENV_FILE", "HOME_ENV_FILE",
]

# ---------- 凭据文件位置 ----------

_HERE = pathlib.Path(__file__).resolve().parent
REPO_ROOT = _HERE.parent.parent

#: 仓库级本地凭据（不入库）
LOCAL_ENV_FILE = _HERE / ".env.local"
#: 用户级本地凭据（不入库）
HOME_ENV_FILE = pathlib.Path.home() / ".dw-secrets.env"

#: 允许从环境变量/文件读取的键
#  ★ 2026-10-27：必须与 `require_secret(...)` 的实际调用保持同步 —— 漏一个就会让
#    `python ds_config.py` 自检把它当成「不需要」而静默不报，
#    直到真跑批时才炸 SecretMissingError（排查成本高）。新增凭据时两处一起改。
SECRET_KEYS = (
    "DS_PASSWORD",
    "DS_ADMIN_PASSWORD",
    "DS_SERVICE_PASSWORD",
    "DS_PG_PASSWORD",
    "DS_HIVE_PASSWORD",
)

#: 非敏感项有安全的默认值（主机/端口/用户名不是秘密）
DS_BASE = os.environ.get("DS_BASE", "http://localhost:12345/dolphinscheduler")
DS_USER = os.environ.get("DS_USER", "ds_script")
PG_HOST = os.environ.get("DS_PG_HOST", "localhost")
PG_PORT = int(os.environ.get("DS_PG_PORT", "5432"))
PG_USER = os.environ.get("DS_PG_USER", "hiveuser")
PG_DB = os.environ.get("DS_PG_DB", "dolphinscheduler")
HIVE_USER = os.environ.get("DS_HIVE_USER", "hive")


class SecretMissingError(RuntimeError):
    """缺少必需的凭据时抛出。"""


# ---------- 凭据文件解析 ----------

def _parse_env_file(path: pathlib.Path) -> dict:
    """解析 ``KEY=VALUE`` 格式的 env 文件。

    - ``#`` 开头为注释
    - 值两侧的引号会被剥掉（便于写含特殊字符的口令）
    - 忽略空行与无 ``=`` 的行
    """
    result = {}
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return result
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        if key:
            result[key] = value
    return result


def _file_secrets() -> dict:
    """按优先级读取两个凭据文件（靠前者不被后者覆盖）。"""
    merged = {}
    for path in (HOME_ENV_FILE, LOCAL_ENV_FILE):
        if path.exists():
            for key, value in _parse_env_file(path).items():
                merged.setdefault(key, value)
    return merged


_FILE_CACHE: dict | None = None


def _secrets() -> dict:
    global _FILE_CACHE
    if _FILE_CACHE is None:
        _FILE_CACHE = _file_secrets()
    return _FILE_CACHE


# ---------- 读取入口 ----------

def require_secret(key: str) -> str:
    """读取一个必需凭据；缺失则抛 :class:`SecretMissingError`。

    刻意**没有**明文缺省值——缺省值就是「凭证写进源码」的第一步。
    """
    value = os.environ.get(key)
    if value:
        return value
    value = _secrets().get(key)
    if value:
        return value
    raise SecretMissingError(
        f"缺少环境变量 {key}。\n"
        f"  三种配置方式（任选其一）：\n"
        f"    1) export {key}='...'\n"
        f"    2) 写 {LOCAL_ENV_FILE}（仓库内，已 gitignore）：{key}=...\n"
        f"    3) 写 {HOME_ENV_FILE}（用户级，已 gitignore）：{key}=...\n"
        f"  注：源码里不再保留任何口令字面量，故必须显式提供。"
    )


def ds_base() -> str:
    """DS 服务地址（非敏感，有默认）。"""
    return DS_BASE.rstrip("/")


def ds_user() -> str:
    """DS 脚本专用账号（非敏感，有默认 ``ds_script``）。

    注意：脚本专用账号**不能**与浏览器 UI 共用，否则每次 login 都会
    踢掉 UI 会话（DS 3.4.2 的会话表同 user 只留 1 行，见 ds_client.py 头注）。
    """
    return DS_USER


def ds_password() -> str:
    """DS 脚本账号口令（**必需**，无缺省值）。"""
    return require_secret("DS_PASSWORD")


def ds_service_user() -> str:
    """DS 服务账号（用于串行跑批等后台任务，不占 admin 会话）。
    
    2026-10-24 新建：ds_service / ds_service_2026，已授项目全权限 + 4数据源权限。
    与 admin 会话隔离，UI 用 admin 看进度，后台用 ds_service 跑批。
    """
    return os.environ.get("DS_SERVICE_USER", "ds_service")


def ds_service_password() -> str:
    """DS 服务账号口令（必需，无缺省值）。"""
    return require_secret("DS_SERVICE_PASSWORD")


def ds_admin_user() -> str:
    """DS 管理员账号（非敏感，有默认 ``admin``）。"""
    return os.environ.get("DS_ADMIN_USER", "admin")


def ds_admin_password() -> str:
    """DS 管理员口令（**必需**，无缺省值）。

    ⚠ 用 admin 登录会踢掉浏览器 UI 的会话——仅在脚本确实需要管理权限时使用，
    且 ds_client 的 ``allow_admin`` 护栏会额外拦截。
    """
    return require_secret("DS_ADMIN_PASSWORD")


def pg_conn() -> dict:
    """PG 连接参数（含口令，**必需**，无缺省值）。

    用于直连 DolphinScheduler 元库（``t_ds_*`` 表）。
    """
    return {
        "host": PG_HOST,
        "port": PG_PORT,
        "user": PG_USER,
        "password": require_secret("DS_PG_PASSWORD"),
        "dbname": PG_DB,
    }


def pg_password() -> str:
    """PG 口令（**必需**，无缺省值）。"""
    return require_secret("DS_PG_PASSWORD")


def hive_user() -> str:
    """Hive beeline 账号（非敏感，有默认 ``hive``）。"""
    return HIVE_USER


def hive_password() -> str:
    """Hive beeline 口令（**必需**，无缺省值）。

    ⚠ 不走命令行 ``-p``（会进进程列表，被同机其他用户 ``ps`` 读到），
    改用环境变量传递。
    """
    return require_secret("DS_HIVE_PASSWORD")


def preflight(*keys: str) -> None:
    """启动前检查凭据齐备，缺失则一次性报全（省得逐个撞错）。

    用法::

        preflight("DS_PASSWORD", "DS_PG_PASSWORD")   # 缺任何一个都立即退出
    """
    missing = [k for k in keys
               if not (os.environ.get(k) or _secrets().get(k))]
    if missing:
        raise SecretMissingError(
            "缺少凭据：" + ", ".join(missing) + "\n"
            f"  配置方式：export {missing[0]}=... ，或写 {LOCAL_ENV_FILE} / {HOME_ENV_FILE}"
        )


if __name__ == "__main__":
    # 自检：报告各凭据是否齐备（**只报在/缺，不打印值**）
    print("凭据文件：")
    for p in (HOME_ENV_FILE, LOCAL_ENV_FILE):
        print(f"  {p}  {'存在' if p.exists() else '不存在'}")
    print("凭据状态：")
    for key in SECRET_KEYS:
        ok = bool(os.environ.get(key) or _secrets().get(key))
        print(f"  {key:22s} {'OK 已配置' if ok else 'X 缺失'}")
