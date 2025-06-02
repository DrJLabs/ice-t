# CI Logging and Metrics System

## Overview

The ice-t project includes a comprehensive automated CI logging and metrics collection system designed to enable rapid debugging and AI-driven failure analysis. This system automatically captures detailed information about CI runs and makes it immediately available for analysis.

## Architecture

### Components

1. **Failure Log Capture**: `save-failed-log.yml` workflow
2. **Performance Metrics**: `collect-ci-metrics.yml` workflow
3. **Storage Directories**: `.codex/logs/` and `.codex/metrics/`
4. **AI Integration**: Documented commands and procedures for automated analysis

### Workflow Triggers

Both workflows trigger on completion of the main CI workflow ("🚀 Turbo CI - ice-t Persistent Runners"):

- **save-failed-log.yml**: Only runs when CI fails
- **collect-ci-metrics.yml**: Runs on all CI completions (success or failure)

## Data Storage

### Failure Logs
- **Location**: `.codex/logs/ci_[run_id].log`
- **Format**: Complete CI log output including all steps and error details
- **Retention**: Logs are committed to repository for persistent access
- **Access**: Available to any AI agent with repository access

### Performance Metrics
- **Location**: `.codex/metrics/ci-metrics.jsonl`
- **Format**: One JSON object per line with run performance data
- **Fields**:
  - `run_id`: GitHub Actions run ID
  - `conclusion`: success/failure status
  - `duration_ms`: Total run duration in milliseconds
  - `queued_ms`: Time spent queued before execution
  - `actor`: User who triggered the run
  - `head_sha`: Commit SHA that was tested
  - `finished_at`: ISO timestamp of completion

## AI Agent Integration

### Quick Access Commands

```bash
# List recent failure logs
ls -la .codex/logs/ci_*.log | tail -5

# View latest failure log
cat $(ls -t .codex/logs/ci_*.log | head -1)

# Search for specific errors across all logs
grep -r "ERROR\|FAILED\|error:" .codex/logs/

# View recent performance metrics
tail -5 .codex/metrics/ci-metrics.jsonl | jq .

# Find runs by specific actor
grep '"actor":"username"' .codex/metrics/ci-metrics.jsonl
```

### Analysis Workflow for AI Agents

1. **Check for New Failures**: Monitor for new log files in `.codex/logs/`
2. **Extract Error Details**: Parse log files for specific error messages and stack traces
3. **Identify Patterns**: Use metrics data to identify performance trends or recurring issues
4. **Formulate Repairs**: Based on error analysis, develop targeted fixes
5. **Verify Solutions**: Use historical data to validate proposed solutions

## Technical Implementation

### Authentication
- Both workflows use `GH_TOKEN: ${{ github.token }}` for GitHub CLI authentication
- Tokens are automatically provided by GitHub Actions

### Directory Creation
- Workflows ensure `.codex/logs/` and `.codex/metrics/` directories exist using `mkdir -p`
- Directories are created fresh in each runner environment

### Commit Bypass
- All automated commits use `--no-verify` to bypass pre-commit hooks
- Commits are made by `ice-t-bot` user to distinguish from human commits
- No pull request or approval process is required for log commits

### Error Handling
- Workflows use `set -euo pipefail` for robust error handling
- Any failures in log collection are visible in the workflow run logs

## Monitoring and Maintenance

### Health Checks
- Monitor for successful execution of both workflows
- Verify log files are being created and committed
- Check for any authentication or permission issues

### Data Management
- Logs accumulate over time and may require periodic cleanup
- Consider implementing retention policies for very old logs
- Monitor repository size impact of accumulated log data

## Security Considerations

- Log files may contain sensitive information from CI runs
- Access is controlled by repository permissions
- Automated commits bypass security scanning intentionally for immediate availability
- Review logs before sharing repository access to ensure no secrets are exposed

## Troubleshooting

### Common Issues

1. **No logs generated**:
   - Check if CI workflow name matches exactly: "🚀 Turbo CI - ice-t Persistent Runners"
   - Verify GitHub token permissions
   - Check workflow run logs for authentication errors

2. **Directory not found errors**:
   - Ensure `mkdir -p` commands are present in workflows
   - Check for permission issues in runner environment

3. **Commit failures**:
   - Verify git configuration is correct
   - Check for branch protection rules that might block automated commits
   - Ensure `--no-verify` flag is used to bypass pre-commit hooks

### Debug Commands

```bash
# Check if workflows exist and are properly configured
ls -la .github/workflows/save-failed-log.yml .github/workflows/collect-ci-metrics.yml

# Verify directory structure
ls -la .codex/

# Check recent automated commits
git log --oneline --author="ice-t-bot" -10
```

## Future Enhancements

- **Log Analysis Tools**: Automated parsing and analysis scripts
- **Alerting**: Integration with notification systems for critical failures
- **Visualization**: Dashboards for CI performance trends
- **Machine Learning**: Pattern recognition for common failure types
- **Integration**: Hooks into AI repair systems for automated fixes
