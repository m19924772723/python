# FastAPI 精选项目运行说明

> 项目：[fastapi/fastapi](https://github.com/fastapi/fastapi)（86k★，Python Web 框架星标第一）
> 源码：`../fastapi/`（官方 master，v0.161.1-dev，2026-10 快照）
> 运行方式：**框架源码直跑**（`PYTHONPATH` 指向仓库，不用 pip 安装版）

## 启动 / 停止

| 方式 | 启动 | 停止 |
|------|------|------|
| 双击（推荐） | `start.cmd` | `stop.cmd` |
| Git Bash | `./start.sh` | `./stop.sh` |
| 统一入口 | `bash ../_run/run.sh fastapi-demo start` | `bash ../_run/run.sh fastapi-demo stop` |

- 端口：**8900**
- 日志：`../_run/logs/fastapi-demo.log`
- Python：托管 venv `C:\Users\1\.workbuddy\binaries\python\envs\default`（3.13.14）

## 打开什么

| 地址 | 说明 |
|------|------|
| http://127.0.0.1:8900/docs | **Swagger 交互文档**（可直接点 Try it out 调接口） |
| http://127.0.0.1:8900/redoc | ReDoc 风格文档 |
| http://127.0.0.1:8900/ | API 元信息 |
| http://127.0.0.1:8900/todos | TODO 列表（支持 `?done=` / `?q=` 过滤） |

演示应用 `app.py`：TODO 完整 CRUD，展示 FastAPI 核心卖点——
**类型即校验**（Pydantic 字段约束，越界返回 422）、**类型即文档**（/docs 自动生成）、装饰器路由、异常处理。

## 2026-10-23 实测记录

```
/docs  -> 200   /redoc -> 200
POST /todos {"title":"学 FastAPI 源码","priority":5}     -> 201, id=1
POST /todos {"priority":99}                              -> 422（校验拒绝）
GET  /todos?done=false                                   -> [id=1]
GET  /todos/999                                          -> 404 {"detail":"todo 999 不存在"}
stop 后端口 8900 已释放
```

## 环境备注

- 依赖只装了轮子：`starlette / pydantic / uvicorn[standard] / annotated-doc / opentelemetry-api / typing-inspection`（阿里云镜像 `https://mirrors.aliyun.com/pypi/simple/`）
- **清华镜像对 pip 返回 403**（curl/urllib 却 200），pip 一律走阿里云
- 没用 `pip install -e .`：master 分支构建后端 `pdm-backend` 在该网络下拉不到，且源码直跑更贴近「运行仓库本身」
