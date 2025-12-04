#!/usr/bin/env bash
# Quick performance benchmark for uv vs pip

set -e

echo "==================================="
echo "UV vs PIP Performance Benchmark"
echo "==================================="

# Clean install with uv
echo -e "\n[1/2] Testing uv fresh install..."
rm -rf .venv-test-uv
UV_START=$SECONDS
uv venv .venv-test-uv > /dev/null 2>&1
uv pip install --quiet -r requirements.lock -p .venv-test-uv/bin/python > /dev/null 2>&1
UV_TIME=$(($SECONDS - $UV_START))
echo "✅ uv completed in ${UV_TIME}s"

# Clean install with pip
echo -e "\n[2/2] Testing pip fresh install..."
rm -rf .venv-test-pip
PIP_START=$SECONDS
python3 -m venv .venv-test-pip > /dev/null 2>&1
.venv-test-pip/bin/pip install --quiet -r requirements.lock > /dev/null 2>&1
PIP_TIME=$(($SECONDS - $PIP_START))
echo "✅ pip completed in ${PIP_TIME}s"

# Cleanup
rm -rf .venv-test-uv .venv-test-pip

# Results
SPEEDUP=$(awk "BEGIN {printf \"%.1f\", $PIP_TIME / $UV_TIME}")
echo -e "\n==================================="
echo "📊 Results:"
echo "  uv:  ${UV_TIME}s"
echo "  pip: ${PIP_TIME}s"
echo "  Speedup: ${SPEEDUP}x faster"
echo "==================================="
