#!/usr/bin/env bash
# Generate requirements.in files from pyproject.toml
set -e

if ! command -v pip-compile >/dev/null 2>&1; then
    echo "pip-compile not found. Please install pip-tools." >&2
    exit 1
fi

# Generate requirements.in for runtime dependencies
pip-compile pyproject.toml --output-file requirements.in

# Generate dev-requirements.in including dev extras
pip-compile pyproject.toml --extra dev --output-file dev-requirements.in

echo "Generated requirements.in and dev-requirements.in"

