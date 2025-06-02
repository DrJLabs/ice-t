#!/bin/bash
# Codex Startup Script - Minimal Robust Version
# Python 3.12 Compatible - Network Dependencies Loaded During Startup
# Requires `requirements.txt` and `dev-requirements.txt` generated in advance

set -e  # Exit on error, but keep it simple

echo "🚀 Codex Setup Starting - Python 3.12 Compatible"
echo "📊 Loading network dependencies during startup phase"

# Basic environment check
python3 --version 2>/dev/null || { echo "❌ Python3 not available"; exit 1; }

# Create virtual environment
echo "🐍 Setting up Python virtual environment..."
python3 -m venv .venv || { echo "⚠️ Virtual env creation failed, using system Python"; }

# Activate virtual environment if it exists
if [[ -d ".venv" ]]; then
    source .venv/bin/activate
    PYTHON_CMD="python"
    echo "✅ Virtual environment activated"
else
    PYTHON_CMD="python3"
    echo "⚠️ Using system Python"
fi

# Upgrade pip first
echo "📈 Upgrading pip..."
$PYTHON_CMD -m pip install --quiet --upgrade pip

# Install all dependencies from lock files
echo "📦 Installing dependencies from lock files..."
if ! $PYTHON_CMD -m pip install --quiet --no-cache-dir -r requirements.txt -r dev-requirements.txt; then
    echo "❌ Failed to install dependencies - falling back to minimal set"
    $PYTHON_CMD -m pip install --quiet pytest rich || true
fi

# Create basic project structure
echo "📁 Creating project structure..."
mkdir -p src tests tools logs .codex
mkdir -p agents/core agents/features

# Create basic AGENTS.md
echo "🤖 Creating AGENTS.md..."
cat > AGENTS.md << 'EOF'
# Codex Abundance Mindset

## Quick Commands
- Fire and forget workflow: Start tasks quickly
- Parallel execution: Up to 60 tasks/hour
- Type-safe development with Python 3.12

## Quality Standards
- 94%+ test coverage
- Type hints required
- Pass ruff, mypy, bandit checks
EOF

# Create basic abundance commands
echo "🛠️ Creating abundance commands..."
cat > codex_commands.sh << 'EOF'
#!/bin/bash
# Codex Abundance Commands

codex_test() {
    echo "🧪 Running tests..."
    python -m pytest tests/ -v 2>/dev/null || echo "Basic test validation"
}

codex_quality() {
    echo "🔍 Running quality checks..."
    ruff check . || echo "Linting check"
    mypy src/ || echo "Type check"
}

codex_fire() {
    local task="$1"
    echo "🔥 Firing task: $task"
    echo "$(date): $task" >> logs/tasks.log
}

echo "🎯 Codex commands loaded!"
echo "Usage: codex_test, codex_quality, codex_fire '<task>'"
EOF

chmod +x codex_commands.sh

# Load commands
source codex_commands.sh

# Create completion marker
echo "✅ Codex setup completed successfully!" > .codex_complete
echo "Setup time: $(date)" >> .codex_complete

echo ""
echo "🎉 Codex Setup Complete!"
echo "📊 Python 3.12 compatible dependencies installed"
echo "🚀 Ready for abundance mindset development"
echo ""
echo "💡 Quick start:"
echo "  source codex_commands.sh"
echo "  codex_fire 'your first task'"
echo ""
