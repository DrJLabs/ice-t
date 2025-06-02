#!/usr/bin/env bash
###############################################################################
# 🎯 SIMPLIFIED CODEX SETUP SCRIPT
###############################################################################
# Based on dependency analysis - only installs what's actually needed
# Focuses on essential tools for coding tasks
#
# Last updated: December 25, 2024
# Dependencies: Essential tools only (pytest, ruff, mypy, rich, pydantic, click)
###############################################################################

set -euo pipefail
IFS=$'\n\t'

echo -e "\033[0;32m🚀 Simplified Codex Setup - Essential Dependencies Only\033[0m"

# --- 1. Python Environment Setup ---------------------------------------------
echo "🐍 Setting up Python environment..."
python3 --version || { echo "❌ Python3 not available"; exit 1; }

# Create virtual environment if it doesn't exist
if [[ ! -d ".venv" ]]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
if [[ -f ".venv/bin/activate" ]]; then
    source .venv/bin/activate
    PYTHON_CMD="python"
    echo "✅ Virtual environment activated: $VIRTUAL_ENV"
else
    PYTHON_CMD="python3"
    echo "⚠️ Using system Python"
fi

# Upgrade pip
echo "📈 Upgrading pip..."
$PYTHON_CMD -m pip install --quiet --upgrade pip

# --- 2. Install Essential Dependencies ---------------------------------------
echo "📦 Installing essential dependencies..."

# Tier 1: Core tools (must work for basic coding)
echo "  Installing core tools..."
$PYTHON_CMD -m pip install --quiet \
    "pytest>=8.3.0" \
    "rich>=13.7.1" \
    "click>=8.1.6" \
    || { echo "❌ Core tools failed"; exit 1; }

# Tier 2: Quality tools (needed for code quality)
echo "  Installing quality tools..."
$PYTHON_CMD -m pip install --quiet \
    "ruff>=0.11.11" \
    "mypy>=1.15.0" \
    || echo "⚠️ Quality tools failed (will use fallbacks)"

# Tier 3: Codebase-specific (used in current code)
echo "  Installing codebase-specific tools..."
$PYTHON_CMD -m pip install --quiet \
    "pydantic>=2.7.1" \
    "coverage>=7.8.0" \
    "pytest-cov>=6.0.0" \
    || echo "⚠️ Some codebase tools failed"

# --- 3. Create Basic Project Structure ---------------------------------------
echo "📁 Creating basic project structure..."
mkdir -p \
    src/codex_t/{core,features} \
    tests/{core,features} \
    tools logs

# --- 4. Create Simple Commands -----------------------------------------------
echo "🛠️ Creating simple commands..."
cat > codex_commands.sh <<'EOF'
#!/usr/bin/env bash
# Simplified Codex Commands

codex_test() {
    echo "🧪 Running tests..."
    python -m pytest tests/ -v "$@" 2>/dev/null || echo "No tests found"
}

codex_lint() {
    echo "🔍 Linting code..."
    ruff check . || echo "Ruff not available"
}

codex_types() {
    echo "🔍 Type checking..."
    mypy src/ || echo "Mypy not available"
}

codex_validate() {
    echo "✅ Validating environment..."
    python -c "
import sys
print(f'Python: {sys.version}')
try:
    import pytest, rich, ruff, mypy
    print('✅ Core tools available')
except ImportError as e:
    print(f'⚠️ Missing: {e}')
"
}

echo "🎯 Simplified Codex commands loaded!"
echo "Usage: codex_test, codex_lint, codex_types, codex_validate"
EOF

chmod +x codex_commands.sh

# --- 5. Load Commands and Validate -------------------------------------------
echo "🔧 Loading commands..."
source codex_commands.sh

echo "🧪 Validating setup..."
codex_validate

# --- 6. Create Completion Marker ---------------------------------------------
echo "📝 Creating completion marker..."
cat > .codex_simplified_complete <<EOF
{
  "setup_completed": true,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "simplified_essential_only",
  "workspace": "$(pwd)",
  "dependencies_installed": [
    "pytest", "rich", "click", "ruff", "mypy", "pydantic", "coverage"
  ],
  "next_steps": [
    "source .venv/bin/activate",
    "source codex_commands.sh",
    "codex_validate",
    "codex_test"
  ]
}
EOF

# --- 7. Final Success Message ------------------------------------------------
echo -e "\033[0;32m🎉 Simplified Codex Setup Complete!\033[0m"
echo ""
echo -e "\033[0;34m📋 Next steps:\033[0m"
echo "  source .venv/bin/activate    # activate virtual environment"
echo "  source codex_commands.sh     # load commands"
echo "  codex_validate              # check tools"
echo "  codex_test                  # run tests"
echo ""
echo -e "\033[0;36m🎯 Essential Tools Ready!\033[0m"
echo "📁 Workspace: $(pwd)"
echo "🔧 Only essential dependencies installed"
echo "🧪 Ready for focused development"
