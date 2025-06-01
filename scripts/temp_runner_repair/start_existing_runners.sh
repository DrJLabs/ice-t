#!/bin/bash

# Start Existing Runners
# Simple script to start the runners that are already configured

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🚀 Starting Existing Runners${NC}"
echo -e "${BLUE}==============================${NC}"
echo

# Function to start a runner
start_runner() {
    local runner_num=$1
    local global_dir="/home/drj/actions-runner-$(printf "%02d" $runner_num)"
    local runner_name="djin-1-slot-$(printf "%02d" $runner_num)"

    if [ ! -d "$global_dir" ]; then
        echo -e "${YELLOW}⚠️  Runner $runner_num directory not found, skipping...${NC}"
        return 1
    fi

    echo -e "${BLUE}🔄 Starting Runner $runner_num${NC}"
    echo "   Name: $runner_name"
    echo "   Directory: $global_dir"

    cd "$global_dir"

    # Check if already running
    if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
        echo -e "${GREEN}✅ $runner_name is already running${NC}"
        cd "/home/drj/codex-t"
        return 0
    fi

    # Kill any stale processes
    pkill -f "Runner.Listener.*$runner_name" 2>/dev/null || true
    sleep 1

    # Start the runner
    echo "  Starting runner..."
    nohup ./run.sh > runner.log 2>&1 &
    sleep 3

    # Check if it started successfully
    if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
        echo -e "${GREEN}✅ $runner_name started successfully!${NC}"
    else
        echo -e "${RED}❌ $runner_name failed to start${NC}"
        echo "  Last few lines of log:"
        tail -3 runner.log 2>/dev/null || echo "  No log available"
    fi

    cd "/home/drj/codex-t"
    echo
}

# Start each existing runner
echo -e "${BLUE}📋 Starting runners 02-06...${NC}"
echo

for i in {02..06}; do
    start_runner $(printf "%02d" $i)
done

echo -e "${GREEN}🎉 Runner startup complete!${NC}"
echo

# Show final status
echo -e "${BLUE}📊 Final Status:${NC}"
for i in {02..06}; do
    runner_name="djin-1-slot-$(printf "%02d" $i)"
    if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
        echo -e "  Runner $i: ${GREEN}✅ Running${NC}"
    else
        echo -e "  Runner $i: ${RED}❌ Not running${NC}"
    fi
done

echo
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Check GitHub: https://github.com/DrJLabs/codex-t/settings/actions/runners"
echo "2. Test with a workflow run"
echo "3. If runners show session conflicts, they may need reconfiguration"
