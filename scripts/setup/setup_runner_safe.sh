#!/usr/bin/env bash
# Optimized Safe Runner Environment Setup Script
# This script provides high-performance dependency management with caching,
# persistence, and smart updates for CI runners

set -euo pipefail

# Determine the actual project directory based on execution context
if [ -n "${GITHUB_WORKSPACE:-}" ]; then
    PROJECT_DIR="$GITHUB_WORKSPACE"
elif [ -n "${RUNNER_WORKSPACE:-}" ]; then
    PROJECT_DIR="$RUNNER_WORKSPACE/$(basename "${GITHUB_REPOSITORY:-codex-t}")"
else
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Ensure we're in the right directory
cd "$PROJECT_DIR"

# Use runner-specific virtual environment to avoid collisions
RUNNER_ID="${RUNNER_NAME:-$(hostname)}"
VENV_DIR="$PROJECT_DIR/.runner-venv-${RUNNER_ID}"
CACHE_DIR="$PROJECT_DIR/.runner-cache-${RUNNER_ID}"
LOCK_FILE="$CACHE_DIR/deps.lock"
REQUIREMENTS_HASH_FILE="$CACHE_DIR/requirements.hash"

# Create cache directory
mkdir -p "$CACHE_DIR"

echo "🚀 Setting up optimized runner environment..."
echo "📍 Project directory: $PROJECT_DIR"
echo "🤖 Runner ID: $RUNNER_ID"
echo "📦 Virtual environment: $VENV_DIR"

# Function to calculate requirements hash for cache invalidation
calculate_requirements_hash() {
    local hash=""
    [ -f "$PROJECT_DIR/requirements.txt" ] && hash+=$(sha256sum "$PROJECT_DIR/requirements.txt" | cut -d' ' -f1)
    [ -f "$PROJECT_DIR/dev-requirements.txt" ] && hash+=$(sha256sum "$PROJECT_DIR/dev-requirements.txt" | cut -d' ' -f1)
    # Include Python version in hash for cache invalidation
    # Use system python3 to avoid circular dependencies
    hash+=$(/usr/bin/python3 --version 2>/dev/null | sha256sum | cut -d' ' -f1 || echo "unknown")
    echo "$hash" | sha256sum | cut -d' ' -f1
}

# Function to check if dependencies are up to date
deps_are_current() {
    [ -f "$REQUIREMENTS_HASH_FILE" ] && [ -d "$VENV_DIR" ] && \
    [ "$(cat "$REQUIREMENTS_HASH_FILE" 2>/dev/null)" = "$(calculate_requirements_hash)" ]
}

# Function to create optimized pip configuration
setup_pip_optimization() {
    local pip_conf_dir="$VENV_DIR/pip"
    mkdir -p "$pip_conf_dir"
    cat > "$pip_conf_dir/pip.conf" << EOF
[global]
cache-dir = $CACHE_DIR/pip
trusted-host = pypi.org
               files.pythonhosted.org
               pypi.python.org
disable-pip-version-check = true
no-color = true
timeout = 60

[install]
upgrade-strategy = only-if-needed
compile = false
EOF
}

# Function to safely activate virtual environment
activate_venv() {
    # Deactivate any existing virtual environment first
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        echo "⚠️ Deactivating existing virtual environment: $VIRTUAL_ENV"
        if command -v deactivate >/dev/null 2>&1; then
            deactivate 2>/dev/null || true
        fi
        unset VIRTUAL_ENV
    fi

    # Clean PATH from any existing virtual environment paths
    if [ -n "${_OLD_VIRTUAL_PATH:-}" ]; then
        export PATH="$_OLD_VIRTUAL_PATH"
        unset _OLD_VIRTUAL_PATH
    fi

    # Activate our virtual environment
    export VIRTUAL_ENV="$VENV_DIR"
    export _OLD_VIRTUAL_PATH="$PATH"
    export PATH="$VENV_DIR/bin:$PATH"

    # Verify activation worked
    if ! command -v python >/dev/null 2>&1; then
        echo "❌ Virtual environment activation failed - python command not available"
        echo "🔍 PATH: $PATH"
        echo "🔍 VIRTUAL_ENV: ${VIRTUAL_ENV:-not set}"
        echo "🔍 VENV_DIR: $VENV_DIR"
        echo "🔍 Contents of $VENV_DIR/bin:"
        ls -la "$VENV_DIR/bin/" 2>/dev/null || echo "Directory does not exist"
        return 1
    fi

    echo "✅ Virtual environment activated: $VENV_DIR"
    echo "🐍 Using Python: $(which python) ($(python --version))"
    return 0
}

# Fast path: Check if we can skip setup entirely
if deps_are_current; then
    echo "⚡ Dependencies are current, using cached environment (0.1s vs 4.4s)"

    if activate_venv; then
        # Quick verification of critical tools
        missing_tools=()
        for tool in python pip pytest black ruff mypy; do
            if ! command -v "$tool" >/dev/null 2>&1; then
                missing_tools+=("$tool")
            fi
        done

        if [ ${#missing_tools[@]} -eq 0 ]; then
            echo "✅ Using cached environment successfully"
            echo "📍 Virtual environment: $VENV_DIR"
            echo "🐍 Python: $(python --version)"
            echo "📦 Pip: $(pip --version)"

            # Export environment variables for subsequent steps in GitHub Actions
            if [ -n "${GITHUB_ENV:-}" ]; then
                echo "VIRTUAL_ENV=$VENV_DIR" >> "$GITHUB_ENV"
                echo "PATH=$VENV_DIR/bin:$PATH" >> "$GITHUB_ENV"
            fi

            # Also export for current shell
            export VIRTUAL_ENV="$VENV_DIR"
            export PATH="$VENV_DIR/bin:$PATH"

            echo "💾 Caching dependency state..."
            echo "🎉 Optimized runner environment setup complete!"
            echo "📍 Virtual environment: $VENV_DIR"
            echo "🐍 Python: $(python --version)"
            echo "📦 Pip: $(pip --version)"
            echo "💾 Cache directory: $CACHE_DIR"
            echo "✅ Virtual environment properly activated"

            # Don't exit if being sourced
            if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
                exit 0
            else
                return 0
            fi
        else
            echo "❌ Critical tools missing: ${missing_tools[*]}, rebuilding environment..."
        fi
    else
        echo "❌ Virtual environment activation failed, rebuilding environment..."
    fi
fi

echo "🔧 Building/updating dependencies..."

# Create or update virtual environment using system python3
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating virtual environment at $VENV_DIR"
    /usr/bin/python3 -m venv "$VENV_DIR" --clear
else
    echo "🔄 Updating existing virtual environment at $VENV_DIR"
    # Recreate to ensure clean state
    rm -rf "$VENV_DIR"
    /usr/bin/python3 -m venv "$VENV_DIR" --clear
fi

# Activate virtual environment
if ! activate_venv; then
    echo "❌ Failed to activate newly created virtual environment"
    exit 1
fi

# Setup optimized pip configuration
setup_pip_optimization

# Upgrade pip to latest version with optimization
echo "⬆️ Upgrading pip..."
python -m pip install --upgrade pip wheel setuptools --quiet --no-warn-script-location

# CRITICAL: Fix Python 3.12 distutils compatibility issue
# Reference: https://github.com/Uberi/speech_recognition/issues/732
echo "🔧 Ensuring Python 3.12 distutils compatibility..."
if ! python -c "import distutils" 2>/dev/null; then
    echo "⚠️ distutils not available, installing setuptools with force-reinstall for Python 3.12..."
    python -m pip install --upgrade --force-reinstall "setuptools>=68.0" --quiet --no-warn-script-location

    # Test distutils availability after setuptools reinstall
    if python -c "import distutils; print('✅ distutils now available via setuptools')" 2>/dev/null; then
        echo "✅ distutils compatibility confirmed"
    else
        echo "⚠️ distutils still not available, will initialize via setuptools.dist when needed"
    fi
else
    echo "✅ distutils already available"
fi

# Install dependencies with optimizations
install_with_retries() {
    local requirements_file="$1"
    local attempt=1
    local max_attempts=3

    while [ $attempt -le $max_attempts ]; do
        echo "📋 Installing $requirements_file (attempt $attempt/$max_attempts)..."
        if pip install -r "$requirements_file" \
            --quiet \
            --no-warn-script-location \
            --prefer-binary \
            --only-binary=:all: 2>/dev/null || \
           pip install -r "$requirements_file" \
            --quiet \
            --no-warn-script-location \
            --prefer-binary; then
            return 0
        fi

        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Failed to install $requirements_file after $max_attempts attempts"
            return 1
        fi

        echo "⚠️ Attempt $attempt failed, retrying..."
        attempt=$((attempt + 1))
        sleep 2
    done
}

# Install requirements with optimized approach
if [ -f "$PROJECT_DIR/requirements.txt" ] && [ -f "$PROJECT_DIR/dev-requirements.txt" ]; then
    install_with_retries "$PROJECT_DIR/requirements.txt"
    install_with_retries "$PROJECT_DIR/dev-requirements.txt"
else
    echo "⚠️ Lock files missing - installing editable package with dev extras"
    pip install -e .[dev] --quiet --no-warn-script-location
fi

# Install security tools with conflict resolution
echo "🔐 Installing security tools with conflict resolution..."
pip install bandit safety --quiet --no-warn-script-location || echo "Some security tools may not be available"

# Install semgrep separately to handle rich version conflicts
if ! command -v semgrep >/dev/null 2>&1; then
    echo "🔍 Installing semgrep..."
    pip install semgrep --quiet --no-warn-script-location --no-deps || echo "Semgrep installation failed"
fi

# Verify critical tools are available
echo "🔍 Verifying critical tools..."
critical_tools=(python pip pytest black ruff mypy)
for tool in "${critical_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: $(command -v "$tool")"
    else
        echo "  ❌ $tool: not found"
        exit 1
    fi
done

# Verify additional tools with warnings instead of failures
echo "🔍 Verifying additional tools..."
additional_tools=(bandit safety semgrep pre-commit coverage)
for tool in "${additional_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: $(command -v "$tool")"
    else
        echo "  ⚠️ $tool: not found (may be optional)"
    fi
done

# Cache the current state
echo "💾 Caching dependency state..."
calculate_requirements_hash > "$REQUIREMENTS_HASH_FILE"

# Cleanup pip cache if it gets too large (>500MB)
pip_cache_size=$(du -sm "$CACHE_DIR/pip" 2>/dev/null | cut -f1 || echo "0")
if [ "$pip_cache_size" -gt 500 ]; then
    echo "🧹 Cleaning large pip cache ($pip_cache_size MB > 500MB)..."
    pip cache purge --quiet
fi

echo "🎉 Optimized runner environment setup complete!"
echo "📍 Virtual environment: $VENV_DIR"
echo "🐍 Python: $(python --version)"
echo "📦 Pip: $(pip --version)"
echo "💾 Cache directory: $CACHE_DIR"

# Export environment variables for subsequent steps in GitHub Actions
if [ -n "${GITHUB_ENV:-}" ]; then
    echo "VIRTUAL_ENV=$VENV_DIR" >> "$GITHUB_ENV"
    echo "PATH=$VENV_DIR/bin:$PATH" >> "$GITHUB_ENV"
fi

# Also export for current shell
export VIRTUAL_ENV="$VENV_DIR"
export PATH="$VENV_DIR/bin:$PATH"

# Ensure repository dependencies are installed for local usage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/setup_dependencies.sh"

# Final verification
if command -v python >/dev/null 2>&1 && [ -n "$VIRTUAL_ENV" ]; then
    echo "✅ Virtual environment properly activated"

    # Don't exit if being sourced
    if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
        exit 0
    else
        return 0
    fi
else
    echo "❌ Virtual environment not properly activated"

    # Don't exit if being sourced
    if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
        exit 1
    else
        return 1
    fi
fi
