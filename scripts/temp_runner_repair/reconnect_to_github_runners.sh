#!/bin/bash

# Reconnect to Existing GitHub Runners
# This script reconnects to the codex-runner-01 through codex-runner-09 that are already registered

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
REPO_URL="https://github.com/DrJLabs/codex-t"

echo -e "${GREEN}🔗 Reconnecting to GitHub Registered Runners${NC}"
echo -e "${BLUE}=============================================${NC}"
echo

echo -e "${YELLOW}📋 GitHub shows these runners as registered but offline:${NC}"
echo "  codex-runner-01 through codex-runner-09"
echo

# Function to reconnect a runner
reconnect_runner() {
    local runner_num=$1
    local runner_name="codex-runner-$(printf "%02d" $runner_num)"
    local runner_dir="$PROJECT_DIR/actions-runner-$(printf "%02d" $runner_num)"

    echo -e "${BLUE}🔗 Reconnecting $runner_name...${NC}"

    if [ ! -d "$runner_dir" ]; then
        echo -e "  ${RED}❌ Directory $runner_dir not found${NC}"
        return 1
    fi

    cd "$runner_dir"

    # Remove old configuration that doesn't match GitHub
    echo "  🧹 Cleaning old configuration..."
    rm -f .runner .credentials .credentials_rsaparams .env

    echo -e "  ${YELLOW}🔑 This runner ($runner_name) is already registered in GitHub${NC}"
    echo "  Instead of creating a new registration, we need to:"
    echo "  1. Get a token for EXISTING runner $runner_name"
    echo "  2. Use --replace to reconnect to existing registration"
    echo

    read -p "  Enter registration token for $runner_name (or 'skip'): " token

    if [ "$token" = "skip" ] || [ -z "$token" ]; then
        echo -e "  ${YELLOW}⚠️  Skipped $runner_name${NC}"
        cd "$PROJECT_DIR"
        return 1
    fi

    # Configure with existing runner name
    echo "  🔧 Configuring $runner_name..."
    ./config.sh --url "$REPO_URL" \
                 --token "$token" \
                 --name "$runner_name" \
                 --runnergroup default \
                 --work _work \
                 --replace \
                 --unattended

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✅ $runner_name configured successfully!${NC}"

        # Start the runner
        echo "  🚀 Starting $runner_name..."
        nohup ./run.sh > runner.log 2>&1 &
        sleep 3

        if pgrep -f "$runner_dir.*Runner.Listener" > /dev/null; then
            echo -e "  ${GREEN}✅ $runner_name is now ONLINE!${NC}"
        else
            echo -e "  ${YELLOW}⚠️  $runner_name may not have started properly${NC}"
            echo "  Log preview:"
            tail -3 runner.log 2>/dev/null | sed 's/^/    /'
        fi
    else
        echo -e "  ${RED}❌ Failed to configure $runner_name${NC}"
    fi

    cd "$PROJECT_DIR"
    echo
}

echo -e "${BLUE}🔧 Reconnection Process:${NC}"
echo "  We need to reconnect to the existing GitHub runners"
echo "  Each runner (codex-runner-01 through 09) is already registered"
echo "  We just need to get new tokens and reconnect"
echo

for i in {1..9}; do
    reconnect_runner $i
done

echo -e "${GREEN}🎉 Reconnection Process Complete!${NC}"
echo

# Final status check
echo -e "${BLUE}🔍 Final Status Check:${NC}"
online_count=0

for i in {01..09}; do
    runner_dir="$PROJECT_DIR/actions-runner-$i"
    runner_name="codex-runner-$i"

    if [ -d "$runner_dir" ] && [ -f "$runner_dir/.runner" ]; then
        if pgrep -f "$runner_dir.*Runner.Listener" > /dev/null; then
            echo -e "  $runner_name: ${GREEN}✅ ONLINE${NC}"
            ((online_count++))
        else
            echo -e "  $runner_name: ${YELLOW}⚠️  CONFIGURED (stopped)${NC}"
        fi
    else
        echo -e "  $runner_name: ${RED}❌ NOT CONFIGURED${NC}"
    fi
done

echo
if [ $online_count -eq 9 ]; then
    echo -e "${GREEN}🎊 All 9 GitHub runners are now ONLINE! 🎊${NC}"
elif [ $online_count -gt 0 ]; then
    echo -e "${GREEN}✅ $online_count/9 GitHub runners are now ONLINE!${NC}"
else
    echo -e "${YELLOW}⚠️  No runners came online. Check GitHub tokens.${NC}"
fi

echo
echo -e "${BLUE}💡 Notes:${NC}"
echo "  • Each token can only be used once"
echo "  • Get tokens from: https://github.com/DrJLabs/codex-t/settings/actions/runners"
echo "  • The runners should show as 'Idle' in GitHub when working"
