#!/usr/bin/env bash
# Quick performance benchmark for uv vs pip

set -e

echo "==================================="
echo "UV vs PIP Performance Benchmark"
echo "==================================="

# Clean install with uv
echo -e "\n[1/2] Testing uv fresh install..."
rm -rf .venv-test-uv
time uv venv .venv-test-uv > /dev/null 2>&1
time uv pip install --quiet -r requirements.lock -p .venv-test-uv/bin/python > /dev/null 2>&1
UV_TIME=$SECONDS
echo "✅ uv completed in ${UV_TIME}s"

# Clean install with pip
echo -e "\n[2/2] Testing pip fresh install..."
rm -rf .venv-test-pip
python3 -m venv .venv-test-pip > /dev/null 2>&1
time .venv-test-pip/bin/pip install --quiet -r requirements.lock > /dev/null 2>&1
PIP_TIME=$SECONDS
echo "✅ pip completed in ${PIP_TIME}s"

# Cleanup
rm -rf .venv-test-uv .venv-test-pip

# Results
SPEEDUP=$(echo "scale=1; $PIP_TIME / $UV_TIME" | bc)
echo -e "\n==================================="
echo "📊 Results:"
echo "  uv:  ${UV_TIME}s"
echo "  pip: ${PIP_TIME}s"
echo "  Speedup: ${SPEEDUP}x faster"
echo "==================================="
