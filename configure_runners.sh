#!/bin/bash
# Configure ice-t runners with tokens

set -e

REPO_URL="https://github.com/DrJLabs/ice-t"

# Runner labels
declare -A RUNNER_LABELS
RUNNER_LABELS[1]="ice-t,linux,build,setup"
RUNNER_LABELS[2]="ice-t,linux,test,smoke"
RUNNER_LABELS[3]="ice-t,linux,test,unit"
RUNNER_LABELS[4]="ice-t,linux,test,integration"
RUNNER_LABELS[5]="ice-t,linux,quality,security"
RUNNER_LABELS[6]="ice-t,linux,test,api"

echo "🚀 ice-t GitHub Actions Runners Configuration"
echo "=============================================="
echo ""
echo "Repository: $REPO_URL"
echo ""
echo "📋 Runners to configure:"
for i in {1..6}; do
    echo "   Runner $i: ice-t-runner-$i (${RUNNER_LABELS[$i]})"
done
echo ""
echo "📝 Instructions:"
echo "1. Go to: https://github.com/DrJLabs/ice-t/settings/actions/runners/new"
echo "2. For each runner, click 'New self-hosted runner'"
echo "3. Select 'Linux' and copy the token"
echo "4. Paste each token below when prompted"
echo ""

# Collect tokens
declare -A TOKENS
for i in {1..6}; do
    echo "Runner $i (${RUNNER_LABELS[$i]}):"
    read -p "Enter registration token: " TOKENS[$i]
    echo ""
done

echo "🔧 Configuring all runners..."
echo ""

# Configure each runner
for i in {1..6}; do
    echo "Configuring runner $i..."
    cd "ice-t-runner-$i"

    ./config.sh \
        --url "$REPO_URL" \
        --token "${TOKENS[$i]}" \
        --name "ice-t-runner-$i" \
        --labels "${RUNNER_LABELS[$i]}" \
        --work "_work" \
        --replace \
        --unattended \
        --runasservice

    echo "✅ Runner $i configured"
    cd ..
done

echo ""
echo "🚀 Installing and starting services..."

# Install services
for i in {1..6}; do
    echo "Installing service for runner $i..."
    cd "ice-t-runner-$i"
    sudo ./svc.sh install
    sudo ./svc.sh start
    cd ..
    echo "✅ Runner $i service started"
done

echo ""
echo "🎉 All ice-t runners are configured and running!"
echo ""
echo "Check status with:"
echo "   sudo systemctl status actions.runner.*"
echo ""
echo "View logs with:"
echo "   sudo journalctl -u actions.runner.* -f"

# Initialize repository dependencies for consistency
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/setup_dependencies.sh"
