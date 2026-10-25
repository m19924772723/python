#!/bin/bash
# doccano 启停引擎（Windows Git Bash）
# start: Django 后端 8000 + Nuxt 前端 3000
# stop : 按 8000/3000 杀进程
# 依赖: SQLite（库文件 backend/db.sqlite3，无需外部数据库）；Redis 仅数据导入等功能需要 celery，基础标注不用
export MSYS2_ARG_CONV_EXCL='*'
BASE="$(cd "$(dirname "$0")" && pwd)"
VENV="$BASE/.venv/Scripts"
FRONT="$BASE/frontend"
LOGS="$BASE/_logs"
mkdir -p "$LOGS"

port_up() { (echo > /dev/tcp/127.0.0.1/$1) >/dev/null 2>&1; }
kill_port() {
  local pids
  pids=$(netstat -ano | grep ":$1 .*LISTENING" | awk '{print $NF}' | sort -u)
  for pid in $pids; do taskkill /F /T /PID "$pid" >/dev/null 2>&1 && echo "[OK] 已停止进程 $pid（端口 $1）"; done
}

case "$1" in
  start)
    if port_up 8000; then echo "[OK] 后端已在运行（8000）"; else
      (cd "$BASE/backend" && DATABASE_URL="sqlite:///db.sqlite3" SECRET_KEY="doccano-local-dev-key" DEBUG="True" nohup "$VENV/python.exe" manage.py runserver 127.0.0.1:8000 > "$LOGS/server.log" 2>&1 < /dev/null &)
      i=0; while ! port_up 8000 && [ $i -lt 30 ]; do sleep 1; i=$((i+1)); done
      port_up 8000 && echo "[OK] 后端 8000 就绪" || { echo "[X] 后端启动失败，看 $LOGS/server.log"; exit 1; }
    fi
    if port_up 3000; then echo "[OK] 前端已在运行（3000）"; else
      (cd "$FRONT" && NODE_OPTIONS=--openssl-legacy-provider COREPACK_ENABLE_DOWNLOAD_PROMPT=0 nohup "C:/Users/1/.workbuddy/binaries/node/versions/22.22.2-6/corepack" yarn@1.22.22 dev --hostname 127.0.0.1 > "$LOGS/web.log" 2>&1 < /dev/null &)
      i=0; while ! port_up 3000 && [ $i -lt 420 ]; do sleep 1; i=$((i+1)); done
      port_up 3000 && echo "[OK] 前端 3000 就绪" || { echo "[X] 前端启动失败（webpack 冷编译需 4-6 分钟），看 $LOGS/web.log"; exit 1; }
    fi
    echo "========== doccano 启动完成 =========="
    echo " 前端    http://localhost:3000  (admin / 123456)"
    echo " 后端API  http://127.0.0.1:8000  (Django REST, /v1/)"
    echo "======================================"
    ;;
  stop)
    kill_port 3000
    kill_port 8000
    echo "[OK] doccano 已全部停止"
    ;;
  status)
    port_up 8000 && echo "后端 8000: UP" || echo "后端 8000: down"
    port_up 3000 && echo "前端 3000: UP" || echo "前端 3000: down"
    ;;
  *) echo "用法: $0 {start|stop|status}"; exit 1 ;;
esac
