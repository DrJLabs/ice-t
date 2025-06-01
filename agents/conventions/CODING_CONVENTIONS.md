# 🏗️ Ice-T Coding Conventions & Architectural Guidelines

## 🎯 Architecture Overview

Ice-T follows a **Vertical Slice Architecture** pattern, organizing features as self-contained modules with clear boundaries and minimal coupling.

## 📁 Project Structure Standards

### Core Directory Layout
```
src/ice_t/
├── core/                    # Core utilities and base classes
│   ├── __init__.py
│   ├── exceptions.py        # Custom exception classes
│   ├── base_service.py      # Base service class
│   └── config.py           # Configuration management
├── features/               # Feature modules (vertical slices)
│   └── [feature_name]/
│       ├── __init__.py     # Feature exports
│       ├── domain.py       # Business logic
│       ├── dto.py          # Data transfer objects
│       └── service.py      # Service layer
├── integrations/           # External service integrations
├── utilities/              # Shared utilities
└── __init__.py
```

### Supporting Directories
```
scripts/
├── deployment/             # Deployment automation
├── development/            # Development tools
├── runners/                # Script execution engines
├── testing/                # Test automation
├── maintenance/            # System maintenance
└── utilities/              # Shared script utilities

tests/
├── features/               # Feature tests
├── integration/            # Integration tests
├── api/                    # API tests
├── cli/                    # CLI tests
└── utils/                  # Test utilities
```

## 🏛️ Architectural Patterns

### 1. Vertical Slice Architecture

Each feature in `src/ice_t/features/[feature_name]/` MUST follow this pattern:

#### **domain.py** - Business Logic
```python
from abc import ABC, abstractmethod
from typing import Dict, Any, List
from dataclasses import dataclass

@dataclass
class FeatureDomain:
    """Core business logic for the feature."""

    def __init__(self, config: Dict[str, Any]):
        self.config = config

    def process_business_logic(self, input_data: Any) -> Any:
        """Implement core business rules here."""
        # Business logic implementation
        pass
```

#### **dto.py** - Data Transfer Objects
```python
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class FeatureRequestDTO(BaseModel):
    """Request data structure for feature operations."""

    id: str = Field(..., description="Unique identifier")
    name: str = Field(..., min_length=1, max_length=100)
    config: Dict[str, Any] = Field(default_factory=dict)
    created_at: Optional[datetime] = None

    class Config:
        validate_assignment = True

class FeatureResponseDTO(BaseModel):
    """Response data structure for feature operations."""

    id: str
    status: str
    result: Dict[str, Any]
    metadata: Optional[Dict[str, Any]] = None
```

#### **service.py** - Service Layer
```python
from typing import List, Optional
from ..core.base_service import BaseService
from .domain import FeatureDomain
from .dto import FeatureRequestDTO, FeatureResponseDTO

class FeatureService(BaseService):
    """Service layer for feature operations."""

    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.domain = FeatureDomain(config)

    async def process_request(
        self,
        request: FeatureRequestDTO
    ) -> FeatureResponseDTO:
        """Process feature request through business logic."""
        try:
            result = await self.domain.process_business_logic(request)
            return FeatureResponseDTO(
                id=request.id,
                status="success",
                result=result
            )
        except Exception as e:
            self.logger.error(f"Feature processing failed: {e}")
            return FeatureResponseDTO(
                id=request.id,
                status="error",
                result={"error": str(e)}
            )
```

---

## 🎯 Enforcement

These conventions are **NON-NEGOTIABLE** and must be followed by all code contributors, including AI agents.

## 1. General Coding Standards

*   **Language:** All backend code will be written in Python 3.12+.
*   **Style:** Follow PEP 8, enforced by Ruff formatter (configured in `pyproject.toml` and pre-commit hooks).
*   **Type Hinting:** All functions, methods, and variables should have comprehensive type hints. Mypy is used for static type checking and must pass.
*   **Docstrings:** All public modules, classes, functions, and methods must have Google-style docstrings. Docstrings should explain the "why" and usage, not just re-state the "what".
*   **Imports:** Use `isort` for import ordering (configured in `pyproject.toml` and pre-commit).
*   **Logging:** Use the standard Python `logging` module. Configure appropriately for different environments.
*   **Error Handling:** Use specific exceptions. Avoid catching generic `Exception` unless re-raising or handling a very broad case with clear justification.
*   **Immutability:** Prefer immutable data structures where practical.
*   **Simplicity:** Favor clear, straightforward code over overly complex or "clever" solutions.

## 2. Project Structure & Architecture

Refer to the `CODEX_T_MODERNIZATION_PLAN.md` for the target source code structure (e.g., `src/ice_t/core/`, `src/ice_t/features/`, `src/ice_t/integrations/`, `src/ice_t/utilities/`).

*   **Vertical Slices for Features:**
    *   New features should be implemented as self-contained modules under `src/ice_t/features/`.
    *   Each feature module should typically include:
        *   `domain.py`: Core business logic, Pydantic models for domain entities.
        *   `service.py`: Service layer coordinating logic, interacting with domain objects and potentially other services or integrations.
        *   `dto.py` (Data Transfer Objects): Pydantic models for API request/response, or for data transfer between layers if different from domain models.
        *   `routes.py` (if applicable for API features): FastAPI routers and endpoint definitions.
*   **Core Components (`src/ice_t/core/`):**
    *   Contains foundational code shared across multiple features or the entire application (e.g., base classes, core utilities not specific to a domain, shared Pydantic configurations).
    *   Core components should be highly stable and have minimal external dependencies.
*   **Utilities (`src/ice_t/utilities/`):**
    *   Shared helper functions or classes that don't fit into `core` and are not feature-specific (e.g., date helpers, string manipulation).
*   **Integrations (`src/ice_t/integrations/`):**
    *   Modules responsible for communicating with external services (e.g., third-party APIs, databases if not using an ORM handled elsewhere).

## 3. Data Modeling (Pydantic)

*   **Pydantic:** Use Pydantic for all data validation, serialization, and settings management.
*   **Base Models:** Consider creating base Pydantic models with common configurations (e.g., `alias_generator`, `populate_by_name`).
*   **Clarity:** Define clear, explicit schemas for all data structures.

## 4. Testing Conventions

*   **Framework:** Pytest is the standard testing framework.
*   **Test Location:** Tests should reside in the `tests/` directory, mirroring the `src/` structure (e.g., `tests/features/feature_a/test_service.py`).
*   **Test Types & Markers:**
    *   `@pytest.mark.unit`: For fast tests of isolated functions/classes. Mock external dependencies.
    *   `@pytest.mark.integration`: For tests verifying interactions between components or with external services (like databases, if applicable). These may be slower.
    *   `@pytest.mark.smoke`: A small subset of critical-path tests (unit or integration) to quickly verify basic application health.
    *   Use other markers (`slow`, `external`) as defined in `pytest.ini` or `pyproject.toml`.
*   **Coverage:** Aim for >94% test coverage, enforced by CI.
*   **`adaptive_test_runner.py`:** The AI agent should be instructed to use this runner for executing tests after making changes, especially with file-change information for smart selection.
*   **Fixtures:** Use Pytest fixtures for setting up test preconditions.

## 5. API Design (if applicable)

*   **Framework:** If building a web API, FastAPI is preferred.
*   **Schema:** Define explicit request and response models using Pydantic DTOs.
*   **Versioning:** Plan for API versioning early (e.g., `/v1/...`).
*   **Authentication & Authorization:** Implement robust security measures.
*   **Idempotency:** Design endpoints to be idempotent where appropriate.

## 6. Tool Usage

*   **Linters/Formatters (`ruff`, `black`, `isort`, `mypy`):**
    *   These are run via pre-commit hooks and in CI.
    *   The AI agent should aim to produce code that passes these checks by default. The agent can be instructed to run these locally (e.g. via a script invoking them) before finalizing changes.
*   **`pre-commit`:** Hooks are defined in `.pre-commit-config.yaml`. Ensure local git hooks are installed (`pre-commit install`).
*   **`adaptive_test_runner.py`:** As the primary means for the AI to run tests. See `agents/conventions/TOOL_USAGE.md` for specific invocation patterns.
*   **`edit_file` Tool:** The AI will use this for all code modifications. Provide clear instructions and sufficient context.
*   **`run_terminal_cmd` Tool:** For running linters, tests, or other CLI tools as needed. Ensure commands are non-interactive.

## 7. Dependencies

*   Managed via `pyproject.toml` and `pip-tools` (see `CODEX_T_MODERNIZATION_PLAN.md`).
*   The AI should not attempt to install packages directly unless explicitly instructed as part of a controlled environment setup playbook.
*   If a new dependency is needed, the AI should suggest adding it to `pyproject.toml` and regenerating lockfiles.

## 8. Documentation

*   **Code Comments:** Use for explaining complex logic that isn't obvious from the code itself.
*   **Docstrings:** As described above.
*   **Project Documentation (`docs/`):** Broader architectural discussions, setup guides, etc. The AI may be asked to update these.

This document is a living guide and will be updated as the project evolves.
