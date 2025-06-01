#!/bin/bash

echo "=== CI & Runner Status Check ==="
echo "Date: $(date)"
echo

echo "1. Active Runners:"
RUNNER_COUNT=$(ps aux | grep "Runner.Listener" | grep -v grep | wc -l)
echo "   Total active: $RUNNER_COUNT"

echo
echo "2. Runner Status by ID:"
for i in {01..09}; do
    if ps aux | grep "actions-runner-$i" | grep "Runner.Listener" | grep -v grep > /dev/null; then
        echo "   Runner $i: ✅ ACTIVE"
    else
        echo "   Runner $i: ❌ INACTIVE"
    fi
done

echo
echo "3. Recent Runner Logs (last 2 lines):"
for i in {01..03}; do
    echo "   Runner $i:"
    tail -2 actions-runner-$i/runner.log 2>/dev/null | sed 's/^/     /' || echo "     No log"
done

echo
echo "4. Session Conflicts Check:"
CONFLICTS=$(find actions-runner-*/_diag -name "Runner_*.log" -mtime -1 -exec grep -l "SessionConflictException" {} \; 2>/dev/null | wc -l)
if [ $CONFLICTS -eq 0 ]; then
    echo "   ✅ No recent session conflicts"
else
    echo "   ⚠️  $CONFLICTS runners had session conflicts"
fi

echo
echo "5. Virtual Environment Status:"
if [ -d ".runner-venv-01" ]; then
    echo "   ✅ Runner-specific venvs exist"
else
    echo "   ⚠️  Check virtual environment setup"
fi

echo
echo "=== Summary ==="
if [ $RUNNER_COUNT -ge 9 ]; then
    echo "✅ All systems operational - $RUNNER_COUNT runners active"
else
    echo "⚠️  Only $RUNNER_COUNT runners active - expected 9+"
fi
