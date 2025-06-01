#!/bin/bash
# Check if startup scripts are current and functional

echo "🔍 Checking startup script currency..."

# Check main setup script
if [ -f "setup_codex.sh" ]; then
    SETUP_SIZE=$(wc -l < setup_codex.sh)
    echo "✅ setup_codex.sh exists ($SETUP_SIZE lines)"
else
    echo "❌ setup_codex.sh missing"
    exit 1
fi

# Check command system
if [ -f "codex_commands.sh" ]; then
    COMMANDS_SIZE=$(wc -l < codex_commands.sh)
    echo "✅ codex_commands.sh exists ($COMMANDS_SIZE lines)"
else
    echo "❌ codex_commands.sh missing"
    exit 1
fi

# Check SPARC tools
SPARC_TOOLS=$(ls tools/sparc_*.py 2>/dev/null | wc -l)
if [ $SPARC_TOOLS -gt 0 ]; then
    echo "✅ SPARC tools available ($SPARC_TOOLS tools)"
else
    echo "❌ SPARC tools missing"
    exit 1
fi

# Check agent configurations
if [ -d "agents" ]; then
    AGENT_FILES=$(find agents -name "*.md" | wc -l)
    echo "✅ Agent configurations available ($AGENT_FILES files)"
else
    echo "⚠️  Agent configurations not in nested structure"
fi

# Check requirements
if [ -f "requirements.txt" ] && [ -f "dev-requirements.txt" ]; then
    REQ_COUNT=$(cat requirements.txt dev-requirements.txt | grep -v '^#' | grep -v '^$' | wc -l)
    echo "✅ Requirements files exist ($REQ_COUNT packages)"
else
    echo "❌ Requirements files missing"
    exit 1
fi

echo "🎉 Startup system currency check complete!"
