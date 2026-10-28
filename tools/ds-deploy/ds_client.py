#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""DolphinScheduler API 客户端 —— 带会话持久化，避免反复 login 踢掉 UI。

★★ 为什么需要这个模块（DS 3.4.2 实测根因）
    DS 的 t_ds_session 表【同一 user 只保留 1 行】：
      SessionServiceImpl.createSessionIfAbsent(user)
        sessions = queryByUserId(user.id)
        if (非空) {
            删除 index 1..n-1
            s = sessions.get(0)
            if (isSessionExpire(s)) { 刷新 lastLoginTime; return s; }   # 已过期才复用
            else { deleteById(s.id); }                                  # 未过期→删除
        }
        新建 uuid → insert → return
    且 AbstractAuthenticator.getAuthUser() 里：
        s = getSession(sessionId)
        if (s == null) return null;                      → 401 "user does not exist"
        if (isSessionExpire(s)) { expireSession(userId); return null; }  # 删光该用户所有会话
    ⇒ 结论：**任何一次新 login 都会作废该用户的上一个会话**。
      所以脚本如果用 admin 反复登录，浏览器 UI 必然被踢。

★★ 两条防线（本模块实现第 2 条，第 1 条靠独立账号）
    1) 账号隔离：脚本用 ds_script，UI 用 admin —— 两套会话互不影响。
    2) 会话复用（本模块）：把 sessionId 落盘，优先复用；只有失效（401）才重新登录。
       这样脚本自己的 login 次数也降到最低。

用法：
    from ds_client import DSClient
    ds = DSClient()                      # 默认 ds_script 账号，自动复用磁盘会话
    r = ds.call("GET", "/projects", params={"pageNo":1,"pageSize":10})
    ds.close()

    # 需要 admin 权限时（口令从环境变量读，源码不含字面量）
    #   export DS_ADMIN_PASSWORD='...'
    ds = DSClient(user=ds_admin_user(), password=ds_admin_password(),
                  allow_admin=True)

    # 强制重新登录
    ds = DSClient(force_login=True)

环境变量可覆盖：DS_BASE / DS_USER / DS_PASSWORD / DS_ADMIN_USER /
DS_ADMIN_PASSWORD / DS_SESSION_FILE；也可用 tools/ds-deploy/.env.local 或
~/.dw-secrets.env（见 ds_config.py）。**口令不再有源码缺省值**——缺失即报错。

★★ 安全护栏（2026-09-29 加）
    用 admin 登录会**必然踢掉浏览器 UI 的会话**（因为 UI 也用 admin）。
    所以本模块默认**拒绝** user=admin 的登录，除非显式传 allow_admin=True。
    脚本请用 ds_script（已授权 ods_hsfa_etl 项目 + 全部 HIVE 数据源）。
"""
import http.cookiejar
import json
import os
import pathlib
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_config import (  # noqa: E402
    DS_BASE, DS_USER, ds_admin_password, ds_admin_user, ds_password,
)

BASE = DS_BASE
DEFAULT_USER = DS_USER
# ★ 2026-10-22：口令**不再有源码缺省值**。构造 DSClient 时按 user 惰性解析
#   （ds_script → DS_PASSWORD；admin → DS_ADMIN_PASSWORD），缺失即抛
#   SecretMissingError（提示三种配置方式），而不是静默用一个弱缺省密码。
DEFAULT_PWD = None
ACTION_USER = "ds_action"           # 需要写权限的脚本用（若已创建）
# ★ 2026-10-18（评审 #3）：默认目录改**仓库内**路径。
#   原默认 `D:/datax/.dx-tmp/ds-sessions` 是 Windows 盘符形态 —— 文档规定的运行
#   环境是 WSL，`D:/...` 在那里按**相对路径**解析，会在每个调用目录下生成字面名
#   为 `D:` 的目录（仓库里已攒出两棵，含会话凭据文件），且会话复用会因 CWD 不同
#   而失效（每次换目录都重新登录）。DS_SESSION_DIR 仍可覆盖。
SESSION_DIR = pathlib.Path(
    os.environ.get(
        "DS_SESSION_DIR",
        pathlib.Path(__file__).resolve().parents[1] / ".dx-tmp" / "ds-sessions",
    )
)

# 已知会与浏览器 UI 争抢会话的账号名
UI_SHARED_USERS = {"admin"}


class DSClientError(RuntimeError):
    pass


class DSClient:
    """带 Cookie 会话持久化的 DS API 客户端。"""

    #: 单次请求超时（秒）。轮询实例列表时 DS API 偶发抖动，别设太小。
    timeout = 60
    #: 超时后的最大重试次数（仅对 TimeoutError 生效）
    max_retry = 3
    #: 401 后重新登录的最大重试次数（DS API 重启后会话池被清时需要多次）
    max_auth_retry = 4

    def __init__(self, user=DEFAULT_USER, password=DEFAULT_PWD,
                 base=BASE, force_login=False, verbose=True, session_dir=None,
                 allow_admin=False):
        self.user = user
        self.base = base.rstrip("/")
        self.verbose = verbose
        self.session_dir = pathlib.Path(session_dir) if session_dir else SESSION_DIR
        self.session_file = self.session_dir / f"{user}.json"

        # ★ 安全护栏：用与 UI 相同的账号登录会踢掉 UI
        #   ★ 2026-10-22：此检查**前置**到口令解析之前——否则缺少
        #   DS_ADMIN_PASSWORD 时会先抛 SecretMissingError，把「你本来就不该用
        #   admin」这个更根本的错误掩盖成「配置缺失」。
        if user in UI_SHARED_USERS and not allow_admin \
                and os.environ.get("DS_ALLOW_ADMIN") not in ("1", "true", "yes"):
            raise DSClientError(
                f"拒绝以 {user} 登录：该账号与浏览器 UI 共用会话，登录即踢掉 UI。\n"
                f"  请改用脚本专用账号（默认 {DEFAULT_USER}）；"
                f"确实需要 {user} 时显式传 allow_admin=True，或设 DS_ALLOW_ADMIN=1。"
            )

        # ★ 2026-10-22：password 为 None 时按账号惰性解析口令。
        #   源码里不留任何字面量；缺失则抛 SecretMissingError 提示配置方式。
        if password is None:
            password = (ds_admin_password() if user in UI_SHARED_USERS
                        else ds_password())
        self.password = password

        self.cj = http.cookiejar.CookieJar()
        self.op = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(self.cj))
        self.sid = None

        if not force_login and self._load_session():
            if self._probe():
                self._log(f"[ds_client] 复用已有会话 user={user} sid={self.sid[:8]}…")
                return
            self._log(f"[ds_client] 磁盘会话已失效 user={user}，重新登录")
        self.login()

    # ---------- 日志 ----------
    def _log(self, msg):
        if self.verbose:
            print(msg, file=sys.stderr, flush=True)

    # ---------- 会话持久化 ----------
    def _load_session(self):
        """从磁盘读回 sessionId（若尚未过期）。"""
        try:
            if not self.session_file.exists():
                return False
            meta = json.loads(self.session_file.read_text(encoding="utf-8"))
            # 本地预留 2h 过期窗口，比服务端判定略保守
            age = time.time() - meta.get("ts", 0)
            if age >= 7200:
                self._log(f"[ds_client] 磁盘会话已超 2h（{age/60:.0f} 分钟），放弃复用")
                return False
            self.sid = meta.get("sessionId")
            if not self.sid:
                return False
            # 把 sessionId 塞回 CookieJar，供服务端 getAuthUser 读取
            self._set_cookie(self.sid)
            return True
        except Exception as e:  # 磁盘损坏不阻断
            self._log(f"[ds_client] 读取会话文件失败：{e}")
            return False

    def _save_session(self):
        try:
            self.session_dir.mkdir(parents=True, exist_ok=True)
            self.session_file.write_text(
                json.dumps({"sessionId": self.sid, "ts": time.time(),
                            "user": self.user}, ensure_ascii=False),
                encoding="utf-8")
            # 会话文件含凭据，限制权限（Windows 下 chmod 尽力而为）
            try:
                os.chmod(self.session_file, 0o600)
            except Exception:
                pass
        except Exception as e:
            self._log(f"[ds_client] 写会话文件失败：{e}")

    def _set_cookie(self, sid):
        """把 sessionId 写进 CookieJar。

        ★ DS 的 getAuthUser 会先看 header `sessionId`，再看 cookie `sessionId`，
          两者都没有 → 401。这里用 cookie 方式（与浏览器 UI 一致）。
        """
        host = urllib.parse.urlparse(self.base).hostname or "localhost"
        c = http.cookiejar.Cookie(
            version=0, name="sessionId", value=sid,
            port=None, port_specified=False,
            domain=host, domain_specified=False, domain_initial_dot=False,
            path="/", path_specified=True,
            secure=False, expires=None, discard=True,
            comment=None, comment_url=None, rest={}, rfc2109=False,
        )
        self.cj.set_cookie(c)

    # ---------- 登录 / 探测 ----------
    def login(self):
        """执行登录并落盘会话。"""
        form = {"userName": self.user, "userPassword": self.password}
        req = urllib.request.Request(
            f"{self.base}/login",
            data=urllib.parse.urlencode(form).encode(),
            method="POST",
        )
        req.add_header("Content-Type", "application/x-www-form-urlencoded")
        try:
            with self.op.open(req, timeout=30) as r:
                j = json.loads(r.read().decode("utf-8", "replace"))
        except urllib.error.HTTPError as e:
            raise DSClientError(f"登录 HTTP {e.code} {e.reason}")
        sid = (j.get("data") or {}).get("sessionId")
        if not sid:
            raise DSClientError(f"登录失败 code={j.get('code')} msg={j.get('msg')}")
        self.sid = sid
        self._save_session()
        self._log(f"[ds_client] 新登录 user={self.user} sid={sid[:8]}…")
        return sid

    def _probe(self):
        """探测当前会话是否有效。★ 用轻量接口，避免副作用。

        采用 /users/get-user-info（需登录），返回 200 说明会话有效。
        """
        try:
            r = self.call("GET", "/users/get-user-info", raise_on_401=False)
            return bool(r) and r.get("code") == 0
        except Exception:
            return False

    # ---------- 通用调用 ----------
    def call(self, method, path, form=None, params=None, body=None, raise_on_401=True):
        """发请求。★ 遇到 401 自动重登一次并重试（会话被清时的自愈）。

        body: 需要 JSON 请求体时传 dict（走 application/json）。
        """
        return self._call_once(method, path, form, params, body, raise_on_401,
                               _retry_401=True)

    def _call_once(self, method, path, form, params, body, raise_on_401,
                   _retry_401, _try=0, _auth_try=0):
        """发一次请求。

        ★ 2026-10-09：新增**超时重试**。
          起因：全量串行跑批跑到第 10 个工作流（约 54 分钟）时，一次普通的
          GET 实例列表 **60s 无响应** ⇒ `TimeoutError: timed out` ⇒ 整个跑批脚本崩溃，
          而 DS 里的实例其实**还在正常跑**（白丢了后面 20 个工作流的编排）。
          ⇒ 超时属于偶发抖动，重试即可；不重试的话「一次网络抖 == 整轮跑批前功尽弃」。
        """
        url = self.base + path
        if params:
            url += "?" + urllib.parse.urlencode(params)
        data = None
        if form is not None:
            # ★ doseq=True：form 里出现 list 值时展开成重复键（历史脚本的 _raw 都这么发），
            #   对纯标量 form 无任何影响 ⇒ 向后兼容且更正确。
            data = urllib.parse.urlencode(form, doseq=True).encode()
        elif body is not None:
            data = json.dumps(body).encode()
        req = urllib.request.Request(url, data=data, method=method)
        if form is not None:
            req.add_header("Content-Type", "application/x-www-form-urlencoded")
        elif body is not None:
            req.add_header("Content-Type", "application/json")
        if self.sid:
            req.add_header("sessionId", self.sid)
        try:
            with self.op.open(req, timeout=self.timeout) as r:
                raw = r.read().decode("utf-8", "replace")
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            # ★★★ 顺序关键：`HTTPError` 是 `URLError` 的子类、`URLError` 又是 `OSError`
            #   的子类 ⇒ 若把 `except (TimeoutError, OSError)` 写在前面，**401 会被它
            #   先吃掉**，401 重登逻辑永远走不到（实测：只在正常路径测过，一遇 401
            #   就直接抛，整个跑批脚本崩）。所以 HTTPError 必须排在 OSError 之前。
            if e.code == 401:
                # 会话失效 → 重新登录并重试。
                # ★ 2026-10-09：由「只重试 1 次」放宽到 self.max_auth_retry 次。
                #   起因：DS API 容器**重启后**会话池被清，脚本刚 login 拿到的新 sid
                #   在头几次请求里仍会 401（API 自身还在预热）⇒ 只重试一次会把
                #   整个跑批脚本崩掉（实测：触发完工作流就崩，白丢后面 18 个的编排）。
                #   多次重试 + 退避，等 API 预热完即可自愈。
                if _auth_try < self.max_auth_retry:
                    wait = 3 * (_auth_try + 1)
                    self._log("[ds_client] 会话失效(401) %s %s → %ds 后重新登录重试 %d/%d"
                              % (method, path, wait, _auth_try + 1, self.max_auth_retry))
                    time.sleep(wait)
                    try:
                        self.login()
                    except Exception as le:
                        self._log("[ds_client] 重登失败：%s" % le)
                    return self._call_once(method, path, form, params, body,
                                           raise_on_401, _retry_401,
                                           _auth_try=_auth_try + 1)
                if raise_on_401:
                    raise
                return None
            raise
        except TimeoutError as e:
            # ★ 只重试「超时类」；真正的 HTTP 错误已由上面的分支处理
            if _try < self.max_retry:
                wait = 5 * (_try + 1)
                self._log("[ds_client] 超时 %s %s（%s）→ %ds 后重试 %d/%d"
                          % (method, path, e, wait, _try + 1, self.max_retry))
                time.sleep(wait)
                return self._call_once(method, path, form, params, body,
                                       raise_on_401, _retry_401, _try=_try + 1)
            raise

    def close(self, sign_out=False):
        """收尾。★ 2026-10-18（评审 #4）：默认**不**注销会话。

        原实现每次 close() 都发 /signOut —— 等于把刚落盘、供**跨次复用**的会话
        立刻注销，与模块「会话复用、少 login」的设计正相反；并发共享同一 sid
        的工具也会被顺带踢成 401（能自愈，但要等退避重登）。
        ⇒ 默认无副作用；确实要注销时显式 `close(sign_out=True)`。
        """
        if not sign_out:
            return
        try:
            self.call("POST", "/signOut", raise_on_401=False)
        except Exception:
            pass


# ---------- 便捷函数 ----------
def get_client(**kw):
    """兼容旧脚本的一行式入口。"""
    return DSClient(**kw)


# ---------- 响应取值助手（2026-10-22 新增，统一防御性取值） ----------
#
# ★ 为什么需要
#   DS 的分页接口返回有两种形态：有时是 list，有时是 {"totalList": [...]}。
#   历史脚本因此各写了一份 `lst_of`（已在 ds-check-running.py / ds-deploy-all-dwd.py
#   里重复），而更多地方直接 `res["data"]["totalList"]` / `g["taskDefinitionList"]`
#   / `next(p["code"] for p in lst if ...)` —— 后者在 DS 返回异常结构（网关错误、
#   会话失效后的空 body、字段改名）时会抛 KeyError / StopIteration / TypeError，
#   报错信息完全看不出「是 DS 返回结构变了」还是「脚本逻辑错了」。
#   ⇒ 统一收口到这里，缺失时给出**可读的**错误。

def lst_of(res) -> list:
    """从 DS 响应里取列表，兼容 list 与 {"totalList": [...]} 两种形态。

    取不到就返回空列表（调用方可自行判断是否为空）。
    """
    if not isinstance(res, dict):
        return res if isinstance(res, list) else []
    data = res.get("data")
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        lst = data.get("totalList")
        if isinstance(lst, list):
            return lst
    return []


def project_code(res, name: str) -> int:
    """从项目列表响应里取指定项目的 code。

    找不到时抛 :class:`DSClientError`（**不是**裸 ``next()`` 的 StopIteration），
    报错信息带上项目名，便于定位「DS 里没这个项目 / 返回结构变了」。
    """
    for p in lst_of(res):
        if isinstance(p, dict) and p.get("name") == name:
            code = p.get("code")
            if code is not None:
                return code
    raise DSClientError(
        f"在 DS 项目列表里找不到项目 {name!r}。"
        f"  返回前 {len(lst_of(res))} 条；可能是项目名写错、"
        f"当前账号无权访问，或 DS 返回结构异常。")


def _maybe_json(x):
    """DS 偶尔把 JSON 作为**字符串**返回（taskDefinitionList 等）→ 尝试解码。"""
    if isinstance(x, str):
        try:
            return json.loads(x)
        except Exception:
            return []
    return x


def task_definitions(res) -> list:
    """安全取工作流的任务定义列表（``taskDefinitionList``）。

    兼容三种输入形态：
      · 完整响应 dict（含 "data" 键）
      · 已解包的 data dict（直接含 "taskDefinitionList"）
      · **JSON 字符串**（DS 有时把整个数组当字符串返回，见各脚本的 j() 包装）
    缺失时返回空列表 —— 调用方通常还会遍历它，拿到空列表比 KeyError 更好诊断。
    """
    res = _maybe_json(res)
    if not isinstance(res, dict):
        return []
    data = _maybe_json(res.get("data"))
    if isinstance(data, dict) and "taskDefinitionList" in data:
        tds = _maybe_json(data.get("taskDefinitionList"))
        return tds if isinstance(tds, list) else []
    # 已经是解包后的 data
    tds = _maybe_json(res.get("taskDefinitionList"))
    return tds if isinstance(tds, list) else []


def dependence_of(task: dict) -> list:
    """安全取任务的依赖条目列表（``taskParams.dependence.dependTaskList``）。

    ★ taskParams 与各级 dependence 字段 DS 也可能返回 JSON **字符串**，
      与 task_definitions 一样先解码，否则依赖引用会被静默当成「无依赖」
      （删除前的 DWS→DWD 引用检查就依赖这个函数，漏判即放行删除）。
    """
    if not isinstance(task, dict):
        return []
    params = _maybe_json(task.get("taskParams"))
    if not isinstance(params, dict):
        return []
    dep = _maybe_json(params.get("dependence"))
    if not isinstance(dep, dict):
        return []
    lst = _maybe_json(dep.get("dependTaskList"))
    return lst if isinstance(lst, list) else []


# ---------- 旧脚本兼容层（2026-10-15） ----------
# 历史脚本各自手写了一份 urllib HTTP 层，形态基本统一为：
#     call(method, path, params=None, form=None, body=None, _retry=True) + login()
# 这里给出一个薄封装，让它们能一次性切到本模块、删掉各自的重复实现：
#
#     from ds_client import legacy_client
#     ds = legacy_client(base=DS, user=USER, password=PWD,
#                        allow_admin=True, timeout=300)
#     ds.login()                                  # 建立/复用会话（磁盘会话优先）
#     ds.call("GET", "/projects", params={...})
#     ds.call("PUT", path, form={...})            # 401 自动重登并重试
#     ds.call("POST", path, body={...})           # JSON body
#
# ★ 语义对齐说明：
#   · `_retry=True`  → `raise_on_401=True`（401 时重登并重试）
#   · `_retry=False` → `raise_on_401=False`（不重登；401 时返回 None）
#   · `doseq=True` 已固化在 DSClient 内部（与历史 _raw 一致）
#   · `timeout` 默认取历史最常见值 300s，可按脚本原来的值显式传
class LegacyCaller:
    """把 `DSClient` 包成「`call(...)` + `login()`」的旧式薄封装。"""

    def __init__(self, user=DEFAULT_USER, password=DEFAULT_PWD, base=BASE,
                 timeout=300, allow_admin=False, verbose=False, **kw):
        # ★ 2026-10-22：password=None 时交给 DSClient 按账号惰性解析，
        #   本类不再持有任何口令字面量。
        self.client = DSClient(user=user, password=password, base=base,
                               allow_admin=allow_admin, verbose=verbose, **kw)
        self.client.timeout = timeout

    @property
    def sid(self):
        return self.client.sid

    def login(self):
        """返回 sessionId。构造时已完成登录或复用磁盘会话。"""
        return self.client.sid

    def call(self, method, path, params=None, form=None, body=None, _retry=True):
        return self.client.call(method, path, form=form, params=params, body=body,
                                raise_on_401=bool(_retry))

    def close(self):
        self.client.close()


def legacy_client(**kw):
    """一行式入口：`legacy_client(base=..., user=..., password=..., allow_admin=True)`。"""
    return LegacyCaller(**kw)


if __name__ == "__main__":
    # 自检：登录 → 复用 → 查项目
    print("--- 第一次（可能新登录）---")
    d1 = DSClient()
    j = d1.call("GET", "/projects", params={"pageNo": 1, "pageSize": 10})
    names = [p["name"] for p in (j.get("data") or {}).get("totalList", [])]
    print("可见项目:", names)
    print("--- 第二次（应复用磁盘会话）---")
    d2 = DSClient()
    print("sid 一致:", d1.sid == d2.sid)
