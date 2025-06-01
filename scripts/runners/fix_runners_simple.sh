#!/bin/bash

# Simple runner fix script - avoid complex commands
echo "Step 1: Stop all runners"
pkill -f "Runner.Listener"
sleep 3

echo "Step 2: Verify stopped"
pgrep -f "Runner.Listener" || echo "All stopped"

echo "Step 3: Start runner 01"
cd /home/drj/codex-t/actions-runner-01
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Step 4: Start runner 02"
cd /home/drj/codex-t/actions-runner-02
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Step 5: Start runner 03"
cd /home/drj/codex-t/actions-runner-03
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Done with first 3 runners"
cd /home/drj/codex-t
