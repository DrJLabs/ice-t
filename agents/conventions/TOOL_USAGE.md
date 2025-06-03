# Tool Usage

The AI uses the following tools during development:

- **edit_file** – apply code or documentation changes.
- **run_terminal_cmd** – run commands such as tests or linters.
- **adaptive_test_runner.py** – execute relevant tests after changes.

Use `run_terminal_cmd` for installation or formatting commands. After modifying code, always run the adaptive test runner to verify correctness before creating a pull request.
Consult the modernization checklist to align tooling commands with current priorities.

`tests/groups.json` defines the test groups used by the adaptive runner and CI.
Edit this file whenever you add or remove a group. Each entry must contain:

- `name` – the identifier used in the runner and workflow matrix.
- `path` – relative path to the test directory.
- `coverage` – whether coverage reports are required for the group.
