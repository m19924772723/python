"""pycurl 最小兼容桩（Windows 演示用）。

healthchecks 用 pycurl 给监控对象发 HTTP 通知，pycurl 在 Windows 无预编译轮子。
本桩只保证 `import pycurl` 与 Django 启动通过；出站通知调用 perform() 时报错，
不影响网页前后端本身。若需完整功能请用 WSL/Linux。
"""


class error(Exception):
    def __init__(self, code: int = 0, msg: str = "pycurl stub"):
        self.args = (code, msg)
        self.code = code

    def __str__(self) -> str:
        return f"[{self.code}] {self.msg}"


class Curl:
    def __init__(self) -> None:
        self._opts: dict = {}

    def setopt(self, key, value) -> None:
        self._opts[key] = value

    def perform(self) -> None:
        raise error(7, "pycurl stub: outbound HTTP disabled in Windows demo")

    def getinfo(self, *_):
        return 0

    def errstr(self) -> str:
        return "pycurl stub"

    def close(self) -> None:
        pass


# curl_easy 常量（数值无所谓，仅作键名占位）
NOSIGNAL = 99
PROTOCOLS = 8
PROTO_HTTP = 1
PROTO_HTTPS = 2
OPENSOCKETFUNCTION = 13
FOLLOWLOCATION = 52
MAXREDIRS = 68
TIMEOUT = 13
URL = 10002
USERPWD = 10005
HTTPHEADER = 10023
POSTFIELDS = 10015
UPLOAD = 40
INFILESIZE = 14
READDATA = 10009
CUSTOMREQUEST = 10036
WRITEDATA = 10011
RESPONSE_CODE = 2097154
SOCKET_BAD = -1

E_OPERATION_TIMEDOUT = 28
E_COULDNT_RESOLVE_HOST = 6
E_COULDNT_CONNECT = 7
E_TOO_MANY_REDIRECTS = 47
E_SSL_CONNECT_ERROR = 35
E_PEER_FAILED_VERIFICATION = 60
