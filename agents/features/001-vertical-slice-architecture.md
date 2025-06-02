# 001-Vertical-Slice-Architecture

## Vertical Slice Pattern for Codex

Recommended architecture pattern for Codex development.

### Structure

Each feature should be a complete vertical slice:

```
src/ice_t/features/feature_name/
├── __init__.py          # Feature exports
├── domain.py            # Business logic
├── dto.py               # Data transfer objects
├── service.py           # Service layer
├── repository.py        # Data access (if needed)
└── api.py               # API endpoints (if needed)

tests/features/feature_name/
├── test_domain.py       # Unit tests
├── test_service.py      # Integration tests
└── test_api.py          # API tests
```

### Implementation Guidelines

1. **Self-Contained**: Each slice should be independent
2. **Complete**: Include all layers needed for the feature
3. **Testable**: Comprehensive test coverage for each layer
4. **Type-Safe**: Full type hints throughout

### Example

```python
# domain.py
from pydantic import BaseModel
from typing import List

class UserRegistration:
    def __init__(self, validator: UserValidator):
        self.validator = validator

    def register_user(self, email: str, password: str) -> User:
        """Register a new user with validation."""
        # Implementation
        pass
```
