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
python3 -m pip install --upgrade pip setuptools wheel --no-input --no-compile

# Install dependencies
if command -v pip-sync >/dev/null 2>&1 && \
   [ -f requirements.lock ] && [ -f dev-requirements.lock ]; then
    echo "🔄 Installing dependencies from lock files with pip-sync..."
    pip-sync requirements.lock dev-requirements.lock
elif [ -f "requirements.txt" ] && [ -f "dev-requirements.txt" ]; then
    echo "📦 Installing dependencies from requirements.txt and dev-requirements.txt..."
    python3 -m pip install --no-input --no-compile -r requirements.txt -r dev-requirements.txt
else
    # Fallback if no lock files or requirements.txt files are found.
    # This assumes project dependencies (including dev) are defined in setup.py or pyproject.toml
    # and can be installed via extras.
    echo "📦 No standard lock or requirements files found. Installing dependencies from project definition with 'dev' extras..."
    python3 -m pip install --no-input --no-compile -e .[dev]
fi

# Ensure ice-t itself is installed in development mode with its dev dependencies.
# This step is crucial if the above dependency installation methods
# (e.g., pip-sync or installing from requirements.txt) do not inherently install
# the local package in editable mode with its '[dev]' extras.
echo "🔧 Installing ice-t in development mode with 'dev' extras..."
python3 -m pip install --no-input --no-compile -e .[dev]

echo "✅ ice-t development environment ready!"
echo "💡 To activate: source .venv/bin/activate"
