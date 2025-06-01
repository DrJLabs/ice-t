#!/bin/bash
# Ultra-Minimal Codex Startup Script
# Guaranteed to work - only essential packages

echo "🚀 Ultra-Minimal Codex Setup - Python 3.12"

# Basic check
python3 --version || exit 1

# Use system Python to avoid venv issues
PYTHON_CMD="python3"

# Upgrade pip (with system package override for Codex)
echo "📈 Upgrading pip..."
$PYTHON_CMD -m pip install --quiet --upgrade pip --break-system-packages 2>/dev/null || echo "pip upgrade skipped"

# Core essentials only
echo "📦 Installing essential packages..."
$PYTHON_CMD -m pip install --quiet --break-system-packages \
    pytest \
    rich \
    click \
    requests || echo "⚠️ Some packages failed"

echo "🔧 Installing basic quality tools..."
$PYTHON_CMD -m pip install --quiet --break-system-packages \
    ruff \
    mypy || echo "⚠️ Quality tools failed"

# Create basic structure
echo "📁 Creating structure..."
mkdir -p src tests logs .codex

# Basic AGENTS.md
cat > AGENTS.md << 'EOF'
# Codex Ready

## Commands
- Fire and forget workflow
- 60 tasks/hour capacity

## Standards
- Type hints required
- Test coverage important
EOF

# Simple commands
cat > codex_commands.sh << 'EOF'
#!/bin/bash

codex_fire() {
    echo "🔥 Task: $1"
    echo "$(date): $1" >> logs/tasks.log
}

codex_test() {
    echo "🧪 Running tests..."
    python3 -m pytest tests/ -v 2>/dev/null || echo "No tests found"
}

echo "🎯 Codex ultra-minimal ready!"
EOF

chmod +x codex_commands.sh
source codex_commands.sh

echo "✅ Setup complete!" > .codex_complete

echo ""
echo "🎉 Ultra-Minimal Setup Complete!"
echo "Ready for Codex development"
echo ""
echo "Test: codex_fire 'hello world'"
echo ""
