# doccano 本地运行指南（Windows / Git Bash）

> GitHub 精选：https://github.com/doccano/doccano （26k+★）
> 技术栈：Django 4 + Django REST framework 后端 + Vue2/Nuxt2(Vuetify) 前端 | 文本标注平台
> 用途：文本分类/序列标注/Seq2Seq 数据集构建，可导出 ML 训练数据

## 端口与账号

| 服务 | 端口 | 说明 |
|------|------|------|
| 前端 Nuxt dev | 3000 | 主入口，浏览器打开 http://localhost:3000 |
| 后端 API | 8000 | Django REST，/v1/ 前缀，DRF-yasg swagger /v1/swagger |
| 数据库 | — | SQLite（backend/db.sqlite3），零外部依赖 |

**登录账号**：`admin / 123456`（登录页 = http://localhost:3000/auth）

## 启停

双击（Git Bash 环境）：
- 启动：`start.cmd`（引擎 `_doccano-run.sh start`）
- 停止：`stop.cmd`（按端口 8000/3000 杀进程）
- 状态：`bash _doccano-run.sh status`
- ⚠️ 前端 webpack 冷编译需 4-6 分钟，首次启动耐心等

## 目录

```
doccano/
├── backend/               # Django 后端（manage.py 在此）
│   ├── db.sqlite3         # 本地数据库（已迁移+admin 建号）
│   └── requirements-local.txt  # 从 pyproject.toml 提取的 pip 依赖清单
├── frontend/              # Nuxt2 前端（yarn 1 + yarn.lock 安装）
├── .venv/                 # Python 3.13 虚拟环境（D 盘内）
├── _doccano-run.sh        # 启停引擎
├── start.cmd / stop.cmd / start.sh / stop.sh
└── _logs/                 # 前后端日志
```

## 关键构建信息

- Python：托管 3.13.12 建的 venv（`.venv`）；pip 源用阿里云（清华镜像 403）
- Django 版本装到 4.2.30（pyproject 约束 ^4.1.7 兼容）；**django-allauth 必须钉 0.52.0**（新版要求 AccountMiddleware，doccano settings 没配会直接崩）
- 前端：**必须用 yarn 1（仓库自带 yarn.lock）**；pnpm 11 会拒绝 git 型子依赖（tui-editor→squire-rte，ERR_PNPM_EXOTIC_SUBDEP）；yarn.lock 里该依赖 resolved 已是 codeload 直链，直连可下载
- npm 包源：`--registry https://registry.npmmirror.com`（npmjs 被墙）
- Node 22 跑 Nuxt2/webpack4 必须 `NODE_OPTIONS=--openssl-legacy-provider`
- 启动命令：`corepack yarn@1.22.22 dev --hostname 127.0.0.1`

## 环境变量（后端启动必须）

```
DATABASE_URL=sqlite:///db.sqlite3
SECRET_KEY=doccano-local-dev-key
DEBUG=True
```

## 踩坑记录

1. 登录路由是 `/auth` 不是 `/auth/login`（404 页会误导）
2. 登录按钮是卡片右下角的「Login」文本链接（非明显按钮）
3. `manage.py create_admin` 在空库上会抛 User.DoesNotExist（半残命令），建号用 `createsuperuser --no-input` + `DJANGO_SUPERUSER_PASSWORD/EMAIL` 环境变量
4. 后端必须显式 `DJANGO_SETTINGS_MODULE` 或从 backend 目录运行；静态目录警告（client/dist）可忽略——前端 dev 模式独立跑

## 功能提示

- Celery + Redis 仅「数据导入/导出」异步任务需要；基础标注页不需要。如需导入数据集：起 Redis（6379）+ `celery -A config worker`（broker 默认 amqp，需在 settings/env 里指到 redis://）
- 标注流程：登录 → Create 建项目（选文本分类/序列标注/Seq2Seq）→ 导入数据集 → 进入标注页
