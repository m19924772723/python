#!/usr/bin/env bash
# FastAPI demo（端口 8900）启动
exec bash "$(cd "$(dirname "$0")/.." && pwd)/_run/run.sh" fastapi-demo start
