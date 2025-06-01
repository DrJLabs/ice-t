#!/bin/bash

# Reconfigure Existing Runners with Proper Labels
# Based on the restored runners/configs/runner_config.sh configuration

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
REPO_URL="https://github.com/DrJLabs/codex-t"

echo -e "${GREEN}🔧 Reconfiguring Existing Runners with Proper Labels${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo

# Source the runner configuration
if [ -f "runners/configs/runner_config.sh" ]; then
    source runners/configs/runner_config.sh
    echo -e "${GREEN}✅ Loaded runner configuration${NC}"
else
    echo -e "${RED}❌ Runner configuration not found${NC}"
    exit 1
fi

# Function to reconfigure a runner with new labels
reconfigure_runner() {
    local runner_num=$1
    local runner_dir="$PROJECT_DIR/actions-runner-$(printf "%02d" $runner_num)"
    local global_dir="/home/drj/actions-runner-$(printf "%02d" $runner_num)"

    if [ ! -d "$global_dir" ]; then
        echo -e "${YELLOW}⚠️  Runner $runner_num not found, skipping...${NC}"
        return 1
    fi

    local labels="${RUNNER_LABELS[$runner_num]}"
    local runner_name="djin-1-slot-$(printf "%02d" $runner_num)"

    echo -e "${BLUE}🔧 Reconfiguring Runner $runner_num${NC}"
    echo "   Name: $runner_name"
    echo "   Labels: $labels"
    echo "   Directory: $global_dir"

    cd "$global_dir"

    # Stop the runner if it's running
    if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
        echo "  Stopping running instance..."
        pkill -f "Runner.Listener.*$runner_name" || true
        sleep 2
    fi

    # Remove existing configuration
    if [ -f ".runner" ]; then
        echo "  Removing existing configuration..."
        ./config.sh remove --unattended || true
        sleep 1
    fi

    # Get registration token
    echo
    echo -e "${YELLOW}🔑 Registration token needed for $runner_name${NC}"
    echo "1. Open: https://github.com/DrJLabs/codex-t/settings/actions/runners"
    echo "2. Click 'New self-hosted runner'"
    echo "3. Select 'Linux' and 'x64'"
    echo "4. Copy the token (after --token)"
    read -p "Enter registration token for $runner_name: " token

    if [ -z "$token" ]; then
        echo -e "${RED}❌ No token provided for $runner_name, skipping...${NC}"
        cd "$PROJECT_DIR"
        return 1
    fi

    # Configure with new labels
    echo "  Configuring with new labels..."
    ./config.sh --url "$REPO_URL" \
                 --token "$token" \
                 --name "$runner_name" \
                 --labels "$labels" \
                 --runnergroup default \
                 --work _work \
                 --replace \
                 --unattended

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $runner_name reconfigured successfully!${NC}"

        # Start the runner
        echo "  Starting runner..."
        nohup ./run.sh > runner.log 2>&1 &
        sleep 2

        if pgrep -f "Runner.Listener.*$runner_name" > /dev/null; then
            echo -e "${GREEN}✅ $runner_name is now running${NC}"
        else
            echo -e "${YELLOW}⚠️  $runner_name may not have started properly${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to reconfigure $runner_name${NC}"
    fi

    cd "$PROJECT_DIR"
    echo
}

# Main execution
echo -e "${BLUE}📋 Runners to reconfigure:${NC}"
for i in {02..06}; do
    if [ -d "/home/drj/actions-runner-$(printf "%02d" $i)" ]; then
        labels="${RUNNER_LABELS[$(printf "%02d" $i)]}"
        echo "  Runner $i: $labels"
    fi
done
echo

read -p "Continue with reconfiguration? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Reconfiguration cancelled"
    exit 0
fi

echo -e "${GREEN}🔄 Starting runner reconfiguration...${NC}"
echo

# Reconfigure each existing runner
for i in {02..06}; do
    reconfigure_runner $(printf "%02d" $i)
done

echo -e "${GREEN}🎉 Runner reconfiguration complete!${NC}"
echo
echo -e "${BLUE}📊 Next Steps:${NC}"
echo "1. Check GitHub: https://github.com/DrJLabs/codex-t/settings/actions/runners"
echo "2. Verify runner status: ./runners/scripts/quick_status.sh"
echo "3. Test with a workflow run"
