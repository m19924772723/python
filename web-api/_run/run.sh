#!/usr/bin/env bash
# =============================================================================
# Python Web 项目统一启停引擎（与 java/_run/run.sh 同一套约定）
#   用法: run.sh fastapi-demo start|stop|restart|status
#   日志: _run/logs/<key>.log   PID: _run/pids/<key>.pid
# =============================================================================
set -u

BASE="D:/code/workbuddy/workbuddy-project/python/web-api"
RUN="$BASE/_run"
LOGS="$RUN/logs"; PIDS="$RUN/pids"
mkdir -p "$LOGS" "$PIDS"

PY="C:/Users/1/.workbuddy/binaries/python/envs/default/Scripts/python.exe"
FAPI="$BASE/fastapi"              # fastapi 官方仓库（源码运行）
DEMO="$BASE/fastapi-demo"         # 演示应用
HC="$BASE/healthchecks"           # healthchecks 全栈项目（Django）
STUB="$BASE/_stub"                # pycurl 兼容桩
PORT=8900
HC_PORT=8910
# 必须禁用 MSYS 参数改写：否则 /F /T /PID 会被转成路径（报 无效参数 'F:/'）
export MSYS2_ARG_CONV_EXCL='*'

C_OK="\033[32m"; C_ERR="\033[31m"; C_WARN="\033[33m"; C_DIM="\033[90m"; C_END="\033[0m"
ok()   { printf "${C_OK}[OK]${C_END} %s\n" "$*"; }
info() { printf "${C_DIM}[..]${C_END} %s\n" "$*"; }
warn() { printf "${C_WARN}[!]${C_END} %s\n" "$*"; }
err()  { printf "${C_ERR}[X]${C_END} %s\n" "$*"; }

port_pid() {
  netstat -ano 2>/dev/null | tr -d '\r' \
    | awk -v pp=":$1" '$2 ~ (pp"$") && $4=="LISTENING" {print $5; exit}'
}
port_up() { [ -n "$(port_pid "$1")" ]; }
http_code() { curl -s --noproxy '*' -o /dev/null -m 4 -w "%{http_code}" "http://127.0.0.1:$1$2" 2>/dev/null; }

banner() {
  echo
  echo "============================================================"
  echo "  $1"
  echo "  $(date '+%Y-%m-%d %H:%M:%S')"
  echo "============================================================"
}

start_fastapi_demo() {
  banner "FastAPI 演示服务（端口 $PORT，框架源码直跑）"
  if port_up "$PORT"; then warn "$PORT 已在运行，跳过启动"; return 0; fi
  info "框架来源：fastapi 官方仓库源码（PYTHONPATH=$FAPI）"
  (
    cd "$DEMO"
    PYTHONPATH="$FAPI" nohup "$PY" -m uvicorn app:app \
      --host 127.0.0.1 --port "$PORT" >> "$LOGS/fastapi-demo.log" 2>&1 < /dev/null &
    echo $! > "$PIDS/fastapi-demo.pid"
  )
  local i=0
  while [ "$i" -lt 30 ]; do
    if port_up "$PORT"; then
      ok "端口 $PORT 已就绪（HTTP $(http_code "$PORT" /docs)）"
      echo
      info "Swagger 交互文档  http://127.0.0.1:$PORT/docs"
      info "ReDoc 文档        http://127.0.0.1:$PORT/redoc"
      info "API 根            http://127.0.0.1:$PORT/"
      info "日志              $LOGS/fastapi-demo.log"
      return 0
    fi
    sleep 1; i=$((i+1))
    [ $((i % 10)) -eq 0 ] && info "等待端口 $PORT … ${i}s/30s"
  done
  err "端口 $PORT 未就绪，请查看 $LOGS/fastapi-demo.log"
  tail -15 "$LOGS/fastapi-demo.log"
  return 1
}

stop_fastapi_demo() {
  banner "停止 FastAPI 演示服务"
  local pid; pid="$(port_pid "$PORT")"
  if [ -z "$pid" ]; then info "端口 $PORT 未在运行"; else
    info "结束 uvicorn（PID $pid）…"
    taskkill /F /T /PID "$pid" 2>&1 | tr -d '\r' | sed 's/^/    /'
    local i=0
    while port_up "$PORT" && [ "$i" -lt 12 ]; do sleep 1; i=$((i+1)); done
    port_up "$PORT" && err "端口 $PORT 仍在监听" || ok "已停止（端口 $PORT 已释放）"
  fi
  [ -f "$PIDS/fastapi-demo.pid" ] && rm -f "$PIDS/fastapi-demo.pid"
}

KEY="${1:-fastapi-demo}"; ACTION="${2:-start}"

start_healthchecks() {
  banner "healthchecks 全栈监控平台（端口 $HC_PORT，Django + SQLite）"
  if port_up "$HC_PORT"; then warn "$HC_PORT 已在运行，跳过启动"; return 0; fi
  if [ ! -f "$HC/hc.sqlite" ]; then
    info "首次运行：迁移数据库 …"
    ( cd "$HC" && SECRET_KEY="hc-demo-2026" PYTHONPATH="$STUB" "$PY" manage.py migrate --noinput >> "$LOGS/healthchecks.log" 2>&1 )
    ( "$PY" "$BASE/_demos/hc_superuser.py" >> "$LOGS/healthchecks.log" 2>&1 )
  fi
  (
    cd "$HC"
    SECRET_KEY="hc-demo-2026" PYTHONPATH="$STUB" ALLOWED_HOSTS="127.0.0.1,localhost" nohup "$PY" manage.py runserver 127.0.0.1:$HC_PORT --noreload \
      >> "$LOGS/healthchecks.log" 2>&1 < /dev/null &
    echo $! > "$PIDS/healthchecks.pid"
  )
  local i=0
  while [ "$i" -lt 40 ]; do
    if port_up "$HC_PORT"; then
      ok "端口 $HC_PORT 已就绪（HTTP $(http_code "$HC_PORT" /)）"
      echo
      info "监控面板  http://127.0.0.1:$HC_PORT/  （登录 admin@example.org / hc123456）"
      info "登录页    http://127.0.0.1:$HC_PORT/accounts/login/"
      info "Django 后台 http://127.0.0.1:$HC_PORT/admin/"
      info "日志      $LOGS/healthchecks.log"
      return 0
    fi
    sleep 1; i=$((i+1))
    [ $((i % 10)) -eq 0 ] && info "等待端口 $HC_PORT … ${i}s/40s"
  done
  err "端口 $HC_PORT 未就绪，日志尾部："
  tail -15 "$LOGS/healthchecks.log"
  return 1
}

stop_healthchecks() {
  banner "停止 healthchecks"
  local pid; pid="$(port_pid "$HC_PORT")"
  if [ -z "$pid" ]; then info "端口 $HC_PORT 未在运行"; else
    info "结束 Django（PID $pid）…"
    taskkill /F /T /PID "$pid" 2>&1 | tr -d '\r' | sed 's/^/    /'
    local i=0
    while port_up "$HC_PORT" && [ "$i" -lt 12 ]; do sleep 1; i=$((i+1)); done
    port_up "$HC_PORT" && err "端口 $HC_PORT 仍在监听" || ok "已停止（端口 $HC_PORT 已释放）"
  fi
  [ -f "$PIDS/healthchecks.pid" ] && rm -f "$PIDS/healthchecks.pid"
}

case "$KEY" in
  fastapi-demo)
    case "$ACTION" in
      start)   start_fastapi_demo ;;
      stop)    stop_fastapi_demo ;;
      restart) stop_fastapi_demo; sleep 1; start_fastapi_demo ;;
      status)
        banner "状态：fastapi-demo"
        if port_up "$PORT"; then ok "端口 $PORT 监听中（PID $(port_pid "$PORT")），/docs HTTP $(http_code "$PORT" /docs)"; else warn "端口 $PORT 未运行"; fi ;;
      *) echo "用法: run.sh fastapi-demo start|stop|restart|status"; exit 2 ;;
    esac ;;
  healthchecks)
    case "$ACTION" in
      start)   start_healthchecks ;;
      stop)    stop_healthchecks ;;
      restart) stop_healthchecks; sleep 1; start_healthchecks ;;
      status)
        banner "状态：healthchecks"
        if port_up "$HC_PORT"; then ok "端口 $HC_PORT 监听中（PID $(port_pid "$HC_PORT")），首页 HTTP $(http_code "$HC_PORT" /)"; else warn "端口 $HC_PORT 未运行"; fi ;;
      *) echo "用法: run.sh healthchecks start|stop|restart|status"; exit 2 ;;
    esac ;;
  *) echo "未知项目: $KEY（当前可用: fastapi-demo healthchecks）"; exit 2 ;;
esac
