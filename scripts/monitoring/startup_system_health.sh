#!/bin/bash
# Comprehensive startup system health check

echo "🏥 Startup System Health Check"
echo "=============================="

# Check 1: File existence
echo "📁 File Existence Check:"
files=("setup_codex.sh" "codex_commands.sh" "requirements.txt" "dev-requirements.txt")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file MISSING"
    fi
done

# Check 2: Script permissions
echo ""
echo "🔐 Permission Check:"
scripts=("setup_codex.sh" "codex_commands.sh")
for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        echo "  ✅ $script executable"
    else
        echo "  ❌ $script not executable"
        chmod +x "$script"
        echo "    🔧 Fixed permissions for $script"
    fi
done

# Check 3: SPARC tools
echo ""
echo "🛠️  SPARC Tools Check:"
if [ -d "tools" ]; then
    sparc_count=$(ls tools/sparc_*.py 2>/dev/null | wc -l)
    echo "  ✅ $sparc_count SPARC tools found"
else
    echo "  ❌ tools directory missing"
fi

# Check 4: Agent configurations
echo ""
echo "🤖 Agent Configuration Check:"
if [ -d "agents" ]; then
    agent_count=$(find agents -name "*.md" 2>/dev/null | wc -l)
    echo "  ✅ $agent_count agent configuration files"
else
    echo "  ⚠️  agents directory not found (will be created)"
fi

# Check 5: Dependencies
echo ""
echo "📦 Dependency Check:"
if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version 2>&1)
    echo "  ✅ $python_version"
else
    echo "  ❌ Python3 not available"
fi

# Check 6: Network isolation readiness
echo ""
echo "🔒 Network Isolation Readiness:"
if [ -f "agents/startup/pre_network_setup.md" ]; then
    echo "  ✅ Pre-isolation guide available"
else
    echo "  ⚠️  Pre-isolation guide missing"
fi

echo ""
echo "🎯 Health Check Summary:"
echo "  - Run ./check_startup_currency.sh for detailed checks"
echo "  - Run ./validate_manual_startup.sh to test procedures"
echo "  - Follow agents/startup/pre_network_setup.md before isolation"
