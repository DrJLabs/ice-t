#!/bin/bash
# Migration Script: Enhanced Quality Gate + Lightning CI → Turbo CI
# This script helps transition to the new unified Turbo CI workflow

set -euo pipefail

echo "🚀 Turbo CI Migration Script"
echo "============================"
echo ""

# Check current system status
echo "📊 System Status Check:"
echo "- Active runners: $(ps aux | grep 'Runner.Listener' | grep -v grep | wc -l)"
echo "- Available RAM: $(free -h | grep '^Mem:' | awk '{print $7}')"
echo "- CPU cores: $(nproc)"
echo ""

# Check existing workflows
echo "📋 Current Workflow Analysis:"
if [ -f ".github/workflows/enhanced-quality-gate-v2.yml" ]; then
    echo "✅ Enhanced Quality Gate V2 found"
    ENHANCED_TRIGGERS=$(grep -A 10 "^on:" .github/workflows/enhanced-quality-gate-v2.yml | grep -E "push|pull_request|schedule" | wc -l)
    echo "   - Automatic triggers: $ENHANCED_TRIGGERS"
else
    echo "❌ Enhanced Quality Gate V2 not found"
fi

if [ -f ".github/workflows/lightning-fast-ci.yml" ]; then
    echo "✅ Lightning Fast CI found"
    LIGHTNING_MANUAL=$(grep -A 5 "^on:" .github/workflows/lightning-fast-ci.yml | grep "workflow_dispatch" | wc -l)
    echo "   - Manual only: $LIGHTNING_MANUAL"
else
    echo "❌ Lightning Fast CI not found"
fi

if [ -f ".github/workflows/turbo-ci.yml" ]; then
    echo "✅ Turbo CI found"
    TURBO_TRIGGERS=$(grep -A 15 "^on:" .github/workflows/turbo-ci.yml | grep -E "push|pull_request|schedule|workflow_dispatch" | wc -l)
    echo "   - Total triggers: $TURBO_TRIGGERS"
else
    echo "❌ Turbo CI not found - please create it first"
    exit 1
fi

echo ""

# Performance comparison
echo "🏁 Performance Comparison:"
echo ""
echo "| Feature                    | Enhanced QG | Lightning CI | Turbo CI |"
echo "|----------------------------|-------------|--------------|----------|"
echo "| Automatic Triggers         | ✅ Yes      | ❌ No        | ✅ Yes   |"
echo "| Max Parallelism            | 9 runners   | 9 runners    | 10 runners|"
echo "| Performance Modes          | ❌ No       | ✅ Yes       | ✅ Yes   |"
echo "| Smart Test Strategy        | ❌ No       | ❌ No        | ✅ Yes   |"
echo "| Specialized Runners        | ✅ Yes      | ❌ No        | ✅ Yes   |"
echo "| Ultra-fast Caching         | ❌ No       | ✅ Yes       | ✅ Yes   |"
echo "| RAM Optimization (117GB)   | ❌ No       | ❌ No        | ✅ Yes   |"
echo "| CPU Optimization (16 core) | ❌ No       | ❌ No        | ✅ Yes   |"
echo ""

# Migration recommendations
echo "💡 Migration Recommendations:"
echo ""

# Check if we should migrate
SHOULD_MIGRATE=true

if [ "$ENHANCED_TRIGGERS" -gt 0 ] && [ "$LIGHTNING_MANUAL" -gt 0 ]; then
    echo "🎯 RECOMMENDED: Migrate to Turbo CI"
    echo "   Reasons:"
    echo "   - Combines automatic triggers from Enhanced QG"
    echo "   - Adds performance optimizations from Lightning CI"
    echo "   - Optimized for your 10-runner, 117GB RAM, 16-core system"
    echo "   - Smart performance scaling based on trigger type"
    echo ""
elif [ "$ENHANCED_TRIGGERS" -gt 0 ]; then
    echo "⚡ CONSIDER: Add Lightning performance to Enhanced QG"
    echo "   - Your Enhanced QG has good triggers"
    echo "   - But missing performance optimizations"
    echo ""
elif [ "$LIGHTNING_MANUAL" -gt 0 ]; then
    echo "🔄 CONSIDER: Add automatic triggers to Lightning CI"
    echo "   - Your Lightning CI has good performance"
    echo "   - But missing automatic triggers"
    echo ""
else
    echo "❓ UNCLEAR: Review your current setup"
    SHOULD_MIGRATE=false
fi

# Performance mode recommendations
echo "🎛️ Performance Mode Recommendations:"
echo ""
echo "For your system (10 runners, 117GB RAM, 16 cores):"
echo ""
echo "📈 **Maximum Mode** (10 runners):"
echo "   - Use for: main branch pushes, releases"
echo "   - Timeout: 5 minutes"
echo "   - Best for: comprehensive validation"
echo ""
echo "⚡ **Turbo Mode** (8 runners) - RECOMMENDED DEFAULT:"
echo "   - Use for: pull requests, feature branches"
echo "   - Timeout: 4 minutes"
echo "   - Best for: fast feedback"
echo ""
echo "⚖️ **Balanced Mode** (6 runners):"
echo "   - Use for: scheduled runs, conservative testing"
echo "   - Timeout: 6 minutes"
echo "   - Best for: resource conservation"
echo ""

# Test strategy recommendations
echo "🧪 Test Strategy Recommendations:"
echo ""
echo "🧠 **Smart Strategy** - RECOMMENDED DEFAULT:"
echo "   - Small PRs (<5 files): unit tests only"
echo "   - Large PRs (≥5 files): full test suite"
echo "   - Skips integration tests for small changes"
echo ""
echo "🔄 **Full Strategy**:"
echo "   - Runs complete test suite"
echo "   - Use for main branch, releases"
echo ""
echo "🚀 **Quick Strategy**:"
echo "   - Smoke tests only"
echo "   - Use for rapid iteration"
echo ""

# Migration steps
if [ "$SHOULD_MIGRATE" = true ]; then
    echo "📋 Migration Steps:"
    echo ""
    echo "1. **Test Turbo CI**:"
    echo "   gh workflow run turbo-ci.yml --field performance_mode=turbo --field test_scope=smart"
    echo ""
    echo "2. **Compare Performance**:"
    echo "   - Monitor execution time"
    echo "   - Check resource utilization"
    echo "   - Verify all tests pass"
    echo ""
    echo "3. **Gradual Migration**:"
    echo "   - Keep existing workflows initially"
    echo "   - Run Turbo CI in parallel"
    echo "   - Compare results for 1-2 weeks"
    echo ""
    echo "4. **Full Migration** (when confident):"
    echo "   - Disable old workflows"
    echo "   - Update branch protection rules"
    echo "   - Update documentation"
    echo ""
fi

# Branch protection recommendations
echo "🛡️ Branch Protection Recommendations:"
echo ""
echo "For main branch, require these Turbo CI checks:"
echo "- turbo-setup"
echo "- turbo-quality"
echo "- turbo-tests"
echo "- turbo-build (optional)"
echo ""

# Cleanup recommendations
echo "🧹 Cleanup Recommendations:"
echo ""
echo "After successful migration:"
echo "1. Archive old workflow files:"
echo "   mkdir -p .github/workflows/archived"
echo "   mv .github/workflows/enhanced-quality-gate-v2.yml .github/workflows/archived/"
echo "   mv .github/workflows/lightning-fast-ci.yml .github/workflows/archived/"
echo ""
echo "2. Update documentation:"
echo "   - README.md"
echo "   - CONTRIBUTING.md"
echo "   - Any CI/CD documentation"
echo ""
echo "3. Clean up old caches:"
echo "   - GitHub Actions cache cleanup"
echo "   - Runner cache cleanup"
echo ""

# Performance monitoring
echo "📊 Performance Monitoring:"
echo ""
echo "Monitor these metrics after migration:"
echo "- Average workflow execution time"
echo "- Runner utilization"
echo "- Cache hit rates"
echo "- Resource usage (RAM/CPU)"
echo "- Developer feedback time"
echo ""

# Final recommendations
echo "🎯 Final Recommendations:"
echo ""
echo "✅ **DO:**"
echo "- Start with 'turbo' mode for most workflows"
echo "- Use 'smart' test strategy as default"
echo "- Monitor performance for 1-2 weeks"
echo "- Keep old workflows as backup initially"
echo ""
echo "❌ **DON'T:**"
echo "- Use 'maximum' mode for every trigger"
echo "- Delete old workflows immediately"
echo "- Skip performance monitoring"
echo "- Forget to update branch protection"
echo ""

echo "🚀 Ready to migrate to Turbo CI!"
echo "Run: gh workflow run turbo-ci.yml --field performance_mode=turbo"
