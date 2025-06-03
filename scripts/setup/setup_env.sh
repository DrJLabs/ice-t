#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate
python -m pip install --upgrade pip

if command -v pip-sync >/dev/null 2>&1 && \
   [ -f requirements.txt ] && [ -f dev-requirements.txt ]; then
    pip-sync requirements.txt dev-requirements.txt
else
    pip install -r requirements.txt -r dev-requirements.txt
fi
pip install -e .
echo "✅ Environment ready"
