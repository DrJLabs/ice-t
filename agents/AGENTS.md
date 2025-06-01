# 🤖 AI Agent Guide for ice-t

## 📋 Overview

This directory contains structured guidance for AI agents (Cursor AI, Codex, etc.) working within the ice-t codebase. The goal is to provide clear, actionable instructions that enable autonomous, high-quality development.

## 🏗️ Directory Structure

```
agents/
├── AGENTS.md                    # This file - main entry point
├── charter/                     # High-level mission and persona
│   └── AI_CHARTER.md           # Core principles and ethical guidelines
├── conventions/                 # Standards and patterns
│   ├── CODING_CONVENTIONS.md   # Code standards and architecture
│   └── TOOL_USAGE.md          # How to use development tools
└── playbooks/                  # Task-specific guides
    └── IMPLEMENT_FEATURE.md    # Feature development template
```

## 🎯 Quick Start for AI Agents

### 1. First Time Setup
1. **Read the Charter**: Start with `charter/AI_CHARTER.md` to understand your role and principles
2. **Review Conventions**: Study `conventions/CODING_CONVENTIONS.md` for code standards
3. **Learn Tools**: Read `conventions/TOOL_USAGE.md` for tool usage patterns
4. **Follow Playbooks**: Use `playbooks/IMPLEMENT_FEATURE.md` for structured development

### 2. Before Any Work
- **Always** create a new branch with `cursor/` prefix (see mandatory workflow rule)
- Review relevant task tracking in `.cursor/rules/009-task-tracking-modernization.mdc`
- Run tests with `scripts/testing/adaptive_test_runner.py` to understand current state

### 3. Development Workflow
1. **Clarify Requirements**: Ask questions if specifications are unclear
2. **Follow Architecture**: Use vertical slice pattern (`domain/`, `service/`, `dto/`)
3. **Write Tests First**: Use TDD approach with comprehensive test coverage
4. **Run Quality Checks**: Use `ruff`, `mypy`, `black`, and other linters
5. **Test Integration**: Use `adaptive_test_runner.py` for smart test execution

## 📚 Core Documents

### 🎭 Charter & Mission
- **Purpose**: Defines AI persona as "Senior Python Full-Stack Developer"
- **Principles**: Clarity, testability, security, maintainability
- **Communication**: How to ask for clarification and report issues
- **File**: `charter/AI_CHARTER.md`

### 🏛️ Conventions & Standards
- **Coding Standards**: Non-negotiable code quality rules
- **Architecture**: Vertical slice pattern, DTO usage, API design
- **Dependencies**: Preferred libraries and usage patterns
- **File**: `conventions/CODING_CONVENTIONS.md`

### 🛠️ Tool Usage
- **Test Runner**: How to use `adaptive_test_runner.py`
- **Linters**: `ruff`, `mypy`, `black`, `isort` integration
- **CI/CD**: Understanding GitHub Actions workflows
- **File**: `conventions/TOOL_USAGE.md`

### 📖 Playbooks
- **Feature Implementation**: Step-by-step development process
- **Bug Fixes**: Systematic debugging and testing approach
- **Refactoring**: Safe code improvement practices
- **Files**: `playbooks/*.md`

## 🚀 Project Context

### Technology Stack
- **Language**: Python 3.12
- **Framework**: FastAPI (for web APIs)
- **Testing**: pytest with comprehensive markers
- **Type Checking**: mypy with strict settings
- **Linting**: ruff for code quality
- **CI/CD**: GitHub Actions with self-hosted runners

### Architecture Principles
- **Vertical Slices**: Features organized by domain, not technical layer
- **DTO Pattern**: Data Transfer Objects for API boundaries
- **Dependency Injection**: Clean separation of concerns
- **Test Coverage**: >94% coverage requirement
- **Type Safety**: Full type hints and mypy compliance

## 📋 Task Tracking Integration

This project uses systematic task tracking for modernization efforts. Before starting work:

1. **Check Rule 009**: Review `.cursor/rules/009-task-tracking-modernization.mdc`
2. **Update Status**: Mark tasks as in progress (🔄) or completed (✅)
3. **Document Progress**: Update task descriptions with findings
4. **Verify Completion**: Ensure all subtasks are finished before marking complete

## 🔗 Related Resources

- **Main Documentation**: `docs/` directory
- **Development Scripts**: `scripts/` directory
- **Testing Framework**: `tests/` directory with organized structure
- **CI Configuration**: `.github/workflows/`
- **Quality Tools**: `pyproject.toml` configuration

## 🎪 Agent-Specific Notes

### For Cursor AI
- Follow mandatory branch workflow (Rule 000)
- Use task tracking system (Rule 009)
- Leverage parallel tool calls for efficiency
- Integrate with adaptive test runner

### For Codex AI
- Ensure environment setup matches local development
- Use structured prompts from playbooks
- Follow coding conventions strictly
- Report issues clearly in PR descriptions

## 🔄 Continuous Improvement

This guidance system evolves based on:
- AI agent performance and feedback
- Project modernization progress
- Development team insights
- Community best practices

**Remember**: These documents are living guides. Update them as you learn and discover better patterns for AI-assisted development. 