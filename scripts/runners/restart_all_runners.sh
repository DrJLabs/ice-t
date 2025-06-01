#!/bin/bash

echo "=== Stopping all runners to resolve session conflicts ==="
pkill -f "Runner.Listener" 2>/dev/null || true
pkill -f "runsvc.sh" 2>/dev/null || true
sleep 5

echo "=== Verifying all runners are stopped ==="
if pgrep -f "Runner.Listener" > /dev/null; then
    echo "Force killing remaining runners..."
    pkill -9 -f "Runner.Listener"
    sleep 2
fi

echo "=== Starting project runners 01-09 ==="
cd /home/drj/codex-t

for i in {01..09}; do
    echo "Starting runner $i..."
    cd actions-runner-$i
    nohup ./run.sh > runner.log 2>&1 &
    sleep 2
    cd ..
done

echo "=== Waiting for runners to initialize ==="
sleep 10

echo "=== Checking runner status ==="
ps aux | grep "Runner.Listener" | grep -v grep | wc -l
echo "Active runners count above"

echo "=== Checking runner logs for errors ==="
for i in {01..09}; do
    echo "Runner $i status:"
    tail -3 actions-runner-$i/runner.log 2>/dev/null || echo "No log yet"
    echo
done
