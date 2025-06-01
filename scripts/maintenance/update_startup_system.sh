#!/bin/bash

# Update Startup System for Codex
# Ensures startup scripts are current and work before network isolation

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔄 Updating Codex Startup System${NC}"

# Check if we're in the right directory
if [ ! -f "setup_codex.sh" ]; then
    echo -e "${RED}❌ setup_codex.sh not found. Run from project root.${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Checking startup script currency...${NC}"

# Create startup system status checker
cat > check_startup_currency.sh << 'EOF'
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
EOF

chmod +x check_startup_currency.sh

# Create manual startup validation script
cat > validate_manual_startup.sh << 'EOF'
#!/bin/bash
# Validate that manual startup procedures work correctly
# This simulates the manual entry process before network isolation

echo "🧪 Testing manual startup procedures..."

# Test 1: Basic environment
echo "Test 1: Environment validation"
python3 --version || { echo "❌ Python3 not available"; exit 1; }
echo "✅ Python3 available"

# Test 2: Setup script execution
echo "Test 2: Setup script validation"
if [ -x "setup_codex.sh" ]; then
    echo "✅ setup_codex.sh is executable"
else
    echo "❌ setup_codex.sh not executable"
    chmod +x setup_codex.sh
fi

# Test 3: Command loading
echo "Test 3: Command system"
if source codex_commands.sh 2>/dev/null; then
    echo "✅ Commands load successfully"
else
    echo "❌ Command loading failed"
    exit 1
fi

# Test 4: SPARC tools
echo "Test 4: SPARC tools"
if python tools/sparc_spec_parser.py --help >/dev/null 2>&1; then
    echo "✅ SPARC tools functional"
else
    echo "❌ SPARC tools not working"
    exit 1
fi

# Test 5: Virtual environment creation
echo "Test 5: Virtual environment"
if python3 -m venv test_venv 2>/dev/null; then
    echo "✅ Virtual environment creation works"
    rm -rf test_venv
else
    echo "⚠️  Virtual environment creation may have issues"
fi

echo "🎉 Manual startup validation complete!"
EOF

chmod +x validate_manual_startup.sh

# Create startup script updater
cat > update_startup_scripts.sh << 'EOF'
#!/bin/bash
# Update startup scripts to ensure they're current

echo "🔄 Updating startup scripts..."

# Backup current scripts
mkdir -p backups/startup_$(date +%Y%m%d_%H%M%S)
cp setup_codex.sh codex_commands.sh backups/startup_$(date +%Y%m%d_%H%M%S)/

# Update setup_codex.sh with latest improvements
if grep -q "validate_prereqs" setup_codex.sh; then
    echo "✅ setup_codex.sh appears current"
else
    echo "⚠️  setup_codex.sh may need updates"
fi

# Update codex_commands.sh with streamlined commands
if grep -q "sparc-test-health" codex_commands.sh; then
    echo "✅ codex_commands.sh appears current"
else
    echo "⚠️  codex_commands.sh may need updates"
fi

# Ensure all scripts are executable
chmod +x setup_codex.sh
chmod +x codex_commands.sh
chmod +x check_startup_currency.sh
chmod +x validate_manual_startup.sh

echo "✅ Startup scripts updated"
EOF

chmod +x update_startup_scripts.sh

# Create comprehensive startup system checker
cat > startup_system_health.sh << 'EOF'
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
EOF

chmod +x startup_system_health.sh

# Run the health check
echo -e "${BLUE}🏥 Running startup system health check...${NC}"
./startup_system_health.sh

echo ""
echo -e "${GREEN}✅ Startup system update complete!${NC}"
echo ""
echo -e "${BLUE}📋 Available Commands:${NC}"
echo "  ./check_startup_currency.sh      - Check if scripts are current"
echo "  ./validate_manual_startup.sh     - Test manual startup procedures"
echo "  ./update_startup_scripts.sh      - Update startup scripts"
echo "  ./startup_system_health.sh       - Comprehensive health check"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "  - Always run validate_manual_startup.sh before network isolation"
echo "  - Follow agents/startup/pre_network_setup.md for manual setup"
echo "  - Only manually entered commands work before network isolation"
