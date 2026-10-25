# healthchecks 本地运行说明（Windows）

> 项目：[healthchecks/healthchecks](https://github.com/healthchecks/healthchecks)（8.6k★）
> Django 全栈定时任务心跳监控平台：**完整网页前端 + 后端 + Admin 后台**，SQLite 免装数据库
> 源码：本目录（官方 master，v5.1-dev，2026-10 快照）· 端口 **8910**

## 启动 / 停止

| 方式 | 启动 | 停止 |
|------|------|------|
| 双击（推荐） | `start.cmd` | `stop.cmd` |
| Git Bash | `./start.sh` | `./stop.sh` |
| 统一入口 | `bash ../_run/run.sh healthchecks start` | `bash ../_run/run.sh healthchecks stop` |

首次启动自动完成：migrate 建表（`hc.sqlite`）+ 创建超级用户。

**登录账号：`admin@example.org` / `hc123456`**（Django admin 同账号）

## 打开什么

| 地址 | 说明 |
|------|------|
| http://127.0.0.1:8910/ | 登录后进入「My Projects」控制台，可新建项目、添加监控项 |
| http://127.0.0.1:8910/accounts/login/ | 登录页（邮箱+密码） |
| http://127.0.0.1:8910/admin/ | Django Admin 后台（用户/项目/监控项全可管） |

核心玩法：给某个定时任务建一个 Check → 平台给你一个 ping URL → 任务结尾 `curl` 一下 → 没按时 ping 就发告警（邮件/Webhook 等，出站通知需 pycurl，Windows 演示环境为桩实现）。

## 实测记录（2026-10-23）

```
migrate           -> 全部迁移 OK（hc.sqlite）
登录              -> admin@example.org 登录成功，进入 My Projects
/admin/           -> "My checks Administration" 后台正常
stop              -> 端口 8910 释放
截图              -> _shots/03-hc-login.png / 04-hc-dashboard.png / 05-hc-admin.png
```

## Windows 适配点（与官方的差异）

1. **pycurl 无 Windows 轮子** → 用兼容桩 `../_stub/pycurl.py`（PYTHONPATH 前置），
   仅保证启动；出站告警请求会报「pycurl stub」。完整功能请在 WSL/Linux 跑。
2. **ALLOWED_HOSTS** → 启动命令已带 `ALLOWED_HOSTS=127.0.0.1,localhost`，否则 Django 6 返回 400。
3. **依赖** → 剔除 pycurl 后其余 19 包从阿里云镜像安装（清华镜像对 pip 403）。
4. **Django 6.1** → `createsuperuser` 交互在脚本里被沙箱拦，改用 `manage.py shell` 建用户
   （见 `../_demos/hc_superuser.py`，首次启动自动执行）。
