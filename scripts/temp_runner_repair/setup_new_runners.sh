#!/bin/bash

# Script to set up runners 07, 08, 09 with optimized labels
# Run this after getting the tokens from GitHub

echo "Setting up runners 07, 08, 09..."

# Function to setup a runner
setup_runner() {
    local runner_num=$1
    local token=$2
    local labels=$3

    echo "Setting up runner $runner_num with labels: $labels"

    # Create directory
    mkdir -p actions-runner-$runner_num
    cd actions-runner-$runner_num

    # Download runner (if not already exists)
    if [ ! -f config.sh ]; then
        curl -o actions-runner-linux-x64-2.320.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-x64-2.320.0.tar.gz
        tar xzf ./actions-runner-linux-x64-2.320.0.tar.gz
    fi

    # Configure with labels
    ./config.sh --url https://github.com/DrJLabs/codex-t --token $token --labels $labels --name actions-runner-$runner_num --work _work --replace

    # Install as service
    sudo ./svc.sh install drj
    sudo ./svc.sh start

    cd ..
}

# You'll need to replace these tokens with real ones from GitHub
echo "Please replace the TOKEN_XX placeholders with actual tokens from GitHub"
echo ""
echo "setup_runner 07 TOKEN_07 \"self-hosted,linux,fast-setup,pre-commit-ready\""
echo "setup_runner 08 TOKEN_08 \"self-hosted,linux,python-dev,test-runner\""
echo "setup_runner 09 TOKEN_09 \"self-hosted,linux,security-tools,full-env\""
