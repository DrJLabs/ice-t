# Playbook: Fix Bug

This playbook outlines the steps the AI should follow when resolving a defect.

1. **Clarify the issue** and confirm the expected behavior.
2. **Add or update tests** that reproduce the bug in `tests/`.
3. **Apply the fix** in the relevant module under `src/ice_t/`.
4. **Run the adaptive test runner** to ensure the fix works and no regressions occur.
5. **Update documentation** or changelog entries if needed.
6. **Run linters and type checkers** before committing.

Use the tools described in `agents/conventions/TOOL_USAGE.md` to modify files and execute commands.
