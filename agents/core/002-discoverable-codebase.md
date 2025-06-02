# 002-Discoverable-Codebase Protocol

## Making Your Codebase Discoverable for Codex

This document explains practices that help the AI agent quickly navigate and understand the repository. Following these conventions ensures tasks can be delegated effectively.

Based on Codex team emphasis on discoverability.

### Naming Conventions

1. **Clear, Descriptive Names**
   - Choose names that explain purpose
   - Avoid abbreviations and jargon
   - Use consistent naming patterns

2. **Directory Structure**
   - Logical organization by feature/domain
   - Clear separation of concerns
   - Consistent depth and grouping

3. **Code Organization**
   - One concept per file/module
   - Clear entry points
   - Documented interfaces

### Implementation Guidelines

```python
# Good: Clear, discoverable structure
src/codex_t/
├── user_management/
│   ├── authentication.py
│   ├── authorization.py
│   └── user_profile.py
├── data_processing/
│   ├── validation.py
│   ├── transformation.py
│   └── storage.py
```

### Navigation Aids

- README files in each major directory
- Clear module docstrings
- Type hints for all public interfaces
- Examples in docstrings
