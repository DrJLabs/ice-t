#!/bin/bash
set -e

python3 -m pip install --quiet --upgrade pip --break-system-packages

python3 -m pip install --quiet --break-system-packages \
    pytest==8.3.4 \
    rich==13.9.4 \
    pydantic==2.10.3 \
    ruff==0.8.4 \
    mypy==1.13.0 \
    pytest-cov==6.0.0 \
    pytest-xdist==3.7.0 \
    requests==2.32.3 \
    httpx==0.28.1 \
    fastapi==0.115.6 \
    click==8.1.7 \
    coverage==7.6.9 \
    bandit==1.8.0 \
    hypothesis==6.122.1
