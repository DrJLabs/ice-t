#!/bin/bash
set -euo pipefail

# 🤖 Enable Auto-Merge Setup Script
# Configures repository settings for auto-merge functionality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Codex-T Auto-Merge Configuration${NC}"
echo "========================================"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Get repository information
REPO_INFO=$(gh repo view --json owner,name,mergeCommitAllowed,defaultBranchRef)
OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')
DEFAULT_BRANCH=$(echo "$REPO_INFO" | jq -r '.defaultBranchRef.name')

# Check auto-merge setting separately
AUTO_MERGE_INFO=$(gh api repos/$OWNER/$REPO_NAME --jq '.allow_auto_merge // false')
CURRENT_AUTO_MERGE="$AUTO_MERGE_INFO"

echo -e "${BLUE}📋 Repository Information:${NC}"
echo "  Owner: $OWNER"
echo "  Repository: $REPO_NAME"
echo "  Default Branch: $DEFAULT_BRANCH"
echo "  Current Auto-merge Setting: $CURRENT_AUTO_MERGE"
echo

# Function to enable auto-merge at repository level
enable_repository_auto_merge() {
    echo -e "${YELLOW}🔧 Enabling auto-merge at repository level...${NC}"

    if gh api repos/$OWNER/$REPO_NAME --method PATCH --field allow_auto_merge=true &> /dev/null; then
        echo -e "${GREEN}✅ Auto-merge enabled at repository level${NC}"
    else
        echo -e "${RED}❌ Failed to enable auto-merge at repository level${NC}"
        echo "You may need admin permissions or the feature may not be available"
        return 1
    fi
}

# Function to check branch protection
check_branch_protection() {
    local branch=$1
    echo -e "${YELLOW}🔍 Checking branch protection for '$branch'...${NC}"

    if PROTECTION=$(gh api repos/$OWNER/$REPO_NAME/branches/$branch/protection 2>/dev/null); then
        echo -e "${GREEN}✅ Branch protection is configured for '$branch'${NC}"

        # Check required status checks
        if echo "$PROTECTION" | jq -e '.required_status_checks.contexts[]' &> /dev/null; then
            echo "  📋 Required status checks:"
            echo "$PROTECTION" | jq -r '.required_status_checks.contexts[]' | sed 's/^/    - /'
        else
            echo -e "${YELLOW}  ⚠️ No required status checks configured${NC}"
        fi

        # Check review requirements
        if echo "$PROTECTION" | jq -e '.required_pull_request_reviews' &> /dev/null; then
            REVIEW_COUNT=$(echo "$PROTECTION" | jq -r '.required_pull_request_reviews.required_approving_review_count')
            echo "  👥 Required reviews: $REVIEW_COUNT"
        else
            echo "  👥 No review requirements"
        fi
    else
        echo -e "${YELLOW}  ⚠️ No branch protection configured for '$branch'${NC}"
        echo "  Consider setting up branch protection for security"
    fi
    echo
}

# Function to suggest branch protection setup
suggest_branch_protection() {
    local branch=$1
    echo -e "${BLUE}💡 Suggested branch protection for '$branch':${NC}"

    if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
        cat << EOF
  Required status checks:
    - 🚀 Code Quality (Local Cache)
    - 🚀 Type Safety (Local Cache)
    - 🚀 Security Analysis (Local Cache)
    - 🚀 Tests (unit, integration, smoke)
    - 🚀 Build (Local Cache)

  Required reviews: 1
  Dismiss stale reviews: true
  Require code owner reviews: true
EOF
    else
        cat << EOF
  Required status checks:
    - 🚀 Code Quality (Local Cache)
    - 🚀 Tests (unit, integration, smoke)

  Required reviews: 0 (optional)
  Dismiss stale reviews: true
EOF
    fi
    echo
}

# Function to test auto-merge workflow
test_auto_merge_workflow() {
    echo -e "${YELLOW}🧪 Testing auto-merge workflow syntax...${NC}"

    if [ -f ".github/workflows/auto-merge.yml" ]; then
        # Basic YAML syntax check
        if command -v python3 &> /dev/null; then
            if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/auto-merge.yml'))" 2>/dev/null; then
                echo -e "${GREEN}✅ Auto-merge workflow syntax is valid${NC}"
            else
                echo -e "${RED}❌ Auto-merge workflow has syntax errors${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}⚠️ Cannot validate YAML syntax (python3 not available)${NC}"
        fi
    else
        echo -e "${RED}❌ Auto-merge workflow not found at .github/workflows/auto-merge.yml${NC}"
        return 1
    fi
}

# Function to display usage instructions
show_usage_instructions() {
    echo -e "${BLUE}🎯 Usage Instructions:${NC}"
    echo
    echo "1. 📝 Manual Auto-merge (any PR):"
    echo "   gh pr edit <PR_NUMBER> --add-label 'auto-merge'"
    echo
    echo "2. 🤖 AI Agent Auto-merge:"
    echo "   git checkout -b cursor/your-feature"
    echo "   # ... make changes ..."
    echo "   gh pr create --title 'Your feature' --body 'Description'"
    echo
    echo "3. 📦 Dependabot Auto-merge:"
    echo "   # Dependabot PRs are automatically eligible"
    echo
    echo "4. 🔍 Monitor Auto-merge:"
    echo "   gh workflow list"
    echo "   gh run list --workflow='Auto-Merge Pull Requests'"
    echo
}

# Function to check GitHub Actions permissions
check_actions_permissions() {
    echo -e "${YELLOW}🔍 Checking GitHub Actions permissions...${NC}"

    # This setting cannot be checked via API, so we provide guidance
    echo -e "${BLUE}📋 Required GitHub Actions Permission:${NC}"
    echo "  GitHub Actions must be allowed to create and approve pull requests"
    echo
    echo -e "${YELLOW}⚠️ If auto-merge fails with permission errors:${NC}"
    echo "  1. Go to: https://github.com/$OWNER/$REPO_NAME/settings/actions"
    echo "  2. Under 'Workflow permissions'"
    echo "  3. Check: ☑️ 'Allow GitHub Actions to create and approve pull requests'"
    echo "  4. Click 'Save'"
    echo
    echo -e "${BLUE}💡 This is required for the auto-approval feature in our workflow${NC}"
    echo
}

# Main execution
main() {
    # Step 1: Enable auto-merge at repository level
    if [ "$CURRENT_AUTO_MERGE" = "true" ]; then
        echo -e "${GREEN}✅ Auto-merge is already enabled at repository level${NC}"
    else
        if ! enable_repository_auto_merge; then
            exit 1
        fi
    fi
    echo

    # Step 2: Check branch protection for main branches
    check_branch_protection "$DEFAULT_BRANCH"

    if [ "$DEFAULT_BRANCH" != "develop" ]; then
        check_branch_protection "develop" 2>/dev/null || echo -e "${YELLOW}⚠️ 'develop' branch does not exist${NC}"
        echo
    fi

    # Step 3: Test auto-merge workflow
    test_auto_merge_workflow
    echo

    # Step 4: Show usage instructions
    show_usage_instructions

    # Step 5: Check GitHub Actions permissions
    check_actions_permissions

    # Final summary
    echo -e "${GREEN}🎉 Auto-merge configuration complete!${NC}"
    echo
    echo -e "${BLUE}📚 For detailed information, see: docs/AUTO_MERGE_GUIDE.md${NC}"
    echo -e "${BLUE}🔧 To customize further, edit: .github/workflows/auto-merge.yml${NC}"
}

# Handle command line arguments
case "${1:-setup}" in
    "setup"|"")
        main
        ;;
    "check")
        echo -e "${BLUE}🔍 Checking current auto-merge configuration...${NC}"
        echo "Repository auto-merge: $CURRENT_AUTO_MERGE"
        check_branch_protection "$DEFAULT_BRANCH"
        test_auto_merge_workflow
        ;;
    "enable")
        enable_repository_auto_merge
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [setup|check|enable|help]"
        echo "  setup  - Full auto-merge configuration (default)"
        echo "  check  - Check current configuration"
        echo "  enable - Enable repository auto-merge setting only"
        echo "  help   - Show this help message"
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
