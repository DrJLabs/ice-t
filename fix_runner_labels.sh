#!/bin/bash
# Fix ice-t runner labels to match workflow expectations

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/DrJLabs/ice-t"
RUNNERS_DIR="/home/drj/ice-t-runners"

echo -e "${GREEN}🔧 Fixing ice-t runner labels to match workflow expectations${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Expected labels based on workflow analysis
declare -A RUNNER_LABELS
RUNNER_LABELS[1]="self-hosted,ice-t,build"
RUNNER_LABELS[2]="self-hosted,ice-t,test"
RUNNER_LABELS[3]="self-hosted,ice-t,test"
RUNNER_LABELS[4]="self-hosted,ice-t,test"
RUNNER_LABELS[5]="self-hosted,ice-t,quality"
RUNNER_LABELS[6]="self-hosted,ice-t,security"
RUNNER_LABELS[7]="self-hosted,ice-t,diagrams"

echo -e "${YELLOW}Current workflow expectations:${NC}"
echo "  - [self-hosted, ice-t, build] - Build and setup tasks"
echo "  - [self-hosted, ice-t, test] - Test execution (multiple runners)"
echo "  - [self-hosted, ice-t, quality] - Code quality checks"
echo "  - [self-hosted, ice-t, security] - Security scanning"
echo "  - [self-hosted, ice-t, diagrams] - Diagram generation"
echo

# Function to reconfigure a runner
reconfigure_runner() {
    local runner_num=$1
    local runner_dir="${RUNNERS_DIR}/ice-t-runner-${runner_num}"
    local runner_name="ice-t-runner-${runner_num}"
    local labels="${RUNNER_LABELS[$runner_num]}"
    
    echo -e "${BLUE}🔧 Reconfiguring Runner ${runner_num}${NC}"
    echo "   Name: $runner_name"
    echo "   Labels: $labels"
    echo "   Directory: $runner_dir"
    
    if [ ! -d "$runner_dir" ]; then
        echo -e "${RED}❌ Runner directory not found: $runner_dir${NC}"
        return 1
    fi
    
    cd "$runner_dir"
    
    # Stop the service first
    echo "  🛑 Stopping service..."
    sudo systemctl stop "actions.runner.DrJLabs-ice-t.ice-t-runner-${runner_num}.service" || true
    sleep 2
    
    # Remove existing configuration
    echo "  🧹 Removing existing configuration..."
    ./config.sh remove --unattended || true
    sleep 1
    
    echo -e "${YELLOW}🔑 Registration token needed for $runner_name${NC}"
    echo "Go to: https://github.com/DrJLabs/ice-t/settings/actions/runners/new"
    echo "Select 'Linux' and copy the registration token"
    read -p "Enter registration token for $runner_name: " token
    
    if [ -z "$token" ]; then
        echo -e "${RED}❌ No token provided for $runner_name, skipping...${NC}"
        cd "$RUNNERS_DIR"
        return 1
    fi
    
    # Configure with new labels
    echo "  🔧 Configuring with new labels..."
    ./config.sh \
        --url "$REPO_URL" \
        --token "$token" \
        --name "$runner_name" \
        --labels "$labels" \
        --work "_work" \
        --replace \
        --unattended \
        --runasservice
    
    if [ $? -eq 0 ]; then
        echo "  🚀 Installing and starting service..."
        sudo ./svc.sh install || true
        sudo ./svc.sh start
        echo -e "${GREEN}✅ Runner ${runner_num} reconfigured successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to configure runner ${runner_num}${NC}"
    fi
    
    cd "$RUNNERS_DIR"
    echo
}

# Main execution
echo -e "${YELLOW}📋 Runners to reconfigure:${NC}"
for i in {1..7}; do
    echo "   Runner $i: ${RUNNER_LABELS[$i]}"
done
echo

read -p "Do you want to proceed with reconfiguring all runners? (y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Starting runner reconfiguration...${NC}"
    echo
    
    for i in {1..7}; do
        reconfigure_runner $i
    done
    
    echo -e "${GREEN}🎉 All runners reconfigured!${NC}"
    echo
    echo "Check status with:"
    echo "  sudo systemctl status actions.runner.*"
else
    echo -e "${YELLOW}⚠️ Reconfiguration cancelled${NC}"
fi 