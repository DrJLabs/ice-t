#!/bin/bash

echo "Starting remaining runners 04-09"

echo "Starting runner 04"
cd /home/drj/codex-t/actions-runner-04
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Starting runner 05"
cd /home/drj/codex-t/actions-runner-05
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Starting runner 06"
cd /home/drj/codex-t/actions-runner-06
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Starting runner 07"
cd /home/drj/codex-t/actions-runner-07
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Starting runner 08"
cd /home/drj/codex-t/actions-runner-08
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "Starting runner 09"
cd /home/drj/codex-t/actions-runner-09
nohup ./run.sh > runner.log 2>&1 &
sleep 2

echo "All runners started"
cd /home/drj/codex-t
