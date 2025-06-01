#!/bin/bash

# Reactivate Existing PROJECT Runners
# This script attempts to reactivate runners that are already registered in GitHub
# by removing stale .runner files and using the original runner names

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
REPO_URL="https://github.com/DrJLabs/codex-t"
RUNNER_VERSION="2.324.0"

echo -e "${GREEN}🔄 Reactivating Existing PROJECT Runners${NC}"
echo -e "${BLUE}=======================================${NC}"
echo

# Source the runner configuration
if [ -f "runners/configs/runner_config.sh" ]; then
    source runners/configs/runner_config.sh
    echo -e "${GREEN}✅ Loaded runner configuration${NC}"
else
    echo -e "${RED}❌ Runner configuration not found${NC}"
    exit 1
fi

# Function to check if runner exists on GitHub (we'll assume they do based on your statement)
check_runner_in_github() {
    local runner_name=$1
    echo -e "${BLUE}ℹ️  Assuming $runner_name exists in GitHub (as you mentioned)${NC}"
    return 0
}

# Function to reactivate a project runner
reactivate_project_runner() {
    local runner_num=$1
    local runner_dir="$PROJECT_DIR/actions-runner-$runner_num"
    local labels="${RUNNER_LABELS[$runner_num]}"
    local runner_name="codex-t-runner-$runner_num"

    echo -e "${BLUE}🔄 Reactivating PROJECT Runner $runner_num${NC}"
    echo "   Name: $runner_name"
    echo "   Labels: $labels"
    echo "   Directory: $runner_dir"

    # Check if runner exists in GitHub
    if ! check_runner_in_github "$runner_name"; then
        echo -e "${YELLOW}⚠️  $runner_name doesn't exist in GitHub, skipping...${NC}"
        return 1
    fi

    # Create directory if it doesn't exist
    if [ ! -d "$runner_dir" ]; then
        echo "  Creating directory..."
        mkdir -p "$runner_dir"
        cd "$runner_dir"

        # Download and extract runner
        echo "  Downloading GitHub Actions Runner..."
        curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
        tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
        rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    else
        cd "$runner_dir"
        echo "  Directory exists, checking configuration..."
    fi

    # Remove stale .runner file if it exists (allows reconfiguration)
    if [ -f ".runner" ]; then
        echo "  Removing stale .runner configuration..."
        rm -f .runner
    fi

    # Remove credentials file if it exists
    if [ -f ".credentials" ]; then
        echo "  Removing stale .credentials file..."
        rm -f .credentials
    fi

    # Stop any running service
    if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
        echo "  Stopping existing runner process..."
        pkill -f "Runner.Listener.*$runner_name" || true
        sleep 2
    fi

    echo -e "${YELLOW}🔑 Registration token needed for $runner_name${NC}"
    echo "Since the runner exists in GitHub, you can:"
    echo "1. Go to: https://github.com/DrJLabs/codex-t/settings/actions/runners"
    echo "2. Find the existing runner '$runner_name' and delete it"
    echo "3. Click 'New self-hosted runner'"
    echo "4. Copy the token (after --token)"
    read -p "Enter registration token for $runner_name (or 'skip' to skip): " token

    if [ "$token" = "skip" ] || [ -z "$token" ]; then
        echo -e "${YELLOW}⚠️  Skipped $runner_name${NC}"
        cd "$PROJECT_DIR"
        return 1
    fi

    # Configure the runner
    echo "  Configuring runner..."
    ./config.sh --url "$REPO_URL" \
                 --token "$token" \
                 --name "$runner_name" \
                 --labels "$labels" \
                 --runnergroup default \
                 --work _work \
                 --replace \
                 --unattended

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $runner_name configured successfully!${NC}"

        # Start the runner
        echo "  Starting runner..."
        nohup ./run.sh > runner.log 2>&1 &
        sleep 3

        if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
            echo -e "${GREEN}✅ $runner_name is now running${NC}"
        else
            echo -e "${YELLOW}⚠️  $runner_name may not have started properly${NC}"
            echo "  Check logs: tail -f $runner_dir/runner.log"
        fi
    else
        echo -e "${RED}❌ Failed to configure $runner_name${NC}"
    fi

    cd "$PROJECT_DIR"
    echo
}

# Alternative: Try to reuse existing configurations if they exist
try_restart_existing() {
    local runner_num=$1
    local runner_dir="$PROJECT_DIR/actions-runner-$runner_num"
    local runner_name="codex-t-runner-$runner_num"

    if [ -d "$runner_dir" ] && [ -f "$runner_dir/.runner" ]; then
        echo -e "${BLUE}🔄 Attempting to restart existing runner $runner_num${NC}"
        cd "$runner_dir"

        # Try to start the runner
        nohup ./run.sh > runner.log 2>&1 &
        sleep 3

        if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
            echo -e "${GREEN}✅ $runner_name restarted successfully!${NC}"
            cd "$PROJECT_DIR"
            return 0
        else
            echo -e "${YELLOW}⚠️  $runner_name failed to restart, will need reconfiguration${NC}"
            cd "$PROJECT_DIR"
            return 1
        fi
    fi
    return 1
}

# Main execution
echo -e "${BLUE}📋 Attempting to reactivate PROJECT runners:${NC}"
for i in {01..09}; do
    labels="${RUNNER_LABELS[$i]}"
    echo "  Runner $i: $labels"
done
echo

echo -e "${BLUE}🔄 First, trying to restart existing configurations...${NC}"
restarted_count=0
for i in {01..09}; do
    if try_restart_existing $i; then
        ((restarted_count++))
    fi
done

if [ $restarted_count -gt 0 ]; then
    echo -e "${GREEN}✅ Successfully restarted $restarted_count runners${NC}"
    echo
fi

echo -e "${BLUE}🔧 For remaining runners, manual reconfiguration needed...${NC}"
read -p "Continue with manual reconfiguration for remaining runners? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Reactivation cancelled"
    exit 0
fi

echo -e "${GREEN}🔄 Starting manual reconfiguration...${NC}"
echo

# Reconfigure each project runner that needs it
for i in {01..09}; do
    runner_dir="$PROJECT_DIR/actions-runner-$i"
    if [ ! -d "$runner_dir" ] || [ ! -f "$runner_dir/.runner" ] || ! pgrep -f "Runner.Listener.*codex-t-runner-$i" > /dev/null; then
        reactivate_project_runner $i
    else
        echo -e "${GREEN}✅ Runner $i already active${NC}"
    fi
done

echo -e "${GREEN}🎉 PROJECT runner reactivation complete!${NC}"
echo
echo -e "${BLUE}📊 Final status:${NC}"
./runners/scripts/quick_status.sh 2>/dev/null || echo "Status script not available"
echo
echo -e "${BLUE}📁 PROJECT runner directories:${NC}"
for i in {01..09}; do
    if [ -d "actions-runner-$i" ]; then
        if pgrep -f "Runner.Listener.*codex-t-runner-$i" > /dev/null; then
            echo "  ✅ actions-runner-$i/ (RUNNING)"
        else
            echo "  ⚠️  actions-runner-$i/ (STOPPED)"
        fi
    else
        echo "  ❌ actions-runner-$i/ (MISSING)"
    fi
done
