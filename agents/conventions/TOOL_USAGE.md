# Tool Usage

The AI uses the following tools during development:

- **edit_file** – apply code or documentation changes.
- **run_terminal_cmd** – run commands such as tests or linters.
- **adaptive_test_runner.py** – execute relevant tests after changes.

Use `run_terminal_cmd` for installation or formatting commands. After modifying code, always run the adaptive test runner to verify correctness before creating a pull request.
