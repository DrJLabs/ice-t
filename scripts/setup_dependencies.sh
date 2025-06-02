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

# Upgrade pip and install dependencies
echo "⬆️ Upgrading pip and installing dependencies..."
python3 -m pip install --upgrade pip setuptools wheel --no-input --no-compile
python3 -m pip install --no-input --no-compile -r requirements.txt -r dev-requirements.txt

# Install ice-t in development mode
echo "🔧 Installing ice-t in development mode..."
python3 -m pip install -e .

echo "✅ ice-t development environment ready!"
echo "💡 To activate: source .venv/bin/activate" 
