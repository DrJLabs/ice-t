# 003-Quality-Standards

## Quality Gates for Codex Development

Use this document to enforce rigorous checks so the AI agent consistently delivers production-quality code. These standards define when work is acceptable.

Automated quality standards that Codex must meet.

### Coverage Requirements

- **94%+ test coverage** for all new code
- **100% type coverage** for public APIs
- **Zero security vulnerabilities** (bandit scan)
- **Zero linting errors** (ruff check)

### Tools Configuration

```bash
# Quality check commands
ruff check .                 # Linting
mypy src/                   # Type checking
bandit -r src/              # Security scan
pytest --cov=src --cov-fail-under=94  # Coverage
```

### Automated Gates

All code must pass:
1. Formatting (ruff format)
2. Linting (ruff check)
3. Type checking (mypy)
4. Security scanning (bandit)
5. Test coverage (94%+)
6. Performance benchmarks
