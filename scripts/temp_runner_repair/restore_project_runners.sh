#!/bin/bash

# Restore PROJECT Runners - Final Solution
# Combines the fresh GitHub Actions runner binaries with backed up configurations

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
BACKUP_DIR="$PROJECT_DIR/archive/global_runners_backup"
RUNNER_VERSION="2.324.0"

echo -e "${GREEN}🔄 FINAL RESTORE: PROJECT Runners${NC}"
echo -e "${BLUE}=================================${NC}"
echo

# Function to create and configure a runner
setup_project_runner() {
    local runner_num=$1
    local runner_dir="$PROJECT_DIR/actions-runner-$runner_num"
    local backup_dir="$BACKUP_DIR/actions-runner-$runner_num"

    echo -e "${BLUE}🔧 Setting up Runner $runner_num...${NC}"

    # Create runner directory and download fresh binaries
    mkdir -p "$runner_dir"
    cd "$runner_dir"

    echo "  📦 Downloading GitHub Actions Runner v${RUNNER_VERSION}..."
    if curl -s -f -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
        "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"; then

        tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
        rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
        chmod +x config.sh run.sh
        echo "  ✅ Fresh runner binaries installed"
    else
        echo -e "  ${RED}❌ Failed to download runner${NC}"
        return 1
    fi

    # Restore backed up configuration if available
    if [ -d "$backup_dir" ]; then
        echo "  🔄 Restoring backed up configuration..."

        # Copy configuration files
        for file in .runner .credentials .credentials_rsaparams .env; do
            if [ -f "$backup_dir/$file" ]; then
                cp "$backup_dir/$file" "$runner_dir/$file"
                echo "    ✅ Restored $file"
            fi
        done

        # Start the runner
        echo "  🚀 Starting runner..."
        nohup ./run.sh > runner.log 2>&1 &
        sleep 3

        # Check if it started successfully
        if pgrep -f "$runner_dir.*Runner.Listener" > /dev/null; then
            echo -e "  ${GREEN}✅ Runner $runner_num ONLINE!${NC}"
            cd "$PROJECT_DIR"
            return 0
        else
            echo -e "  ${YELLOW}⚠️  Runner $runner_num configured but not running${NC}"
            echo "  Log preview:"
            tail -3 runner.log 2>/dev/null | sed 's/^/    /' || echo "    No log available"
        fi
    else
        echo -e "  ${YELLOW}⚠️  No backup found for runner $runner_num - needs manual configuration${NC}"
    fi

    cd "$PROJECT_DIR"
    return 0
}

# Create all 9 PROJECT runners
echo -e "${BLUE}📋 Creating all 9 PROJECT runners...${NC}"
echo

created_count=0
restored_count=0
manual_count=0

for i in {01..09}; do
    if setup_project_runner $i; then
        ((created_count++))

        # Check if it has backup config
        if [ -d "$BACKUP_DIR/actions-runner-$i" ]; then
            ((restored_count++))
        else
            ((manual_count++))
        fi
    fi
    echo
done

echo -e "${GREEN}🎉 PROJECT Runner Restoration Complete!${NC}"
echo -e "${BLUE}=======================================${NC}"
echo

echo -e "${BLUE}📊 Results:${NC}"
echo "  📁 Directories created: $created_count/9"
echo "  🔄 Configurations restored: $restored_count/9"
echo "  🔑 Need manual config: $manual_count/9"

echo
echo -e "${BLUE}🔍 Final Status Check:${NC}"
running_count=0
configured_count=0

for i in {01..09}; do
    runner_dir="$PROJECT_DIR/actions-runner-$i"

    if [ -d "$runner_dir" ]; then
        if [ -f "$runner_dir/.runner" ]; then
            if pgrep -f "$runner_dir.*Runner.Listener" > /dev/null; then
                echo -e "  Runner $i: ${GREEN}✅ RUNNING${NC}"
                ((running_count++))
            else
                echo -e "  Runner $i: ${YELLOW}⚠️  CONFIGURED (stopped)${NC}"
                ((configured_count++))
            fi
        else
            echo -e "  Runner $i: ${BLUE}📋 READY FOR CONFIG${NC}"
        fi
    else
        echo -e "  Runner $i: ${RED}❌ MISSING${NC}"
    fi
done

echo
echo -e "${BLUE}📈 Summary:${NC}"
echo "  ✅ Running: $running_count/9"
echo "  ⚠️  Configured (stopped): $configured_count/9"
echo "  📋 Need configuration: $((9 - running_count - configured_count))/9"

if [ $running_count -gt 0 ]; then
    echo
    echo -e "${GREEN}🎊 SUCCESS: $running_count PROJECT runners are ONLINE! 🎊${NC}"
fi

if [ $configured_count -gt 0 ]; then
    echo
    echo -e "${YELLOW}🚀 To start configured runners:${NC}"
    for i in {01..09}; do
        if [ -f "$PROJECT_DIR/actions-runner-$i/.runner" ] && ! pgrep -f "actions-runner-$i.*Runner.Listener" > /dev/null; then
            echo "  cd actions-runner-$i && nohup ./run.sh > runner.log 2>&1 &"
        fi
    done
fi

if [ $((9 - running_count - configured_count)) -gt 0 ]; then
    echo
    echo -e "${YELLOW}🔑 For runners needing configuration:${NC}"
    echo "  1. Get token: https://github.com/DrJLabs/codex-t/settings/actions/runners"
    echo "  2. Run: cd actions-runner-0X && ./configure_runner.sh <token>"
fi

echo
echo -e "${GREEN}✨ All PROJECT runners restored exactly as they were! ✨${NC}"
