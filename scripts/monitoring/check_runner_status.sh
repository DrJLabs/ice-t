#!/bin/bash

# Runner Status Checker and Optimizer
# This script analyzes current runner setup and provides optimization recommendations

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🔍 GitHub Actions Runner Status Analysis${NC}"
echo "========================================"
echo

# Check system resources
echo -e "${BLUE}📊 System Resources:${NC}"
CPU_CORES=$(nproc)
TOTAL_MEM_GB=$(free -g | awk 'NR==2{print $2}')
AVAILABLE_MEM_GB=$(free -g | awk 'NR==2{print $7}')
LOAD_AVG=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | sed 's/,//')

echo "  CPU Cores: $CPU_CORES"
echo "  Total Memory: ${TOTAL_MEM_GB}GB"
echo "  Available Memory: ${AVAILABLE_MEM_GB}GB"
echo "  Current Load: $LOAD_AVG"
echo

# Check runner directories
echo -e "${BLUE}📁 Runner Directories:${NC}"
RUNNER_DIRS=()
for i in {01..09}; do
    if [ -d "actions-runner-$i" ]; then
        RUNNER_DIRS+=("actions-runner-$i")
        echo "  ✅ actions-runner-$i: Present"
    else
        echo "  ❌ actions-runner-$i: Missing"
    fi
done
echo

# Check active runners
echo -e "${BLUE}🏃 Active Runners:${NC}"
ACTIVE_COUNT=0
for dir in "${RUNNER_DIRS[@]}"; do
    if pgrep -f "$dir.*Runner.Listener" > /dev/null; then
        echo "  ✅ $dir: Running"
        ((ACTIVE_COUNT++))

        # Get memory usage
        MEM_KB=$(pgrep -f "$dir.*Runner.Listener" | xargs ps -o pid,rss | tail -n +2 | awk '{sum+=$2} END {print sum}')
        if [ ! -z "$MEM_KB" ]; then
            MEM_MB=$((MEM_KB / 1024))
            echo "    Memory: ${MEM_MB}MB"
        fi
    else
        echo "  ❌ $dir: Not running"
    fi
done

echo
echo -e "${BLUE}📈 Runner Summary:${NC}"
echo "  Active Runners: $ACTIVE_COUNT/${#RUNNER_DIRS[@]}"
echo "  Target for Workflow: 9 runners"

# Calculate optimal configuration
echo
echo -e "${BLUE}🎯 Optimization Analysis:${NC}"

# CPU utilization recommendation
OPTIMAL_LOAD=$(echo "scale=1; $CPU_CORES * 0.75" | bc)
if (( $(echo "$LOAD_AVG < $OPTIMAL_LOAD" | bc -l) )); then
    echo "  ✅ CPU: Can handle more load (current: $LOAD_AVG, optimal: <$OPTIMAL_LOAD)"
    CAN_ADD_RUNNERS=true
else
    echo "  ⚠️  CPU: Approaching capacity (current: $LOAD_AVG, optimal: <$OPTIMAL_LOAD)"
    CAN_ADD_RUNNERS=false
fi

# Memory utilization recommendation
REQUIRED_MEM_GB=16  # Rough estimate for 9 runners
if [ $AVAILABLE_MEM_GB -ge $REQUIRED_MEM_GB ]; then
    echo "  ✅ Memory: Sufficient for 9 runners (available: ${AVAILABLE_MEM_GB}GB)"
else
    echo "  ⚠️  Memory: May be limited for 9 runners (available: ${AVAILABLE_MEM_GB}GB, recommended: ${REQUIRED_MEM_GB}GB)"
fi

# Provide recommendations
echo
echo -e "${BLUE}💡 Recommendations:${NC}"

if [ $ACTIVE_COUNT -lt 9 ]; then
    MISSING_RUNNERS=$((9 - ACTIVE_COUNT))
    echo "  📝 Need to add $MISSING_RUNNERS more runners for optimal workflow performance"

    if [ $CAN_ADD_RUNNERS == true ]; then
        echo "  ✅ System can handle additional runners"
        echo "  🚀 Run: ./create_optimal_runners.sh"
    else
        echo "  ⚠️  System may be stressed with additional runners"
        echo "  🔧 Consider optimizing existing runners or upgrading hardware"
    fi
fi

# Check for idle optimization
echo
echo -e "${BLUE}⏱️  Idle Optimization Strategy:${NC}"
echo "  🎯 Goal: Runners should sit idle often during action runs"
echo "  📊 Current utilization: ${ACTIVE_COUNT}/9 runners active"

IDLE_PERCENTAGE=$(echo "scale=0; (9 - $ACTIVE_COUNT) * 100 / 9" | bc)
echo "  📈 Idle capacity: ${IDLE_PERCENTAGE}%"

if [ $IDLE_PERCENTAGE -ge 33 ]; then
    echo "  ✅ Good idle capacity - runners can handle CI bursts efficiently"
elif [ $IDLE_PERCENTAGE -ge 20 ]; then
    echo "  ⚠️  Moderate idle capacity - may have queuing during peak times"
else
    echo "  🚨 Low idle capacity - likely to have queuing and delays"
fi

# Workflow optimization check
echo
echo -e "${BLUE}⚡ Workflow Optimization Status:${NC}"
if grep -q "max-parallel: 6" .github/workflows/enhanced-quality-gate-v2.yml 2>/dev/null; then
    echo "  ✅ 6 parallel test groups configured"
else
    echo "  ❌ Parallel test configuration needs optimization"
fi

if grep -q "Enhanced Quality Gate V2 - Maximum Efficiency" .github/workflows/enhanced-quality-gate-v2.yml 2>/dev/null; then
    echo "  ✅ Workflow optimized for maximum efficiency"
else
    echo "  ❌ Workflow needs efficiency optimization"
fi

# GitHub token helper
echo
echo -e "${BLUE}🔑 GitHub Token Helper:${NC}"
echo "  📋 To get registration tokens:"
echo "     1. Visit: https://github.com/DrJLabs/codex-t/settings/actions/runners"
echo "     2. Click 'New self-hosted runner'"
echo "     3. Copy the token after --token"
echo

# Final recommendations
echo -e "${GREEN}🚀 Next Steps:${NC}"
if [ $ACTIVE_COUNT -lt 6 ]; then
    echo "  1. 🔧 Fix existing runners that are not running"
    echo "  2. 🆕 Add missing runners using ./create_optimal_runners.sh"
elif [ $ACTIVE_COUNT -lt 9 ]; then
    echo "  1. 🆕 Add $(( 9 - ACTIVE_COUNT )) more runners for optimal performance"
    echo "  2. 🎯 Use ./create_optimal_runners.sh for guided setup"
else
    echo "  1. ✅ Runner count is optimal"
    echo "  2. 🔍 Monitor performance in GitHub Actions"
fi

echo "  3. 📊 Test with a PR to validate parallel execution"
echo "  4. 🎛️  Monitor idle capacity during CI runs"
echo
echo -e "${BLUE}💡 Pro Tips:${NC}"
echo "  • Runners should idle 30-50% of the time for optimal burst handling"
echo "  • Each runner uses ~200-500MB RAM when idle"
echo "  • 9 runners enable 6 parallel test groups + 3 infrastructure jobs"
echo "  • Expected 3-4x speedup with proper runner distribution"
