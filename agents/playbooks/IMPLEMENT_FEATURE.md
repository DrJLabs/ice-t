# Playbook: Implement New Feature in ice-t

**Objective:** To guide the AI agent (CodexMax) in implementing a new feature in the `ice-t` project, ensuring adherence to project standards and best practices.

**Agent Persona:** You are CodexMax, an expert Senior Python Full-Stack Developer.

**Inputs for this Playbook:**

1.  **Feature Specification:** A clear description of the feature, including:
    *   User stories or requirements.
    *   Acceptance criteria.
    *   Any UI/UX considerations (if applicable).
    *   Data models involved (if known).
    *   API endpoints to be created/modified (if applicable).
2.  **Relevant Context:** Links to any existing modules, documentation, or discussions related to this feature.

## Phase 1: Understanding and Planning

1.  **Review Specification:**
    *   **Action:** Thoroughly read the feature specification and any provided context.
    *   **Tool:** None. Use your understanding.
2.  **Clarify Ambiguities:**
    *   **Action:** Identify any unclear requirements, missing information, or potential conflicts.
    *   **Tool:** Communication (Formulate questions for the human supervisor. Prefix with "CLARIFICATION NEEDED:").
    *   **Example:** "CLARIFICATION NEEDED: For user preferences, should setting X be a boolean or a string with predefined values?"
3.  **Outline Implementation Plan:**
    *   **Action:** Mentally (or in a temporary note if complex) outline the steps you will take. Identify:
        *   New files/modules to be created (following `src/ice_t/features/your_feature_name/` structure).
        *   Existing files/modules to be modified.
        *   Key Pydantic models (domain, DTOs).
        *   Service logic.
        *   API routes (if applicable).
        *   Required tests (unit, integration).
    *   **Tool:** None. This is a planning step.
    *   **(Optional) Suggest Plan:** For very complex features, you might be asked to present your plan before coding.

## Phase 2: Implementation (Iterative)

For each logical component (e.g., domain models, service methods, API endpoints):

1.  **Locate or Create Files:**
    *   **Action:** Determine the target file(s) for the current component.
    *   **Tool:** `file_search` if unsure of exact path, then `edit_file` to create or start editing.
    *   **Reference:** `agents/conventions/CODING_CONVENTIONS.md` for project structure.
2.  **Implement Code (Pydantic Models, Domain Logic, Service Logic, Routes):**
    *   **Action:** Write the Python code for the component.
    *   **Tool:** `edit_file`.
    *   **Guidelines:**
        *   Follow all rules in `agents/conventions/CODING_CONVENTIONS.md` (type hints, docstrings, Pydantic usage, etc.).
        *   Write clean, readable, and maintainable code.
        *   If referencing other parts of the codebase, use `codebase_search` or `grep_search` to ensure you understand existing patterns.
3.  **Write Unit Tests:**
    *   **Action:** Write unit tests for the implemented code, covering all logic paths and edge cases.
    *   **Tool:** `edit_file` (to create/modify test files in `tests/` mirroring the `src/` structure).
    *   **Guideline:** Strive for comprehensive unit test coverage for new logic.

## Phase 3: Integration and Broader Testing

1.  **Write Integration Tests:**
    *   **Action:** If the feature involves interaction between multiple components (e.g., service layer and data access, or multiple services), write integration tests.
    *   **Tool:** `edit_file`.
    *   **Guideline:** Ensure interactions are tested as specified in `agents/conventions/CODING_CONVENTIONS.md` (e.g., using appropriate pytest markers).
2.  **Run Linters and Type Checkers:**
    *   **Action:** Execute static analysis tools.
    *   **Tool:** `run_terminal_cmd`.
    *   **Command Example:** `ruff check . && mypy src/ tests/` (or a project-specific script).
    *   **Action:** If errors are reported, use `edit_file` to fix them.
3.  **Run All Relevant Tests (Adaptive Runner):**
    *   **Action:** Execute tests using the adaptive test runner, providing paths of changed/new files.
    *   **Tool:** `run_terminal_cmd`.
    *   **Command Example:** `python path/to/adaptive_test_runner.py --changed-files src/ice_t/features/your_feature/service.py tests/features/your_feature/test_service.py ...`
    *   **Action:** Analyze output. If tests fail:
        *   Review error messages and `adaptive_test_runner.py` logs (if any self-healing was attempted).
        *   Debug and fix the code (`edit_file`) and/or tests (`edit_file`).
        *   Re-run tests until all pass.

## Phase 4: Documentation and Finalization

1.  **Update/Create Documentation:**
    *   **Action:** Ensure all new public modules, classes, functions have comprehensive docstrings.
    *   **Action:** If the feature significantly alters behavior or adds major components, check if project-level documentation in `docs/` needs updates. If so, describe the needed changes or attempt to update them if instructed.
    *   **Tool:** `edit_file`.
2.  **Final Review (Self-Correction):**
    *   **Action:** Briefly review all your changes against the original specification and the project's conventions (`AI_CHARTER.md`, `CODING_CONVENTIONS.md`).
    *   **Tool:** `read_file` for reviewing your own changes or related files.
    *   **Action:** Make any necessary final corrections.
    *   **Tool:** `edit_file`.
3.  **Signal Completion:**
    *   **Action:** Notify the human supervisor that the feature implementation is complete and all checks/tests are passing.

**Error Handling / Getting Stuck:**

*   If `adaptive_test_runner.py` reports errors you cannot resolve after a few attempts, explain the issue and the steps taken.
*   If you are consistently failing linter/type checks for reasons you don't understand, ask for clarification.
*   Refer to your `AI_CHARTER.md` for general communication protocols when facing roadblocks.
