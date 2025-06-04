#!/bin/bash

# Codacy MCP Setup Verification Script
# This script checks if your system is ready for Codacy MCP integration

set -e

echo "🔍 Verifying Codacy MCP Setup Prerequisites..."
echo "================================================"

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js is installed: $NODE_VERSION"
else
    echo "❌ Node.js is not installed"
    echo "   Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm is installed: $NPM_VERSION"
else
    echo "❌ npm is not installed"
    echo "   npm should come with Node.js installation"
    exit 1
fi

# Check npx
if command -v npx &> /dev/null; then
    NPX_VERSION=$(npx --version)
    echo "✅ npx is installed: $NPX_VERSION"
else
    echo "❌ npx is not installed"
    echo "   npx should come with npm 5.2.0 or higher"
    exit 1
fi

# Check git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "✅ Git is installed: $GIT_VERSION"
else
    echo "❌ Git is not installed"
    echo "   Please install Git"
    exit 1
fi

# Check if we're in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "✅ Current directory is a Git repository"

    # Get repository info
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "No remote origin found")
    echo "   Repository: $REPO_URL"

    if [[ "$REPO_URL" == *"github.com"* ]]; then
        PROVIDER="gh"
        ORG=$(echo "$REPO_URL" | sed -n 's/.*github\.com[:/]\([^/]*\).*/\1/p')
        REPO=$(echo "$REPO_URL" | sed -n 's/.*github\.com[:/][^/]*\/\([^/]*\)\.git.*/\1/p')
        echo "   Provider: GitHub"
        echo "   Organization: $ORG"
        echo "   Repository: $REPO"
    elif [[ "$REPO_URL" == *"gitlab.com"* ]]; then
        PROVIDER="gl"
        echo "   Provider: GitLab"
    elif [[ "$REPO_URL" == *"bitbucket.org"* ]]; then
        PROVIDER="bb"
        echo "   Provider: Bitbucket"
    else
        echo "   Provider: Unknown or unsupported"
    fi
else
    echo "⚠️  Not in a Git repository"
    echo "   Codacy works best with Git repositories"
fi

# Check if .cursor directory exists
if [ -d ".cursor" ]; then
    echo "✅ .cursor directory exists"

    # Check if mcp.json exists
    if [ -f ".cursor/mcp.json" ]; then
        echo "✅ MCP configuration file exists: .cursor/mcp.json"

        # Validate JSON
        if cat .cursor/mcp.json | python3 -m json.tool > /dev/null 2>&1; then
            echo "✅ MCP configuration file is valid JSON"
        else
            echo "❌ MCP configuration file has invalid JSON syntax"
        fi
    else
        echo "⚠️  MCP configuration file not found: .cursor/mcp.json"
        echo "   This will be created when you configure MCP in Cursor"
    fi
else
    echo "⚠️  .cursor directory not found"
    echo "   This will be created when you configure MCP in Cursor"
fi

# Test npx with a simple command
echo ""
echo "🧪 Testing npx functionality..."
if npx --version &> /dev/null; then
    echo "✅ npx is working correctly"
else
    echo "❌ npx is not working correctly"
    exit 1
fi

# Check internet connectivity to npm registry
echo ""
echo "🌐 Testing connectivity to npm registry..."
if curl -s --connect-timeout 5 https://registry.npmjs.org/ > /dev/null; then
    echo "✅ Can connect to npm registry"
else
    echo "❌ Cannot connect to npm registry"
    echo "   Check your internet connection or corporate firewall"
fi

# Check if Codacy MCP package is available
echo ""
echo "📦 Checking Codacy MCP package availability..."
if npx --yes @codacy/codacy-mcp --help &> /dev/null; then
    echo "✅ Codacy MCP package is accessible"
else
    echo "⚠️  Could not verify Codacy MCP package"
    echo "   This might work when properly configured with API token"
fi

echo ""
echo "================================================"
echo "🎉 Prerequisites verification complete!"
echo ""
echo "Next steps:"
echo "1. Get your Codacy API token from https://app.codacy.com"
echo "2. Configure MCP in Cursor settings"
echo "3. Add your API token to the configuration"
echo "4. Restart Cursor"
echo ""
echo "📖 For detailed instructions, see: docs/CODACY_CURSOR_SETUP.md"
