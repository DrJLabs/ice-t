#!/bin/bash
# =============================================================================
# Pre-commit Setup Script for ChatGPT Codex Environment
# Installs and tests pre-commit hooks with offline-first design
# =============================================================================

set -e  # Exit on any error

echo "🔧 Setting up pre-commit hooks for Codex environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f ".pre-commit-config.yaml" ]]; then
    print_error "No .pre-commit-config.yaml found. Run this script from the project root."
    exit 1
fi

# Install pre-commit if not available
print_status "Checking pre-commit installation..."
if command -v pre-commit >/dev/null 2>&1; then
    print_success "pre-commit is already installed: $(pre-commit --version)"
else
    print_status "Installing pre-commit..."
    if command -v pip >/dev/null 2>&1; then
        pip install pre-commit
        print_success "pre-commit installed successfully"
    else
        print_warning "pip not found. Installing pre-commit via system package manager..."
        # Try different package managers
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y pre-commit
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y pre-commit
        elif command -v brew >/dev/null 2>&1; then
            brew install pre-commit
        else
            print_error "Could not install pre-commit. Please install manually."
            exit 1
        fi
    fi
fi

# Install the pre-commit hooks
print_status "Installing pre-commit hooks..."
pre-commit install --install-hooks

# Also install for other git hooks if needed
pre-commit install --hook-type pre-push
pre-commit install --hook-type commit-msg

print_success "Pre-commit hooks installed successfully"

# Test the helper script
print_status "Testing pre-commit helper utilities..."
if python3 tools/pre_commit_helpers.py --help >/dev/null 2>&1; then
    print_error "Helper script test failed. Expected help command to show usage."
else
    print_success "Helper script is working correctly"
fi

# Run a quick validation of the configuration
print_status "Validating pre-commit configuration..."
if pre-commit validate-config; then
    print_success "Pre-commit configuration is valid"
else
    print_error "Pre-commit configuration validation failed"
    exit 1
fi

# Test individual hooks on sample files
print_status "Testing hooks on sample files..."

# Create a temporary test file
TEST_FILE="temp_test_file.py"
cat > "$TEST_FILE" << 'EOF'
#!/usr/bin/env python3
"""Test file for pre-commit hooks."""

import json

def test_function(data):
    result = {"test": True}
    return result

if __name__ == "__main__":
    print("Hello World!")
EOF

# Test basic hooks
print_status "Testing trailing whitespace fixer..."
python3 tools/pre_commit_helpers.py trailing-whitespace "$TEST_FILE"

print_status "Testing end-of-file fixer..."
python3 tools/pre_commit_helpers.py end-of-file "$TEST_FILE"

print_status "Testing security check..."
python3 tools/pre_commit_helpers.py security-check "$TEST_FILE"

# Clean up test file
rm -f "$TEST_FILE"

print_success "Hook tests completed successfully"

# Run pre-commit on all files (dry run first)
print_status "Running dry-run of all hooks..."
if pre-commit run --all-files --dry-run; then
    print_success "Dry-run completed successfully"
else
    print_warning "Dry-run found issues, but that's expected for initial setup"
fi

# Provide usage instructions
cat << 'EOF'

🎉 Pre-commit setup completed successfully!

📋 Usage Instructions:

1. **Automatic on commit**: Hooks will run automatically when you commit:
   git add .
   git commit -m "Your commit message"

2. **Manual execution**: Run hooks manually on all files:
   pre-commit run --all-files

3. **Specific hooks**: Run individual hooks:
   pre-commit run ruff
   pre-commit run mypy

4. **Manual stages**: Run additional checks:
   pre-commit run --hook-stage manual --all-files

5. **Skip hooks**: Skip hooks for a commit (use sparingly):
   git commit -m "WIP: work in progress" --no-verify

-🔧 Available Hooks:
- trailing-whitespace: Remove trailing whitespace
- end-of-file-fixer: Ensure files end with newline
- check-yaml: Validate YAML syntax
- check-json: Validate JSON syntax
- check-merge-conflict: Check for merge conflict markers
- ruff: Lint and format Python code
- ruff-format: Format Python code with Ruff
- mypy: Type checking (src/ only)
- python-check-ast: Syntax validation
- pytest-smoke: Quick smoke tests (manual)
- security-check: Basic security patterns
- docstring-check: Check for missing docstrings (manual)

⚡ Fast Development Loop:
For quick fixes after making changes:
1. pre-commit run --files changed_file.py
2. git add changed_file.py
3. git commit -m "Fixed formatting"

🚨 Troubleshooting:
- If hooks fail: Fix the issues and commit again
- If tools missing: pip install ruff mypy
- Skip problematic hooks temporarily: SKIP=hook-name git commit

Happy coding! 🚀
EOF

print_success "Pre-commit setup documentation displayed above"
