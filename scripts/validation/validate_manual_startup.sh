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
