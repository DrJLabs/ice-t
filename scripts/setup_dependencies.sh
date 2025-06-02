#!/usr/bin/env bash
set -e

echo "🚀 Setting up ice-t development environment..."

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "📦 Creating virtual environment..."
    PY_VERSION=$(cat .python-version)
    PY_BIN="python${PY_VERSION}"
    if command -v "$PY_BIN" >/dev/null 2>&1; then
        "$PY_BIN" -m venv .venv
    else
        echo "⚠️  $PY_BIN not found, falling back to python3"
        python3 -m venv .venv
    fi
fi

# Activate virtual environment
echo "⚡ Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip and install dependencies
echo "⬆️ Upgrading pip and installing dependencies..."
python -m pip install --upgrade pip setuptools wheel --no-input --no-compile
python -m pip install --no-input --no-compile -r requirements.txt -r dev-requirements.txt

# Install ice-t in development mode
echo "🔧 Installing ice-t in development mode..."
python -m pip install -e .

echo "✅ ice-t development environment ready!"
echo "💡 To activate: source .venv/bin/activate"
