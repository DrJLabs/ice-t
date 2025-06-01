#!/bin/bash

# Consolidate Runner Scripts
# This script consolidates the 22+ runner scripts into a more efficient system

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🔧 Consolidating Runner Scripts${NC}"
echo "Found 22+ runner-related scripts. Consolidating into efficient system..."

# Create consolidated runners directory
mkdir -p runners/scripts
mkdir -p runners/configs
mkdir -p runners/logs

echo -e "${BLUE}📁 Creating consolidated structure...${NC}"

# Create master runner management script
cat > runners/manage_runners.sh << 'EOF'
#!/bin/bash
# Master Runner Management Script
# Consolidates all runner operations into one interface

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load configuration
source "$SCRIPT_DIR/configs/runner_config.sh"

usage() {
    echo "Usage: $0 {start|stop|restart|status|setup|clean} [runner_id]"
    echo ""
    echo "Commands:"
    echo "  start [id]    - Start runner(s) (all if no id specified)"
    echo "  stop [id]     - Stop runner(s)"
    echo "  restart [id]  - Restart runner(s)"
    echo "  status        - Show status of all runners"
    echo "  setup [id]    - Setup/configure runner(s)"
    echo "  clean         - Clean runner workspaces"
    echo ""
    echo "Examples:"
    echo "  $0 start 01   - Start runner 01"
    echo "  $0 start      - Start all runners"
    echo "  $0 status     - Show all runner status"
}

start_runner() {
    local runner_id=$1
    local runner_dir="$PROJECT_DIR/actions-runner-$runner_id"

    if [ ! -d "$runner_dir" ]; then
        echo "❌ Runner $runner_id not found"
        return 1
    fi

    echo "🚀 Starting runner $runner_id..."
    cd "$runner_dir"
    nohup ./run.sh > "$SCRIPT_DIR/logs/runner-$runner_id.log" 2>&1 &
    echo "✅ Runner $runner_id started"
}

stop_runner() {
    local runner_id=$1
    echo "🛑 Stopping runner $runner_id..."
    pkill -f "actions-runner-$runner_id" || echo "Runner $runner_id was not running"
}

status_all() {
    echo "📊 Runner Status:"
    for i in {01..09}; do
        if ps aux | grep "actions-runner-$i" | grep "Runner.Listener" | grep -v grep > /dev/null; then
            echo "  Runner $i: ✅ ACTIVE"
        else
            echo "  Runner $i: ❌ INACTIVE"
        fi
    done
}

case "$1" in
    start)
        if [ -n "$2" ]; then
            start_runner "$2"
        else
            for i in {01..09}; do
                start_runner "$i"
                sleep 2
            done
        fi
        ;;
    stop)
        if [ -n "$2" ]; then
            stop_runner "$2"
        else
            echo "🛑 Stopping all runners..."
            pkill -f "Runner.Listener" || echo "No runners were running"
        fi
        ;;
    restart)
        $0 stop "$2"
        sleep 5
        $0 start "$2"
        ;;
    status)
        status_all
        ;;
    setup)
        echo "🔧 Setup functionality - use existing configure_all_runners.sh"
        ;;
    clean)
        echo "🧹 Cleaning runner workspaces..."
        for i in {01..09}; do
            if [ -d "$PROJECT_DIR/actions-runner-$i/_work" ]; then
                rm -rf "$PROJECT_DIR/actions-runner-$i/_work"/*
                echo "  Cleaned runner $i workspace"
            fi
        done
        ;;
    *)
        usage
        exit 1
        ;;
esac
EOF

# Create runner configuration
cat > runners/configs/runner_config.sh << 'EOF'
#!/bin/bash
# Runner Configuration Settings

# Runner settings
RUNNER_COUNT=9
RUNNER_VERSION="2.324.0"
PROJECT_DIR="/home/drj/codex-t"

# Runner labels by ID
declare -A RUNNER_LABELS=(
    [01]="self-hosted,linux,fast-setup,test-runner"
    [02]="self-hosted,linux,test-runner,coverage-tools"
    [03]="self-hosted,linux,pre-commit-ready"
    [04]="self-hosted,linux,python-dev"
    [05]="self-hosted,linux,security-tools,docs-tools"
    [06]="self-hosted,linux,integration-env,full-env"
    [07]="self-hosted,linux,fast-setup,pre-commit-ready"
    [08]="self-hosted,linux,python-dev,test-runner"
    [09]="self-hosted,linux,security-tools,full-env"
)

# Export for use in other scripts
export RUNNER_COUNT RUNNER_VERSION PROJECT_DIR
EOF

# Create simple status checker
cat > runners/scripts/quick_status.sh << 'EOF'
#!/bin/bash
# Quick runner status check

ACTIVE=$(ps aux | grep "Runner.Listener" | grep -v grep | wc -l)
echo "Active runners: $ACTIVE/9"

if [ $ACTIVE -ge 9 ]; then
    echo "✅ All systems operational"
else
    echo "⚠️  Some runners inactive"
fi
EOF

# Make scripts executable
chmod +x runners/manage_runners.sh
chmod +x runners/scripts/quick_status.sh
chmod +x runners/configs/runner_config.sh

echo -e "${GREEN}✅ Consolidated runner management system created${NC}"
echo ""
echo -e "${BLUE}New Usage:${NC}"
echo "  ./runners/manage_runners.sh start     # Start all runners"
echo "  ./runners/manage_runners.sh stop      # Stop all runners"
echo "  ./runners/manage_runners.sh status    # Check status"
echo "  ./runners/scripts/quick_status.sh     # Quick status"
echo ""
echo -e "${YELLOW}📋 Scripts to archive/remove:${NC}"

# List scripts that can be consolidated
echo "The following scripts can be archived (functionality moved to runners/):"
ls -1 *.sh | grep -E "(runner|setup)" | grep -v "setup_codex.sh" | head -10

echo ""
echo -e "${BLUE}💡 Recommendation:${NC}"
echo "1. Test the new consolidated system"
echo "2. Archive old scripts to archive/ directory"
echo "3. Update documentation to use new system"
EOF
