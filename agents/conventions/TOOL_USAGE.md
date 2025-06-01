# 🛠️ AI Agent Tool Usage Guide for ice-t

This document provides specific instructions for AI agents (Cursor, Codex, etc.) on how to effectively use the available tools within the `ice-t` project environment.

## 📋 Core Tool Categories

### 1. Code Editing Tools

#### `edit_file` - Primary Code Modification Tool
**Purpose:** Your primary tool for making changes to existing files or creating new files.

**Best Practices:**
- **Target File:** Always provide full relative path from project root (e.g., `src/ice_t/features/my_feature/service.py`)
- **Instructions:** Clear, first-person description of the change (e.g., "I am adding validation logic to the User service")
- **Context Management:** Provide 3-5 lines of context before/after changes
- **Unchanged Code:** Use `# ... existing code ...` (Python) or appropriate language comments

**Example Structure:**
```python
# ... existing code ...
class UserService:
    def existing_method(self):
        # ... existing code ...
        pass

    def new_validation_method(self, user_data: UserDTO) -> bool:
        """Validate user data according to business rules."""
        return user_data.email and "@" in user_data.email
# ... existing code ...
```

#### `search_replace` - Precise Text Replacement
**Purpose:** For exact text replacements in large files (>2500 lines).

**Requirements:**
- **Uniqueness:** Include 3-5 lines of context before and after
- **Exactness:** Match whitespace, indentation, and surrounding code exactly
- **Single Instance:** Only changes one occurrence per call

### 2. File System Navigation

#### `list_dir` - Directory Exploration
**Purpose:** Discover file structure before targeted operations.
**Usage:** Start with this for unfamiliar areas of the codebase

#### `file_search` - Fuzzy File Finding
**Purpose:** Locate files when you know partial names or paths
**Example:** Query `userService` to find user-related service files

#### `read_file` - File Content Examination
**Purpose:** Read file contents with line number ranges
**Best Practice:** Use targeted line ranges to avoid information overload

### 3. Code Discovery Tools

#### `codebase_search` - Semantic Code Search
**Purpose:** Find code snippets using natural language queries
**When to Use:** Understanding existing patterns, finding examples
**Example Queries:**
- "How is user authentication implemented?"
- "Find Pydantic DTO examples"
- "Show error handling patterns"

#### `grep_search` - Exact Pattern Matching
**Purpose:** Find specific symbols, functions, or regex patterns
**When to Use:** Prefer over semantic search for exact matches
**Remember:** Escape special regex characters (`\(`, `\[`, `\]`)

### 4. Development Execution Tools

#### `run_terminal_cmd` - Command Execution
**Purpose:** Execute shell commands for testing, linting, building

**Critical Requirements:**
- **Non-Interactive:** Always use flags like `-y`, `--yes`, `--no-input`
- **Pager Handling:** Append `| cat` for commands that use pagers
- **Working Directory:** Commands run from project root unless specified
- **Background Jobs:** Set `is_background: true` for long-running processes

**Common Commands:**
```bash
# Run tests
python -m pytest tests/ -v

# Run linting suite
ruff check . && mypy src/ tests/

# Run adaptive test runner
python scripts/testing/adaptive_test_runner.py --changed-files src/modified_file.py
```

## 🧪 Testing Integration

### `adaptive_test_runner.py` - Intelligent Test Execution
**Purpose:** Preferred method for AI-driven test execution

**Key Features:**
- **Smart Selection:** Runs tests related to changed files
- **Self-Healing:** Automatically fixes common issues
- **Learning:** Logs outcomes for continuous improvement

**Usage Patterns:**
```bash
# Test specific changes
python scripts/testing/adaptive_test_runner.py --changed-files src/ice_t/features/user/service.py

# Run fast test suite
python scripts/testing/adaptive_test_runner.py --fast

# Full test run with healing
python scripts/testing/adaptive_test_runner.py --all --heal
```

## 🔄 Workflow Integration

### Branch Management
1. **Always** create new branch: `git checkout -b cursor/feature-description`
2. **Commit frequently** with descriptive messages
3. **Push with upstream**: `git push -u origin cursor/branch-name`

### Quality Assurance Sequence
1. **Code Changes:** Use `edit_file` for modifications
2. **Test Execution:** Use `adaptive_test_runner.py`
3. **Linting:** Run `ruff check . && mypy src/`
4. **Integration Check:** Verify tests pass in CI environment

### Task Tracking Integration
- **Before Work:** Check `.cursor/rules/009-task-tracking-modernization.mdc`
- **During Work:** Update task status (🔄 In Progress, ✅ Completed)
- **After Work:** Document learnings and update related tasks

## 🏗️ Architecture-Specific Patterns

### Vertical Slice Development
When implementing features:
1. **Domain Layer:** Create business logic in `domain/`
2. **Service Layer:** Implement in `service/`
3. **DTO Layer:** Define data contracts in `dto/`
4. **Tests:** Create comprehensive test coverage

### File Organization
```
src/ice_t/features/[feature]/
├── domain/          # Business logic
├── service/         # Application services
├── dto/            # Data transfer objects
└── __init__.py     # Feature exports
```

## 🚨 Error Handling & Recovery

### Common Scenarios
- **Import Errors:** Use `adaptive_test_runner.py` healing capabilities
- **Linting Failures:** Address `ruff` and `mypy` issues immediately
- **Test Failures:** Analyze output, fix issues, re-run tests
- **Merge Conflicts:** Use systematic resolution approach

### When to Ask for Help
- Complex architectural decisions
- Unclear requirements or specifications
- System-level configuration changes
- External service integration issues

## 📊 Performance Considerations

### Parallel Tool Usage
- **Read Operations:** Run multiple `read_file`, `grep_search`, `codebase_search` in parallel
- **Independent Edits:** Edit multiple unrelated files simultaneously
- **Test Execution:** Leverage `pytest-xdist` for parallel test runs

### Efficiency Tips
- Use semantic search before diving into specific files
- Leverage adaptive test runner for smart test selection
- Batch related changes in single `edit_file` calls
- Use appropriate tool for the task (semantic vs exact search)

## 🔄 Continuous Improvement

This tool usage guide evolves based on:
- AI agent performance metrics
- Development workflow efficiency
- Project modernization progress
- Community best practices

**Remember:** These tools are designed to work together. Use them in combination to achieve complex development tasks efficiently and maintain high code quality.
