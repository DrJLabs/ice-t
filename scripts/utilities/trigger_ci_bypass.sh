#!/bin/bash
set -euo pipefail

# 🛠️ CI Bypass Trigger Script
# This script triggers the CI bypass workflow for a specific PR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "🛠️ CI Bypass Trigger Script"
    echo ""
    echo "Usage: $0 <pr_number> <reason>"
    echo ""
    echo "Arguments:"
    echo "  pr_number    The GitHub PR number to bypass CI checks for"
    echo "  reason       The reason for bypassing CI checks (quoted string)"
    echo ""
    echo "Examples:"
    echo "  $0 123 \"Emergency CI workflow fix\""
    echo "  $0 456 \"Update GitHub Actions to fix security issue\""
    echo ""
    echo "This will:"
    echo "  1. Trigger the CI bypass workflow via GitHub Actions API"
    echo "  2. Create successful status checks for all required CI jobs"
    echo "  3. Enable auto-merge if the PR meets other criteria"
    exit 1
}

log_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi

    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
        exit 1
    fi

    log_success "All dependencies are available"
}

validate_pr() {
    local pr_number="$1"

    log_info "Validating PR #$pr_number..."

    # Check if PR exists and get details
    if ! PR_DATA=$(gh pr view "$pr_number" --json number,state,title,author,headRefName 2>/dev/null); then
        log_error "PR #$pr_number not found or inaccessible"
        exit 1
    fi

    local pr_state=$(echo "$PR_DATA" | jq -r '.state')
    local pr_title=$(echo "$PR_DATA" | jq -r '.title')
    local pr_author=$(echo "$PR_DATA" | jq -r '.author.login')
    local pr_branch=$(echo "$PR_DATA" | jq -r '.headRefName')

    if [ "$pr_state" != "OPEN" ]; then
        log_error "PR #$pr_number is not open (current state: $pr_state)"
        exit 1
    fi

    log_success "PR #$pr_number is valid"
    log_info "  Title: $pr_title"
    log_info "  Author: $pr_author"
    log_info "  Branch: $pr_branch"

    return 0
}

trigger_bypass_workflow() {
    local pr_number="$1"
    local reason="$2"

    log_info "Triggering CI bypass workflow..."

    # Get repository information
    REPO_INFO=$(gh repo view --json owner,name)
    REPO_OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
    REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')

    log_info "Repository: $REPO_OWNER/$REPO_NAME"

    # Trigger the workflow dispatch event
    if gh workflow run ci-workflow-bypass.yml \
        --field pr_number="$pr_number" \
        --field bypass_reason="$reason"; then
        log_success "CI bypass workflow triggered successfully"
    else
        log_error "Failed to trigger CI bypass workflow"
        exit 1
    fi

    # Wait a moment for the workflow to start
    sleep 3

    # Show workflow runs
    log_info "Recent workflow runs:"
    gh run list --workflow=ci-workflow-bypass.yml --limit=3
}

confirm_action() {
    local pr_number="$1"
    local reason="$2"

    echo ""
    log_warning "⚠️ CONFIRMATION REQUIRED ⚠️"
    echo ""
    echo "You are about to bypass CI checks for:"
    echo "  PR Number: #$pr_number"
    echo "  Reason: $reason"
    echo ""
    echo "This will:"
    echo "  ✅ Mark all required CI checks as successful"
    echo "  🤖 Enable auto-merge if other criteria are met"
    echo "  💬 Add a comment to the PR explaining the bypass"
    echo ""

    read -p "Are you sure you want to proceed? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled by user"
        exit 0
    fi
}

show_post_trigger_info() {
    local pr_number="$1"

    echo ""
    log_success "🎉 CI bypass triggered successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. 📋 Check the workflow run: gh run list --workflow=ci-workflow-bypass.yml"
    echo "  2. 👀 Monitor PR status: gh pr view $pr_number"
    echo "  3. 🔍 View workflow logs: gh run view --log"
    echo ""
    echo "The bypass workflow will:"
    echo "  ✅ Create successful status checks for all required CI jobs"
    echo "  💬 Comment on the PR with bypass details"
    echo "  🤖 Enable auto-merge if the PR meets eligibility criteria"
    echo ""
    log_info "You can monitor progress at: https://github.com/$(gh repo view --json owner,name -q '.owner.login + \"/\" + .name')/actions"
}

main() {
    cd "$REPO_ROOT"

    # Parse arguments
    if [ $# -ne 2 ]; then
        usage
    fi

    local pr_number="$1"
    local reason="$2"

    # Validate PR number is numeric
    if ! [[ "$pr_number" =~ ^[0-9]+$ ]]; then
        log_error "PR number must be a positive integer"
        exit 1
    fi

    # Validate reason is not empty
    if [ -z "$reason" ]; then
        log_error "Reason cannot be empty"
        exit 1
    fi

    echo "🛠️ CI Bypass Trigger Script"
    echo "=========================="

    # Run checks and trigger
    check_dependencies
    validate_pr "$pr_number"
    confirm_action "$pr_number" "$reason"
    trigger_bypass_workflow "$pr_number" "$reason"
    show_post_trigger_info "$pr_number"
}

# Run main function with all arguments
main "$@"
