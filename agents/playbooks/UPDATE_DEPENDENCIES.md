# Playbook: Update Dependencies

This playbook outlines the steps the AI should follow when updating project dependencies.

1. **Clarify the reason** for the update and check compatibility notes.
2. **Modify requirement files** or `pyproject.toml` with the new versions.
3. **Install or compile** the updated dependencies using `run_terminal_cmd`.
4. **Add or adjust tests** to cover changes introduced by the update.
5. **Run the adaptive test runner** to verify the project still functions correctly.
6. **Update documentation** including changelogs or setup instructions.
7. **Run linters and type checkers** before committing.

Use the tools described in `agents/conventions/TOOL_USAGE.md` to modify files and execute commands.
