#!/bin/bash

# Diagnostic Script for GitHub Actions Runner Environment
# This script helps identify environment issues that cause setup failures

echo "🔍 GitHub Actions Runner Environment Diagnostic"
echo "=============================================="

echo
echo "📊 Basic Environment Information:"
echo "  Current shell: $0"
echo "  SHELL variable: ${SHELL:-not set}"
echo "  User: $(whoami)"
echo "  Home: ${HOME:-not set}"
echo "  PWD: $(pwd)"
echo "  Hostname: $(hostname)"

echo
echo "🔧 GitHub Actions Variables:"
echo "  GITHUB_WORKSPACE: ${GITHUB_WORKSPACE:-not set}"
echo "  GITHUB_REPOSITORY: ${GITHUB_REPOSITORY:-not set}"
echo "  RUNNER_NAME: ${RUNNER_NAME:-not set}"
echo "  RUNNER_WORKSPACE: ${RUNNER_WORKSPACE:-not set}"
echo "  GITHUB_ENV: ${GITHUB_ENV:-not set}"

echo
echo "🐍 Python Environment:"
echo "  System python3: $(/usr/bin/python3 --version 2>/dev/null || echo 'not found')"
echo "  System python3 location: $(which python3 2>/dev/null || echo 'not found')"
echo "  Current python: $(python --version 2>/dev/null || echo 'not found')"
echo "  Current python location: $(which python 2>/dev/null || echo 'not found')"

echo
echo "📦 Virtual Environment Status:"
echo "  VIRTUAL_ENV: ${VIRTUAL_ENV:-not set}"
echo "  _OLD_VIRTUAL_PATH: ${_OLD_VIRTUAL_PATH:-not set}"

echo
echo "🗂️ Directory Listing:"
echo "  Current directory contents:"
ls -la . | head -10

echo
echo "  Virtual environments:"
ls -la .runner-venv* 2>/dev/null || echo "    No .runner-venv* directories found"

echo
echo "💾 Disk Usage:"
echo "  Current directory: $(du -sh . 2>/dev/null || echo 'unknown')"
echo "  Available space: $(df -h . | tail -1 | awk '{print $4}' || echo 'unknown')"

echo
echo "🔍 PATH Analysis:"
echo "  Current PATH:"
echo "$PATH" | tr ':' '\n' | head -10

echo
echo "⚙️ Process Information:"
echo "  Running setup processes:"
ps aux | grep -E "(setup_runner|python)" | grep -v grep | head -5

echo
echo "🧪 Test Commands:"
echo "  Testing /usr/bin/python3 -m venv:"
if /usr/bin/python3 -m venv --help >/dev/null 2>&1; then
    echo "    ✅ venv module available"
else
    echo "    ❌ venv module not available"
fi

echo "  Testing virtual environment creation:"
TEST_VENV="/tmp/test-venv-$$"
if /usr/bin/python3 -m venv "$TEST_VENV" 2>/dev/null; then
    echo "    ✅ Can create virtual environment"
    rm -rf "$TEST_VENV"
else
    echo "    ❌ Cannot create virtual environment"
fi

echo
echo "🎯 Recommendations:"
if [ -n "${GITHUB_WORKSPACE:-}" ]; then
    echo "  - Running in GitHub Actions environment"
    echo "  - Use GITHUB_WORKSPACE as project directory"
else
    echo "  - Running in local environment"
    echo "  - Use script directory as project directory"
fi

if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo "  - Virtual environment detected: $VIRTUAL_ENV"
    echo "  - Consider deactivating before running setup"
else
    echo "  - No virtual environment active"
    echo "  - Safe to proceed with setup"
fi

echo
echo "✅ Diagnostic complete!"
