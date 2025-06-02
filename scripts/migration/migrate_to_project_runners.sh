#!/bin/bash

# Migration Script: Create Clean Project-Specific Runners for Codex-T
# This script creates fresh runners in the project directory while leaving global ones intact

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/home/drj/codex-t"
RUNNER_VERSION="2.320.0"

echo -e "${GREEN}🚀 Codex-T Project Runner Migration${NC}"
echo -e "${YELLOW}Setting up clean, project-specific runners${NC}"
echo

# Function to check existing global runners
check_global_runners() {
    echo -e "${BLUE}📊 Current Global Runner Status:${NC}"
    echo

    for i in {1..6}; do
        local runner_dir="/home/drj/actions-runner"
        if [ $i -gt 1 ]; then
            runner_dir="/home/drj/actions-runner-0$i"
        fi

        if [ -d "$runner_dir" ]; then
            local size=$(du -sh "$runner_dir" 2>/dev/null | cut -f1)
            local status="❌ Offline"

            # Check if runner is active
            if pgrep -f "$runner_dir/run.sh" >/dev/null 2>&1; then
                status="🚀 Running"
            elif [ -f "$runner_dir/.runner" ]; then
                status="✅ Configured"
            fi

            printf "%-20s %-15s %s\n" "Global Runner $i" "$status" "[$size]"
        else
            printf "%-20s %-15s %s\n" "Global Runner $i" "❌ Not found" "[N/A]"
        fi
    done
    echo
}

# Function to setup project-specific runner
setup_project_runner() {
    local runner_num=$1
    local runner_name="codex-runner-$(printf "%02d" $runner_num)"
    local runner_dir="$PROJECT_DIR/actions-runner-$(printf "%02d" $runner_num)"
    local labels=$2

    echo -e "${BLUE}Setting up $runner_name...${NC}"

    # Create runner directory
    mkdir -p "$runner_dir"
    cd "$runner_dir"

    # Download and extract runner if needed
    if [ ! -f "run.sh" ]; then
        echo "  - Downloading GitHub Actions Runner v${RUNNER_VERSION}..."
        curl -s -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
            "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

        echo "  - Extracting runner..."
        tar xzf "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
        rm "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
    fi

    # Create configuration script that will be run interactively
    cat > "$runner_dir/configure_runner.sh" << EOF
#!/bin/bash
echo "Configuring $runner_name with labels: $labels"
echo "When prompted:"
echo "  - Server URL: [Your repository URL]"
echo "  - Registration token: [Token from GitHub]"
echo "  - Runner name: $runner_name"
echo "  - Labels: $labels"
echo "  - Work folder: _work (default)"
echo ""
./config.sh --labels "$labels" --name "$runner_name"
EOF
    chmod +x "$runner_dir/configure_runner.sh"

    # Create start script with environment activation
    cat > "$runner_dir/start_runner.sh" << EOF
#!/bin/bash
cd "\$(dirname "\$0")"

# Activate Python virtual environment
if [ -f "$PROJECT_DIR/.runner-venv/bin/activate" ]; then
    source "$PROJECT_DIR/.runner-venv/bin/activate"
    echo "✅ Python environment activated for $runner_name"
fi

echo "Starting $runner_name..."
echo "Press Ctrl+C to stop"
./run.sh
EOF
    chmod +x "$runner_dir/start_runner.sh"

    # Create workspace cleanup script (addresses GitHub discussion issues)
    cat > "$runner_dir/cleanup_workspace.sh" << EOF
#!/bin/bash
# Workspace cleanup script addressing file ownership issues
# Based on: https://github.com/orgs/community/discussions/51329

set -e

WORK_DIR="\$(dirname "\$0")/_work"

if [ -d "\$WORK_DIR" ]; then
    echo "Cleaning workspace: \$WORK_DIR"

    # Handle potential root-owned files from container jobs
    if [ -w "\$WORK_DIR" ]; then
        rm -rf "\$WORK_DIR"/* 2>/dev/null || true
        rm -rf "\$WORK_DIR"/.[!.]* 2>/dev/null || true
    else
        echo "Warning: Workspace not writable, may need manual cleanup"
        ls -la "\$WORK_DIR"
    fi

    echo "Workspace cleaned successfully"
else
    echo "No workspace directory found"
fi
EOF
    chmod +x "$runner_dir/cleanup_workspace.sh"

    # Create systemd user service
    mkdir -p "$HOME/.config/systemd/user"
    cat > "$HOME/.config/systemd/user/codex-$runner_name.service" << EOF
[Unit]
Description=Codex-T GitHub Actions Runner ($runner_name)
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$runner_dir
ExecStart=$runner_dir/run.sh
ExecStartPre=$runner_dir/cleanup_workspace.sh
Restart=always
RestartSec=5
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=5min

[Install]
WantedBy=default.target
EOF

    echo -e "${GREEN}✅ $runner_name setup complete!${NC}"
    echo "  📁 Location: $runner_dir"
    echo "  🔧 Configure: cd $runner_dir && ./configure_runner.sh"
    echo "  🚀 Start: cd $runner_dir && ./start_runner.sh"
    echo "  🧹 Clean: cd $runner_dir && ./cleanup_workspace.sh"
    echo
}

# Function to install Python tools in a virtual environment
setup_python_tools() {
    echo -e "${YELLOW}Setting up Python virtual environment for runners...${NC}"

    local venv_dir="$PROJECT_DIR/.runner-venv"

    # Create virtual environment if it doesn't exist
    if [ ! -d "$venv_dir" ]; then
        echo "  - Creating virtual environment..."
        python3 -m venv "$venv_dir"
    fi

    # Activate virtual environment
    source "$venv_dir/bin/activate"

    # Upgrade pip in venv
    pip install --upgrade pip

    # Install our project dependencies in venv
    echo "  - Installing Python tools in virtual environment..."
    pip install \
        pytest>=8.3.0 \
        pytest-cov>=6.0.0 \
        pytest-xdist>=3.6.0 \
        pytest-mock>=3.14.0 \
        black>=24.4.2 \
        ruff>=0.11.11 \
        mypy>=1.15.0 \
        pre-commit>=4.0 \
        rich>=13.7.1 \
        click>=8.1.6 \
        pydantic>=2.7.4 \
        hypothesis>=6.131.27 \
        bandit[toml]>=1.7.5 \
        safety>=3.2.0 \
        semgrep \
        types-jsonschema \
        coverage

    # Create activation script for runners
    cat > "$PROJECT_DIR/activate_runner_env.sh" << EOF
#!/bin/bash
# Activate the Python environment for runners
source "$venv_dir/bin/activate"
echo "✅ Runner Python environment activated"
echo "Available tools: \$(which pytest) \$(which black) \$(which ruff) \$(which mypy)"
EOF
    chmod +x "$PROJECT_DIR/activate_runner_env.sh"

    # Deactivate for now
    deactivate

    echo -e "${GREEN}✅ Python virtual environment created at: $venv_dir${NC}"
    echo -e "${BLUE}To activate: source $venv_dir/bin/activate${NC}"
}

# Main setup function
main() {
    echo -e "${YELLOW}This script will create 6 new project-specific runners for codex-t${NC}"
    echo -e "${YELLOW}Your existing global runners will remain untouched${NC}"
    echo

    # Check current state
    check_global_runners

    # Confirm action
    read -p "Continue with project-specific runner setup? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Setup cancelled"
        exit 0
    fi

    # Setup Python environment
    setup_python_tools

    # Create project runners with specialized labels
    echo -e "${BLUE}Creating project-specific runners...${NC}"
    echo

    setup_project_runner 1 "self-hosted,linux,fast-setup,test-runner"
    setup_project_runner 2 "self-hosted,linux,test-runner,coverage-tools"
    setup_project_runner 3 "self-hosted,linux,pre-commit-ready"
    setup_project_runner 4 "self-hosted,linux,python-dev"
    setup_project_runner 5 "self-hosted,linux,security-tools,docs-tools"
    setup_project_runner 6 "self-hosted,linux,integration-env,full-env"

    echo -e "${GREEN}🎉 Project runner setup complete!${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Get registration tokens from GitHub:"
    echo "   Repository → Settings → Actions → Runners → New self-hosted runner"
    echo
    echo "2. Configure each runner:"
    echo "   cd $PROJECT_DIR/actions-runner-01"
    echo "   ./configure_runner.sh"
    echo
    echo "3. Start runners:"
    echo "   ./start_runner.sh                    # Manual start"
    echo "   # OR"
    echo "   systemctl --user enable codex-codex-runner-01.service"
    echo "   systemctl --user start codex-codex-runner-01.service"
    echo
    echo -e "${YELLOW}Note: Global runners remain active and unchanged${NC}"
}

# Validate environment
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Project directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

if [ "$(pwd)" != "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Changing to project directory: $PROJECT_DIR${NC}"
    cd "$PROJECT_DIR"
fi

main "$@"
