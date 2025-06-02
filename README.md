# ice-t

Autonomous high-performance template for web‑app projects driven by Cursor & Codex.

## Development Setup

1. Create and activate a Python 3.12 virtual environment.
2. Install runtime dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Install development tools:
   ```bash
   pip install -r dev-requirements.txt
   ```
4. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```
   The project expects **pre-commit 3.7.0 or newer**. Verify with `pre-commit --version`.
5. Run tests to verify the environment:
   ```bash
   pytest
   ```

