#!/bin/bash
# Setup script for ice-t GitHub Actions self-hosted runners

set -e

# Configuration
REPO_URL="https://github.com/DrJLabs/ice-t"
RUNNERS_DIR="/home/drj/ice-t-runners"
RUNNER_COUNT=6

# Labels for different runners (all get ice-t label plus specialized ones)
declare -A RUNNER_LABELS
RUNNER_LABELS[1]="ice-t,build,setup"
RUNNER_LABELS[2]="ice-t,test,smoke"
RUNNER_LABELS[3]="ice-t,test,unit"
RUNNER_LABELS[4]="ice-t,test,integration"
RUNNER_LABELS[5]="ice-t,quality,security"
RUNNER_LABELS[6]="ice-t,test,api"

# Function to configure a single runner
configure_runner() {
    local runner_num=$1
    local token=$2
    local runner_dir="${RUNNERS_DIR}/ice-t-runner-${runner_num}"
    local runner_name="ice-t-runner-${runner_num}"
    local labels="${RUNNER_LABELS[$runner_num]}"

    echo "🔧 Configuring runner ${runner_num} with labels: ${labels}"

    cd "$runner_dir"

    # Configure the runner
    ./config.sh \
        --url "$REPO_URL" \
        --token "$token" \
        --name "$runner_name" \
        --labels "$labels" \
        --work "_work" \
        --replace \
        --unattended \
        --runasservice

    echo "✅ Runner ${runner_num} configured successfully"
}

# Function to install runner as service
install_service() {
    local runner_num=$1
    local runner_dir="${RUNNERS_DIR}/ice-t-runner-${runner_num}"

    echo "🚀 Installing runner ${runner_num} as service..."

    cd "$runner_dir"
    sudo ./svc.sh install
    sudo ./svc.sh start

    echo "✅ Runner ${runner_num} service installed and started"
}

# Function to copy runner files to other directories
setup_runner_files() {
    echo "📦 Setting up runner files for all runners..."

    # Copy the extracted runner files to other directories
    for i in {2..6}; do
        local target_dir="${RUNNERS_DIR}/ice-t-runner-${i}"
        echo "Copying runner files to ice-t-runner-${i}..."

        # Copy all files except the tar.gz
        cd "${RUNNERS_DIR}/ice-t-runner-1"
        cp -r bin externals config.sh env.sh run-helper.cmd.template run-helper.sh.template run.sh safe_sleep.sh "$target_dir/"
    done

    echo "✅ Runner files copied to all directories"
}

# Main execution
main() {
    echo "🚀 Setting up ice-t GitHub Actions runners..."
    echo "Repository: $REPO_URL"
    echo "Runners to create: $RUNNER_COUNT"
    echo ""

    # Setup runner files in all directories
    setup_runner_files

    echo ""
    echo "📋 Runner configuration:"
    for i in {1..6}; do
        echo "   Runner $i: ${RUNNER_LABELS[$i]}"
    done

    echo ""
    echo "📝 To configure runners, get tokens from:"
    echo "   https://github.com/DrJLabs/ice-t/settings/actions/runners/new"
    echo ""
    echo "Then run: ./setup_ice_t_runners.sh manual-config"
}

# Manual configuration mode
manual_config() {
    echo "🔧 Manual configuration mode"
    echo "Please provide registration tokens for each runner:"
    echo ""

    declare -A TOKENS

    for i in {1..6}; do
        echo "Runner $i (labels: ${RUNNER_LABELS[$i]}):"
        read -p "Enter token for runner $i: " TOKENS[$i]
        echo ""
    done

    echo "🚀 Configuring all runners..."
    for i in {1..6}; do
        configure_runner $i "${TOKENS[$i]}"
    done

    echo ""
    echo "🔧 Installing services..."
    for i in {1..6}; do
        install_service $i
    done

    echo ""
    echo "✅ All ice-t runners configured and started!"
    echo "Check status with: sudo systemctl status actions.runner.*"
}

# Script execution
if [ "$1" = "manual-config" ]; then
    manual_config
else
    main
fi
