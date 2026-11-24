# -*- coding: utf-8 -*-
"""DS 部署/运维脚本共享底座：Docker 探测、JSON 列表反序列化与调度状态快照/恢复。

★ 为什么单独抽离
    ``j(x)``、``snapshot_online_schedules``、``set_schedule`` 与 Docker 路径探测
    原先分别散落在 ``ds-sync-dwd-scripts.py``、``ds-sync-ods-scripts.py``、
    ``ds-relayout.py``、``ds-check-tables-exist.py`` 等多个脚本中，甚至靠动态
    ``_load("ds-sync-dwd-scripts.py")`` 跨脚本借函数。收口到此模块后，各脚本
    直接 import 即可，原脚本保留同名薄委托以保持 100% 向后兼容。
"""
import http.client
import json
import os
import subprocess
from typing import Optional

#: DS REST 调用的「外部」失败：DSClientError 与 drop_wf 等辅助函数的失败都是
#: RuntimeError 子类/实例；网络层为 OSError（含 TimeoutError/URLError）或
#: http.client.HTTPException（IncompleteRead 等）；响应解析失败为 ValueError。
#: TypeError/AttributeError/KeyError 等编程错误不在其中，必须直接暴露。
DS_CALL_ERRORS = (RuntimeError, OSError, ValueError, http.client.HTTPException)

#: docker/beeline 子进程调用的「外部」失败：超时（SubprocessError）、docker 不在
#: PATH（OSError）、beeline() 准备口令文件失败（RuntimeError）。
SUBPROCESS_ERRORS = (subprocess.SubprocessError, OSError, RuntimeError)


def docker_bin() -> str:
    """解析 docker 可执行文件路径（WSL/Linux 走 PATH 或 DOCKER 环境变量）。"""
    env = os.environ.get("DOCKER")
    if env:
        return env
    if os.name == "posix":
        return "docker"
    return r"C:\Program Files\Docker\Docker\resources\bin\docker.exe"


def parse_json_list(x):
    """DS 回读的字段有时是 JSON 字符串、有时已反序列化；与各脚本原 ``j()`` 语义一致。

    字符串解析失败返回 ``[]``；非字符串原样返回（假值归一为 ``[]``）。
    """
    if isinstance(x, str):
        try:
            return json.loads(x)
        except (json.JSONDecodeError, ValueError):
            return []
    return x or []


def snapshot_online_schedules(docker: Optional[str] = None, as_int: bool = False) -> set:
    """快照 DS 元库中当前 ONLINE（release_state=1）的调度 ID 集合。

    必须直接查 PostgreSQL 元库，不能走 REST API（GET /schedules 只返回 ONLINE）。
    改工作流定义会级联把挂在其上的调度置 OFFLINE，提交后需按快照恢复。
    """
    cmd = [
        docker or docker_bin(),
        "exec", "hive-metastore-db",
        "psql", "-U", "dolphinscheduler", "-d", "dolphinscheduler",
        "-tAc", "select id from t_ds_schedules where release_state=1",
    ]
    try:
        r = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=60,
        )
    except (subprocess.SubprocessError, OSError) as e:
        print(f"  ⚠ 快照调度失败（继续）：{e}")
        return set()

    ids = set()
    for line in (r.stdout or "").splitlines():
        s = line.strip()
        if not s:
            continue
        if as_int:
            if s.isdigit():
                ids.add(int(s))
        else:
            ids.add(s)
    return ids


def set_schedule_state(sid, state: int, docker: Optional[str] = None) -> bool:
    """直接更新 DS 元库中指定调度 ID 的 release_state（0=OFFLINE, 1=ONLINE）。

    强制校验 sid 与 state 为整数，防止拼 SQL 注入。
    """
    sid_int = int(sid)
    state_int = int(state)
    if state_int not in (0, 1):
        raise ValueError(f"非法的调度状态 state={state!r}，只允许 0 或 1")
    cmd = [
        docker or docker_bin(),
        "exec", "hive-metastore-db",
        "psql", "-U", "dolphinscheduler", "-d", "dolphinscheduler",
        "-tAc", f"update t_ds_schedules set release_state={state_int} where id={sid_int}",
    ]
    try:
        subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=60,
        )
        return True
    except (subprocess.SubprocessError, OSError) as e:
        print(f"  ⚠ 恢复调度 {sid_int} 失败：{e}")
        return False
