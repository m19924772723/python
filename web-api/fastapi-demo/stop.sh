#!/usr/bin/env bash
# FastAPI demo（端口 8900）停止
exec bash "$(cd "$(dirname "$0")/.." && pwd)/_run/run.sh" fastapi-demo stop
