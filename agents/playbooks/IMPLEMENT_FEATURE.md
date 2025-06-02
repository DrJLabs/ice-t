# Playbook: Implement Feature

This playbook outlines the steps the AI should follow when implementing a new feature.

1. **Clarify requirements** if any part of the specification is unclear.
2. **Identify affected modules** or create new ones following the structure in `src/ice_t/`.
3. **Write domain logic and DTOs** for the feature.
4. **Implement service layer** connecting the domain to interfaces.
5. **Write unit and integration tests** using `adaptive_test_runner.py`.
6. **Update documentation** such as README or module docstrings.
7. **Run linters and type checkers** before committing.

Use the tools outlined in `agents/conventions/TOOL_USAGE.md` to edit files and run commands.
