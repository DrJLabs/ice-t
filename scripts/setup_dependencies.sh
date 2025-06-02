#!/usr/bin/env bash
set -e

echo "🚀 Setting up ice-t development environment..."

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "⚡ Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "⬆️ Upgrading pip..."
python -m pip install --upgrade pip setuptools wheel --no-input --no-compile

# Install dependencies using pip-sync when available
if command -v pip-sync >/dev/null 2>&1 && \ 
   [ -f requirements.lock ] && [ -f dev-requirements.lock ]; then
    echo "🔄 Installing dependencies from lock files with pip-sync..."
    pip-sync requirements.lock dev-requirements.lock
else
    echo "📦 Installing dependencies..."
    python -m pip install --no-input --no-compile -r requirements.txt -r dev-requirements.txt
fi

# Install ice-t in development mode
echo "🔧 Installing ice-t in development mode..."
python -m pip install -e .

echo "✅ ice-t development environment ready!"
echo "💡 To activate: source .venv/bin/activate"
