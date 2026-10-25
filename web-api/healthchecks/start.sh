#!/usr/bin/env bash
# healthchecks（端口 8910）start
exec bash "$(cd "$(dirname "$0")/.." && pwd)/_run/run.sh" healthchecks start
