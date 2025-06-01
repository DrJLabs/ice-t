#!/bin/bash
# Repository Cleanup Script - Clean Slate
# Deletes all branches except main and develop
# Created: May 31, 2025

set -euo pipefail

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

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to confirm destructive operation
confirm_cleanup() {
    echo -e "${RED}⚠️  WARNING: This will delete ALL branches except main and develop!${NC}"
    echo -e "${RED}⚠️  This operation is IRREVERSIBLE!${NC}"
    echo ""
    echo "Branches that will be KEPT:"
    echo "  - main"
    echo "  - develop"
    echo ""
    echo "All other local and remote branches will be DELETED."
    echo ""
    read -p "Are you absolutely sure you want to proceed? (type 'YES' to confirm): " confirm

    if [ "$confirm" != "YES" ]; then
        print_error "Operation cancelled by user"
        exit 1
    fi
}

# Function to check if we're on a protected branch
ensure_safe_branch() {
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "develop" ]; then
        print_status "Switching to main branch for safety..."
        git checkout main
    fi
}

# Function to delete local branches
cleanup_local_branches() {
    print_status "Cleaning up local branches..."

    # Get all local branches except main and develop
    branches_to_delete=$(git branch | grep -v "main\|develop" | grep -v "^\*" | sed 's/^[ \t]*//')

    if [ -z "$branches_to_delete" ]; then
        print_success "No local branches to delete"
        return
    fi

    echo "Local branches to delete:"
    echo "$branches_to_delete" | sed 's/^/  - /'
    echo ""

    # Delete each branch
    while IFS= read -r branch; do
        if [ -n "$branch" ]; then
            print_status "Deleting local branch: $branch"
            git branch -D "$branch" || print_warning "Failed to delete branch: $branch"
        fi
    done <<< "$branches_to_delete"

    print_success "Local branch cleanup completed"
}

# Function to delete remote branches
cleanup_remote_branches() {
    print_status "Cleaning up remote branches..."

    # Fetch latest remote state
    git fetch --all --prune

    # Get all remote branches except main and develop
    remote_branches_to_delete=$(git branch -r | grep -v "main\|develop" | grep -v "HEAD ->" | sed 's/^[ \t]*origin\///')

    if [ -z "$remote_branches_to_delete" ]; then
        print_success "No remote branches to delete"
        return
    fi

    echo "Remote branches to delete:"
    echo "$remote_branches_to_delete" | sed 's/^/  - /'
    echo ""

    # Delete each remote branch
    while IFS= read -r branch; do
        if [ -n "$branch" ]; then
            print_status "Deleting remote branch: $branch"
            git push origin --delete "$branch" || print_warning "Failed to delete remote branch: $branch"
        fi
    done <<< "$remote_branches_to_delete"

    print_success "Remote branch cleanup completed"
}

# Function to provide PR cleanup guidance
provide_pr_guidance() {
    print_status "Checking for open pull requests..."
    echo ""
    echo -e "${YELLOW}📋 PULL REQUEST CLEANUP GUIDANCE${NC}"
    echo "================================="
    echo ""
    echo "To close all open pull requests, you have several options:"
    echo ""
    echo "1. 🌐 GitHub Web Interface:"
    echo "   - Go to: https://github.com/DrJLabs/codex-t/pulls"
    echo "   - Close each PR individually"
    echo ""
    echo "2. 🔧 GitHub CLI (if installed):"
    echo "   gh pr list --state open"
    echo "   gh pr close [PR_NUMBER] --comment 'Repository cleanup - closing all PRs'"
    echo ""
    echo "3. 🛠️  GitHub API (using curl):"
    echo "   # List open PRs:"
    echo "   curl -H \"Authorization: token YOUR_TOKEN\" https://api.github.com/repos/DrJLabs/codex-t/pulls"
    echo ""
    echo "   # Close a PR:"
    echo "   curl -X PATCH -H \"Authorization: token YOUR_TOKEN\" \\"
    echo "        https://api.github.com/repos/DrJLabs/codex-t/pulls/[PR_NUMBER] \\"
    echo "        -d '{\"state\":\"closed\"}'"
    echo ""
    echo "4. 📝 Bulk close script (if you have many PRs):"
    echo "   See the generated script: scripts/utilities/close_all_prs.sh"
    echo ""
}

# Function to create a PR closing script
create_pr_closing_script() {
    cat > scripts/utilities/close_all_prs.sh << 'EOF'
#!/bin/bash
# Close All Pull Requests Script
# Created: May 31, 2025

set -euo pipefail

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "🔍 Finding all open pull requests..."
open_prs=$(gh pr list --state open --json number,title --jq '.[] | "\(.number) \(.title)"')

if [ -z "$open_prs" ]; then
    echo "✅ No open pull requests found"
    exit 0
fi

echo "Found open pull requests:"
echo "$open_prs" | sed 's/^/  - PR #/'

echo ""
read -p "Close all these pull requests? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Operation cancelled"
    exit 0
fi

# Close each PR
while IFS= read -r line; do
    if [ -n "$line" ]; then
        pr_number=$(echo "$line" | cut -d' ' -f1)
        echo "Closing PR #$pr_number..."
        gh pr close "$pr_number" --comment "Repository cleanup - closing all PRs for clean slate"
    fi
done <<< "$open_prs"

echo "✅ All pull requests have been closed"
EOF

    chmod +x scripts/utilities/close_all_prs.sh
    print_success "Created PR closing script: scripts/utilities/close_all_prs.sh"
}

# Function to show final status
show_final_status() {
    echo ""
    echo -e "${GREEN}🎉 REPOSITORY CLEANUP COMPLETED${NC}"
    echo "=================================="
    echo ""
    echo "✅ Remaining branches:"
    git branch -a | grep -E "(main|develop)" | sed 's/^/  /'
    echo ""
    echo "📊 Summary:"
    echo "  - All local branches deleted (except main/develop)"
    echo "  - All remote branches deleted (except main/develop)"
    echo "  - Pull request cleanup guidance provided"
    echo "  - PR closing script created"
    echo ""
    echo "🔗 Next steps:"
    echo "  1. Close pull requests using the guidance above"
    echo "  2. Run: scripts/utilities/close_all_prs.sh (if you have GitHub CLI)"
    echo "  3. Verify cleanup at: https://github.com/DrJLabs/codex-t"
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}🧹 REPOSITORY CLEANUP SCRIPT${NC}"
    echo "============================="
    echo ""

    # Confirm the operation
    confirm_cleanup

    # Ensure we're on a safe branch
    ensure_safe_branch

    # Create the PR closing script
    create_pr_closing_script

    # Clean up local branches
    cleanup_local_branches

    # Clean up remote branches
    cleanup_remote_branches

    # Provide PR guidance
    provide_pr_guidance

    # Show final status
    show_final_status
}

# Run the script
main "$@"
