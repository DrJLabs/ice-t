# Coding Conventions

These conventions supplement automated linters and formatters. They describe architecture and style rules that the AI must follow.

## Project Structure

- Application code lives under `src/ice_t/`.
- Features should follow a domain-service-DTO pattern within `src/ice_t/features/`.
- Keep dependencies between modules minimal. Core modules must not depend on optional features or development tools.

## Style Guidelines

- Prefer explicit imports over wildcard imports.
- Keep functions small and focused. When a function grows beyond ~50 lines consider refactoring.
- Write docstrings for all public modules, classes and functions.
- Use type hints consistently and run MyPy as part of tests.
- Ensure Ruff and Black pass before committing.

## Architecture Rules

- New code should be test-driven. Place unit tests under `tests/` mirroring the source layout.
- Services interact with domain models via typed DTO objects.
- Avoid long inheritance chains; prefer composition.
- Configuration should be environment agnostic and loaded from `pyproject.toml` or environment variables.

See `agents/conventions/TOOL_USAGE.md` for how to invoke project tools.
Refer to `CODEX_T_MODERNIZATION_PLAN.md` for the overarching modernization tasks and update statuses as work progresses.
