#!/usr/bin/env bash
# healthchecks（端口 8910）stop
exec bash "$(cd "$(dirname "$0")/.." && pwd)/_run/run.sh" healthchecks stop
