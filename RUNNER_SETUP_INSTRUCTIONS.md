# ice-t GitHub Actions Runners Setup

## Current Status
✅ 6 runner directories prepared with GitHub Actions runner binaries
✅ All runners have necessary files (config.sh, run.sh, bin/, etc.)

## Runner Configuration

### Labels for each runner:
- Runner 1: ice-t,build,setup
- Runner 2: ice-t,test,smoke  
- Runner 3: ice-t,test,unit
- Runner 4: ice-t,test,integration
- Runner 5: ice-t,quality,security
- Runner 6: ice-t,test,api

### Next Steps:

1. **Get registration tokens from GitHub:**
   Go to: https://github.com/DrJLabs/ice-t/settings/actions/runners/new
   
2. **For each runner (1-6), click "New self-hosted runner"**
   - Select "Linux" 
   - Copy the registration token
   
3. **Configure each runner manually:**

```bash
# Runner 1
cd ice-t-runner-1
./config.sh --url https://github.com/DrJLabs/ice-t --token YOUR_TOKEN_1 --name ice-t-runner-1 --labels ice-t,build,setup --work _work --replace --unattended --runasservice

# Runner 2  
cd ../ice-t-runner-2
./config.sh --url https://github.com/DrJLabs/ice-t --token YOUR_TOKEN_2 --name ice-t-runner-2 --labels ice-t,test,smoke --work _work --replace --unattended --runasservice

# Runner 3
cd ../ice-t-runner-3
./config.sh --url https://github.com/DrJLabs/ice-t --token YOUR_TOKEN_3 --name ice-t-runner-3 --labels ice-t,test,unit --work _work --replace --unattended --runasservice

# Runner 4
cd ../ice-t-runner-4
./config.sh --url https://github.com/DrJLabs/ice-t --token YOUR_TOKEN_4 --name ice-t-runner-4 --labels ice-t,test,integration --work _work --replace --unattended --runasservice

# Runner 5
cd ../ice-t-runner-5
./config.sh --url https://github.com/DrJLabs/ice-t --token YOUR_TOKEN_5 --name ice-t-runner-5 --labels ice-t,quality,security --work _work --replace --unattended --runasservice

# Runner 6
cd ../ice-t-runner-6
./config.sh --url https://github.com/DrJLabs/ice-t --token YOUR_TOKEN_6 --name ice-t-runner-6 --labels ice-t,test,api --work _work --replace --unattended --runasservice
```

4. **Install and start services:**

```bash
# For each runner, install as service
cd ice-t-runner-1 && sudo ./svc.sh install && sudo ./svc.sh start
cd ../ice-t-runner-2 && sudo ./svc.sh install && sudo ./svc.sh start  
cd ../ice-t-runner-3 && sudo ./svc.sh install && sudo ./svc.sh start
cd ../ice-t-runner-4 && sudo ./svc.sh install && sudo ./svc.sh start
cd ../ice-t-runner-5 && sudo ./svc.sh install && sudo ./svc.sh start
cd ../ice-t-runner-6 && sudo ./svc.sh install && sudo ./svc.sh start
```

5. **Verify runners are active:**
```bash
sudo systemctl status actions.runner.*
```

## Quick Setup Commands

After getting all 6 tokens, you can configure all runners quickly:

```bash
# Set your tokens as variables
TOKEN_1="YOUR_ACTUAL_TOKEN_1"
TOKEN_2="YOUR_ACTUAL_TOKEN_2"  
TOKEN_3="YOUR_ACTUAL_TOKEN_3"
TOKEN_4="YOUR_ACTUAL_TOKEN_4"
TOKEN_5="YOUR_ACTUAL_TOKEN_5"
TOKEN_6="YOUR_ACTUAL_TOKEN_6"

# Configure all runners in sequence
cd ice-t-runner-1 && ./config.sh --url https://github.com/DrJLabs/ice-t --token $TOKEN_1 --name ice-t-runner-1 --labels ice-t,build,setup --work _work --replace --unattended --runasservice && cd ..
cd ice-t-runner-2 && ./config.sh --url https://github.com/DrJLabs/ice-t --token $TOKEN_2 --name ice-t-runner-2 --labels ice-t,test,smoke --work _work --replace --unattended --runasservice && cd ..
cd ice-t-runner-3 && ./config.sh --url https://github.com/DrJLabs/ice-t --token $TOKEN_3 --name ice-t-runner-3 --labels ice-t,test,unit --work _work --replace --unattended --runasservice && cd ..
cd ice-t-runner-4 && ./config.sh --url https://github.com/DrJLabs/ice-t --token $TOKEN_4 --name ice-t-runner-4 --labels ice-t,test,integration --work _work --replace --unattended --runasservice && cd ..
cd ice-t-runner-5 && ./config.sh --url https://github.com/DrJLabs/ice-t --token $TOKEN_5 --name ice-t-runner-5 --labels ice-t,quality,security --work _work --replace --unattended --runasservice && cd ..
cd ice-t-runner-6 && ./config.sh --url https://github.com/DrJLabs/ice-t --token $TOKEN_6 --name ice-t-runner-6 --labels ice-t,test,api --work _work --replace --unattended --runasservice && cd ..

# Install all services
for i in {1..6}; do cd ice-t-runner-$i && sudo ./svc.sh install && sudo ./svc.sh start && cd ..; done
```

## Expected Workflow Labels Usage

The runners are configured to match the turbo CI workflow:

- `ice-t,build,setup` - Building and setup tasks
- `ice-t,test,smoke` - Quick smoke tests  
- `ice-t,test,unit` - Unit test execution
- `ice-t,test,integration` - Integration test execution
- `ice-t,quality,security` - Code quality and security scans
- `ice-t,test,api` - API and end-to-end tests

This provides 6-way parallel execution as designed for the ice-t project.

## Troubleshooting Offline Runners

If a runner shows as **offline**:

1. Check the runner service status:
   ```bash
   sudo systemctl status actions.runner.*
