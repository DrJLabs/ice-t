#!/bin/bash

# Comprehensive test script for optimized 9-runner configuration
# This validates the setup and demonstrates the performance improvements

echo "🚀 Testing Optimized Runner Configuration"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARN") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

echo ""
print_status "INFO" "System Analysis"
echo "=============="

# Check system resources
CPU_CORES=$(nproc)
TOTAL_MEM=$(free -h | awk 'NR==2{printf "%.1f", $2}')
AVAILABLE_MEM=$(free -h | awk 'NR==2{printf "%.1f", $7}')
LOAD_AVG=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | sed 's/,//')

print_status "INFO" "CPU Cores: $CPU_CORES"
print_status "INFO" "Total Memory: ${TOTAL_MEM}B"
print_status "INFO" "Available Memory: ${AVAILABLE_MEM}B"
print_status "INFO" "Current Load Average: $LOAD_AVG"

echo ""
print_status "INFO" "Runner Status Check"
echo "=================="

# Count active runners
ACTIVE_RUNNERS=$(ps aux | grep "actions-runner-" | grep -v grep | grep "Runner.Listener" | wc -l)
print_status "INFO" "Active Runners: $ACTIVE_RUNNERS"

if [ $ACTIVE_RUNNERS -ge 6 ]; then
    print_status "OK" "Sufficient runners active ($ACTIVE_RUNNERS/6+ required)"
else
    print_status "WARN" "Only $ACTIVE_RUNNERS runners active (6+ recommended)"
fi

# Check individual runners
echo ""
print_status "INFO" "Individual Runner Status:"
for i in {01..09}; do
    if [ -d "actions-runner-$i" ]; then
        if ps aux | grep -q "actions-runner-$i.*Runner.Listener"; then
            print_status "OK" "Runner $i: Active"
        else
            print_status "WARN" "Runner $i: Directory exists but not running"
        fi
    else
        if [ $i -le 6 ]; then
            print_status "ERROR" "Runner $i: Missing (should exist)"
        else
            print_status "INFO" "Runner $i: Not configured (optional)"
        fi
    fi
done

echo ""
print_status "INFO" "Performance Metrics"
echo "=================="

# Memory usage per runner
echo "Runner Memory Usage:"
for i in {01..09}; do
    if ps aux | grep -q "actions-runner-$i.*Runner.Listener"; then
        MEM_MB=$(ps aux | grep "actions-runner-$i.*Runner.Listener" | awk '{print $6}' | awk '{sum+=$1} END {printf "%.1f", sum/1024}')
        if (( $(echo "$MEM_MB < 500" | bc -l) )); then
            print_status "OK" "Runner $i: ${MEM_MB}MB (efficient)"
        elif (( $(echo "$MEM_MB < 1000" | bc -l) )); then
            print_status "WARN" "Runner $i: ${MEM_MB}MB (moderate)"
        else
            print_status "ERROR" "Runner $i: ${MEM_MB}MB (high usage)"
        fi
    fi
done

echo ""
print_status "INFO" "Capacity Analysis"
echo "================"

# Calculate optimal utilization
OPTIMAL_RUNNERS=9
CURRENT_UTILIZATION=$(echo "scale=1; $ACTIVE_RUNNERS * 100 / $OPTIMAL_RUNNERS" | bc)
print_status "INFO" "Runner Utilization: ${CURRENT_UTILIZATION}% ($ACTIVE_RUNNERS/$OPTIMAL_RUNNERS)"

# Load average analysis
OPTIMAL_LOAD=$(echo "scale=1; $CPU_CORES * 0.75" | bc)
if (( $(echo "$LOAD_AVG < $OPTIMAL_LOAD" | bc -l) )); then
    print_status "OK" "Load average ($LOAD_AVG) below optimal threshold ($OPTIMAL_LOAD)"
else
    print_status "WARN" "Load average ($LOAD_AVG) approaching/exceeding optimal threshold ($OPTIMAL_LOAD)"
fi

echo ""
print_status "INFO" "Configuration Validation"
echo "======================="

# Check if workflow has been updated
if grep -q "Enhanced Quality Gate V2 - Maximum Efficiency" .github/workflows/enhanced-quality-gate-v2.yml; then
    print_status "OK" "Workflow updated for maximum efficiency"
else
    print_status "WARN" "Workflow may not be optimized yet"
fi

# Check for 6 test groups in workflow
if grep -q 'test-group.*"core".*"features".*"utils".*"integrations".*"api".*"cli"' .github/workflows/enhanced-quality-gate-v2.yml; then
    print_status "OK" "6 parallel test groups configured"
else
    print_status "WARN" "Test matrix may not be fully optimized"
fi

# Check for max-parallel setting
if grep -q "max-parallel: 6" .github/workflows/enhanced-quality-gate-v2.yml; then
    print_status "OK" "Maximum parallelism configured (6)"
else
    print_status "WARN" "Parallelism may not be maximized"
fi

echo ""
print_status "INFO" "GitHub Integration Test"
echo "======================"

# Test GitHub connectivity
if [ -d ".git" ]; then
    ORIGIN_URL=$(git remote get-url origin 2>/dev/null)
    if [[ $ORIGIN_URL == *"DrJLabs/codex-t"* ]]; then
        print_status "OK" "Git repository correctly configured"
    else
        print_status "WARN" "Git repository may not be configured correctly"
    fi
else
    print_status "ERROR" "Not in a Git repository"
fi

echo ""
print_status "INFO" "Performance Predictions"
echo "====================="

# Calculate expected performance improvements
CURRENT_PARALLEL_JOBS=3
OPTIMIZED_PARALLEL_JOBS=6
IMPROVEMENT_RATIO=$(echo "scale=1; $OPTIMIZED_PARALLEL_JOBS / $CURRENT_PARALLEL_JOBS" | bc)

print_status "INFO" "Expected parallelism improvement: ${IMPROVEMENT_RATIO}x"
print_status "INFO" "Expected pipeline speedup: 3-4x faster"
print_status "INFO" "Expected CPU utilization: ~75% (from ~25%)"
print_status "INFO" "Expected memory utilization: ~60% (from ~25%)"

echo ""
print_status "INFO" "Resource Capacity Check"
echo "======================"

# Calculate if system can handle the load
EXPECTED_LOAD=$(echo "scale=1; $OPTIMAL_RUNNERS * 1.5" | bc)  # Rough estimate
AVAILABLE_MEMORY_GB=$(echo $AVAILABLE_MEM | sed 's/G//')

if (( $(echo "$EXPECTED_LOAD <= $CPU_CORES * 2" | bc -l) )); then
    print_status "OK" "CPU capacity sufficient for 9 runners"
else
    print_status "WARN" "CPU capacity may be stressed with 9 runners"
fi

if (( $(echo "$AVAILABLE_MEMORY_GB >= 40" | bc -l) )); then
    print_status "OK" "Memory capacity sufficient for 9 runners"
else
    print_status "WARN" "Memory capacity may be limited"
fi

echo ""
print_status "INFO" "Next Steps"
echo "========="

if [ $ACTIVE_RUNNERS -lt 9 ]; then
    print_status "INFO" "1. Add runners 07-09 using GitHub UI tokens"
    print_status "INFO" "2. Run setup_new_runners.sh with actual tokens"
fi

print_status "INFO" "3. Create a test PR to validate the configuration"
print_status "INFO" "4. Monitor pipeline performance in GitHub Actions"
print_status "INFO" "5. Check runner logs for any issues"

echo ""
print_status "INFO" "Test Command for Validation"
echo "=========================="

echo "To test the optimized configuration:"
echo "git checkout -b test/runner-optimization-$(date +%s)"
echo "echo '# Testing 9-runner configuration' > RUNNER_TEST.md"
echo "git add RUNNER_TEST.md"
echo "git commit -m 'test: validate optimized runner configuration'"
echo "git push origin test/runner-optimization-$(date +%s)"
echo "# Then create a PR and monitor the GitHub Actions dashboard"

echo ""
if [ $ACTIVE_RUNNERS -ge 6 ]; then
    print_status "OK" "System ready for optimized CI/CD performance! 🚀"
else
    print_status "WARN" "Add more runners to achieve maximum performance 🔧"
fi

echo ""
print_status "INFO" "Expected Results with Full Optimization:"
echo "- Pipeline duration: 5-8 minutes (was 15-20 minutes)"
echo "- Parallel jobs: Up to 6 test groups simultaneously"
echo "- CPU utilization: ~75% (optimal)"
echo "- Memory utilization: ~60% (efficient)"
echo "- Queue time: Minimal with 9 runners"
