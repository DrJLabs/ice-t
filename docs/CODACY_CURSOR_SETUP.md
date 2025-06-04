# Codacy MCP Server Setup for Cursor

This guide will help you set up Codacy's MCP server with Cursor IDE for enhanced code quality and security analysis.

## Prerequisites

- Node.js and npm installed (with `npx` available)
- Cursor IDE
- A Codacy account (free signup available)

## Step 1: Get Your Codacy API Token

1. Visit [Codacy](https://app.codacy.com) and log in
2. Click your profile avatar (top-right corner)
3. Navigate to **Account > API Tokens**
4. Click **Create API Token**
5. Name it "Cursor MCP" or similar
6. Copy the generated token

## Step 2: Configure MCP in Cursor

1. Open Cursor Settings
2. Go to the **MCP** tab
3. Click **Add new global MCP server**
4. Replace the contents with:

```json
{
  "mcpServers": {
    "codacy": {
      "command": "npx",
      "args": ["-y", "@codacy/codacy-mcp"],
      "env": {
        "CODACY_ACCOUNT_TOKEN": "YOUR_ACTUAL_TOKEN_HERE",
        "CODACY_CLI_VERSION": "latest"
      }
    }
  }
}
```

**Important**: Replace `YOUR_ACTUAL_TOKEN_HERE` with your actual Codacy API token.

## Step 3: Restart Cursor

After saving the configuration, restart Cursor completely for the changes to take effect.

## Step 4: Verify the Setup

1. Open Cursor chat (Cmd/Ctrl + L)
2. Look for the Codacy tools in the MCP section
3. You should see a green dot indicating the server is connected

## Step 5: Test the Connection

Try asking the AI:
- "Show me the security issues in this repository"
- "What's the code quality score for this project?"
- "Run a local analysis on this file"

## Available Codacy MCP Tools

The Codacy MCP server provides access to:

### Repository Management
- `codacy_setup_repository`: Add repository to Codacy
- `codacy_get_repository_with_analysis`: Get repository analysis metrics
- `codacy_list_organization_repositories`: List organization repos

### Code Quality Analysis
- `codacy_list_repository_issues`: List code quality issues
- `codacy_get_file_issues`: Get issues for specific files
- `codacy_cli_analyze`: Run local analysis

### Security Analysis
- `codacy_search_repository_srm_items`: Find security vulnerabilities
- `codacy_search_organization_srm_items`: Organization-wide security scan

### Pull Request Analysis
- `codacy_list_pull_request_issues`: PR-specific issues
- `codacy_get_pull_request_files_coverage`: Coverage analysis

### File Analysis
- `codacy_get_file_with_analysis`: Detailed file metrics
- `codacy_get_file_coverage`: Coverage information
- `codacy_get_file_clones`: Code duplication analysis

## Troubleshooting

### "Unauthorized" Error
- Double-check your API token is correct
- Ensure the token has proper permissions
- Try regenerating the token

### MCP Server Not Starting
- Verify Node.js and npm are installed
- Check that `npx` command works in terminal
- Restart Cursor after configuration changes

### No Tools Showing
- Restart Cursor completely
- Check the MCP configuration format is valid JSON
- Look for error messages in Cursor's developer console

### Connection Issues
- Ensure you have internet connectivity
- Check if corporate firewall blocks npm packages
- Try using the manual installation method

## Alternative Setup (Manual Installation)

If the npx method doesn't work, you can install globally:

```bash
npm install -g @codacy/codacy-mcp
```

Then update your MCP configuration:

```json
{
  "mcpServers": {
    "codacy": {
      "command": "codacy-mcp",
      "env": {
        "CODACY_ACCOUNT_TOKEN": "YOUR_ACTUAL_TOKEN_HERE",
        "CODACY_CLI_VERSION": "latest"
      }
    }
  }
}
```

## Benefits of Using Codacy MCP

- **Real-time Analysis**: Get instant feedback on code quality and security
- **Context-Aware**: AI understands your project's quality metrics
- **Seamless Integration**: No need to switch between tools
- **Automated Fixes**: AI can suggest and apply improvements
- **Security Scanning**: Immediate vulnerability detection
- **Coverage Insights**: Test coverage analysis and recommendations

## Best Practices

1. **Regular Analysis**: Use `codacy_cli_analyze` after making changes
2. **Security First**: Check `codacy_search_repository_srm_items` for vulnerabilities
3. **PR Reviews**: Leverage `codacy_list_pull_request_issues` before merging
4. **Code Quality**: Monitor `codacy_get_repository_with_analysis` metrics
5. **File-Level Insights**: Use `codacy_get_file_with_analysis` for detailed feedback

## Support

If you encounter issues:
- Check [Codacy Documentation](https://docs.codacy.com)
- Visit [Codacy MCP GitHub](https://github.com/codacy/codacy-mcp-server)
- Contact Codacy support at support@codacy.com
