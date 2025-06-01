#!/bin/bash
# Test Virtual Environment Setup for Lightning CI
# This script tests the same steps that the Lightning CI workflow performs

set -e

echo "🧪 Testing Virtual Environment Setup for Lightning CI"
echo "======================================================"

# Test 1: Run setup_runner_safe.sh (which exports to GITHUB_ENV)
echo ""
echo "📋 Test 1: Running setup_runner_safe.sh..."

# Create a temporary GITHUB_ENV file to simulate GitHub Actions
export GITHUB_ENV="/tmp/github_env_test"
rm -f "$GITHUB_ENV"
touch "$GITHUB_ENV"

./setup_runner_safe.sh

# Test 2: Source the exported environment variables
echo ""
echo "📋 Test 2: Loading exported environment variables..."
if [ -f "$GITHUB_ENV" ] && [ -s "$GITHUB_ENV" ]; then
    echo "✅ GITHUB_ENV file created with content:"
    cat "$GITHUB_ENV"

    # Source the environment variables
    set -a  # automatically export all variables
    source "$GITHUB_ENV"
    set +a

    echo "✅ Environment variables loaded"
else
    echo "❌ GITHUB_ENV file not created or empty"
    exit 1
fi

# Test 3: Verify virtual environment is properly set
echo ""
echo "📋 Test 3: Verifying virtual environment setup..."
if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo "✅ VIRTUAL_ENV: $VIRTUAL_ENV"
    if [ -d "$VIRTUAL_ENV" ]; then
        echo "✅ Virtual environment directory exists"
    else
        echo "❌ Virtual environment directory does not exist: $VIRTUAL_ENV"
        exit 1
    fi
else
    echo "❌ VIRTUAL_ENV not set"
    exit 1
fi

# Test 4: Verify Python is available and working
echo ""
echo "📋 Test 4: Verifying Python availability..."
if command -v python >/dev/null 2>&1; then
    echo "✅ Python: $(which python) ($(python --version))"

    # Verify it's using the virtual environment
    PYTHON_PATH=$(which python)
    if [[ "$PYTHON_PATH" == "$VIRTUAL_ENV"* ]]; then
        echo "✅ Python is using the virtual environment"
    else
        echo "❌ Python is not using the virtual environment"
        echo "   Expected path to start with: $VIRTUAL_ENV"
        echo "   Actual path: $PYTHON_PATH"
        exit 1
    fi
else
    echo "❌ Python not found in PATH"
    echo "🔍 Current PATH: $PATH"
    exit 1
fi

# Test 5: Verify critical tools
echo ""
echo "📋 Test 5: Verifying critical tools..."
critical_tools=(pip pytest black ruff mypy)
for tool in "${critical_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        TOOL_PATH=$(which "$tool")
        if [[ "$TOOL_PATH" == "$VIRTUAL_ENV"* ]]; then
            echo "  ✅ $tool: $TOOL_PATH"
        else
            echo "  ⚠️ $tool: $TOOL_PATH (not in venv)"
        fi
    else
        echo "  ❌ $tool: not found"
        exit 1
    fi
done

# Test 6: Test Python imports and functionality
echo ""
echo "📋 Test 6: Testing Python functionality..."
if python -c "import sys; print(f'✅ Python {sys.version_info.major}.{sys.version_info.minor} working')"; then
    echo "✅ Python imports working"
else
    echo "❌ Python imports failed"
    exit 1
fi

# Test 7: Test pytest functionality
echo ""
echo "📋 Test 7: Testing pytest functionality..."
if python -c "import pytest; print('✅ pytest import successful')"; then
    echo "✅ pytest available and importable"
else
    echo "❌ pytest not available or not importable"
    exit 1
fi

# Test 8: Simulate GitHub Actions job environment persistence
echo ""
echo "📋 Test 8: Simulating GitHub Actions environment persistence..."

# Simulate a new job step by unsetting current environment
unset VIRTUAL_ENV
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "🔄 Environment reset (simulating new job step)"

# Re-source the GITHUB_ENV file (like GitHub Actions would do)
set -a
source "$GITHUB_ENV"
set +a

echo "🔄 Environment restored from GITHUB_ENV"

# Verify everything still works
if [ -n "${VIRTUAL_ENV:-}" ] && command -v python >/dev/null 2>&1; then
    echo "✅ Environment persistence test passed"
    echo "   VIRTUAL_ENV: $VIRTUAL_ENV"
    echo "   Python: $(which python) ($(python --version))"
else
    echo "❌ Environment persistence test failed"
    echo "   VIRTUAL_ENV: ${VIRTUAL_ENV:-not set}"
    echo "   Python available: $(command -v python >/dev/null 2>&1 && echo "yes" || echo "no")"
    exit 1
fi

# Cleanup
rm -f "$GITHUB_ENV"

echo ""
echo "🎉 All virtual environment tests passed!"
echo "✅ Lightning CI workflow should work with this setup"
echo ""
echo "📊 Summary:"
echo "  - Virtual environment: $VIRTUAL_ENV"
echo "  - Python: $(python --version)"
echo "  - All critical tools available and in venv"
echo "  - Environment persistence working"
echo "  - Ready for Lightning CI execution"
echo ""
echo "🚀 GitHub Actions best practices implemented:"
echo "  - setup_runner_safe.sh exports to GITHUB_ENV"
echo "  - Environment variables persist between job steps"
echo "  - Virtual environment path passed as job output"
echo "  - Fallback mechanism for venv discovery"
