#!/bin/bash
# Streamlined SPARC Workflow Commands for Codex-T

# Core SPARC workflow aliases
alias sparc-spec="python3 tools/sparc_spec_parser.py"
alias sparc-pseudo="python3 tools/sparc_pseudo_gen.py"
alias sparc-build="python3 tools/sparc_build.py"
alias sparc-finalize="python3 tools/sparc_finalize.py"

# Environment and validation
alias sparc-validate="python3 tools/validate_environment.py"
alias sparc-health="python3 tools/validate_environment.py --verbose"

# Streamlined testing aliases
alias sparc-test="python3 tools/streamlined_test_runner.py --unit"
alias sparc-test-all="python3 tools/streamlined_test_runner.py --all"
alias sparc-test-fast="python3 tools/streamlined_test_runner.py --unit --fast"
alias sparc-test-smoke="python3 tools/streamlined_test_runner.py --smoke"
alias sparc-test-integration="python3 tools/streamlined_test_runner.py --integration"
alias sparc-test-security="python3 tools/streamlined_test_runner.py --security"
alias sparc-test-health="python3 tools/streamlined_test_runner.py --health"

# Legacy pytest aliases (for compatibility)
alias sparc-test-unit="pytest -m unit --cov=src --tb=short"
alias sparc-test-ci="pytest -m 'not slow' --cov=src --tb=short -q"
alias sparc-test-coverage="pytest --cov=src --cov-report=html --cov-report=term-missing"

# Development utilities
alias sparc-format="ruff format . && ruff check . --fix"
alias sparc-types="mypy src/"
alias sparc-clean="find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true"

# Security and quality
alias sparc-security="python3 -m bandit -r src/ -f console"
alias sparc-safety="python3 -m safety check"

# Quality gates
alias sparc-quality="sparc-format && sparc-types && sparc-test-fast"
alias sparc-full-quality="sparc-format && sparc-types && sparc-test-all && sparc-security"

# CI/CD helpers
alias sparc-ci-test="sparc-test-all --fast"
alias sparc-ci-complete="sparc-quality && sparc-finalize"

# Quick health and status
alias sparc-status="sparc-test-health && git status --porcelain"
alias sparc-demo="python3 src/codex_t/core/offline_services.py"

# Development workflow shortcuts
alias sparc-quick="sparc-test-smoke && sparc-format"
alias sparc-ready="sparc-quality && sparc-security"

# ice-t specific test commands
export ICE_T_TEST_CMD="python3 scripts/adaptive_test_runner.py run --level fast"

echo "✅ Streamlined SPARC commands loaded for Codex-T:"
echo ""
echo "🧪 Essential Testing:"
echo "   sparc-test         - Run unit tests with coverage"
echo "   sparc-test-all     - Run complete test suite"
echo "   sparc-test-fast    - Quick unit tests only"
echo "   sparc-test-smoke   - Critical path smoke tests"
echo "   sparc-test-health  - Quick project health check"
echo ""
echo "🎯 Test Categories:"
echo "   sparc-test-unit         - Unit tests only (pytest)"
echo "   sparc-test-integration  - Integration tests"
echo "   sparc-test-security     - Security tests"
echo "   sparc-test-coverage     - Generate coverage report"
echo ""
echo "🔒 Quality & Security:"
echo "   sparc-format       - Format code (ruff format + ruff check)"
echo "   sparc-types        - Type check with mypy"
echo "   sparc-security     - Security scan (bandit)"
echo "   sparc-quality      - Quick quality check"
echo "   sparc-full-quality - Complete quality assessment"
echo ""
echo "🚀 Workflow Shortcuts:"
echo "   sparc-quick        - Smoke tests + formatting"
echo "   sparc-ready        - Full quality check + security"
echo "   sparc-ci-test      - CI-optimized test run"
echo "   sparc-status       - Health check + git status"
echo ""
echo "💡 Quick Start:"
echo "   sparc-test-health           # Check if everything is working"
echo "   sparc-quick                 # Fast development cycle"
echo "   sparc-ready                 # Pre-commit validation"
echo "   sparc-test-all              # Complete validation"
echo ""
echo "🎯 SPARC Workflow: sparc-spec → sparc-pseudo → sparc-build → sparc-test → sparc-finalize"
echo "⚡ Development: sparc-quick for rapid feedback, sparc-ready before commits"
