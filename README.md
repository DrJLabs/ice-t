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
4. Copy the sample environment file and edit as needed:
   ```bash
   cp .env.example .env
   ```
5. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```
   The project expects **pre-commit 4.0 or newer**. Verify with `pre-commit --version`.
   The hooks rely on **Ruff** for linting and formatting, matching the version pinned in `pyproject.toml`.
   Some security hooks (bandit and safety) may require packages from
   `dev-requirements.txt`.

   New hooks mirror the CI job matrix. Trigger them manually when needed:

       pre-commit run ice-t-unit-tests
       pre-commit run ice-t-integration-tests
6. Run tests to verify the environment:
   ```bash
    pytest
    ```

## Adaptive Test Runner

Use `scripts/adaptive_test_runner.py` to execute tests. It supports running a
single group or a sequence of groups similar to the CI matrix.

Run smoke tests:

```bash
python scripts/adaptive_test_runner.py run --smoke
```

Run a sequence of groups:

```bash
python scripts/adaptive_test_runner.py run --sequence smoke,unit-core,unit-features
```

## Tox Environments

The CI workflow defines several job stages which can be reproduced locally via
`tox`. Available environments mirror the pipeline:

- `lint` – run pre-commit quality checks
- `type` – execute MyPy for static analysis
- `security` – run Bandit and Safety scans
- `tests` – execute the full test suite via the adaptive runner
- `build` – build the project using `python -m build`

Run a specific environment, for example code quality checks:

```bash
tox -e lint
```

## Dependency Lock Files

The project uses **pip-tools** to pin dependencies. After editing
`requirements.in` or `dev-requirements.in`, regenerate the lock files:

```bash
pip-compile requirements.in
pip-compile dev-requirements.in
```

Commit the resulting `requirements.txt` and `dev-requirements.txt`. The CI
workflows also run these commands to ensure lock files remain current.

## Diagram Generation

The workflow `.github/workflows/diagram-generation.yml` automatically
generates diagrams for the repository. It runs on:

- pushes to `main` or `develop`
- pull requests targeting these branches
- manual **workflow_dispatch** triggers

The diagrams are produced by the `scripts/generate_*` utilities and
stored in `docs/diagrams/`. To build them locally install the system
packages `graphviz`, `graphviz-dev` and `plantuml` then run:

```bash
python scripts/generate_architecture_diagrams.py
python scripts/generate_workflow_diagrams.py
python scripts/generate_dependency_graphs.py
```


## CI Failure Analysis & Automated Logging

The project includes automated CI failure analysis infrastructure to enable rapid debugging and repair:

### 🔍 **Automated Log Collection**
- **Failure Logs**: Detailed CI failure logs are automatically captured in `.codex/logs/ci_[run_id].log`
- **Performance Metrics**: CI performance data is collected in `.codex/metrics/ci-metrics.jsonl`
- **Automated Commits**: Logs are committed directly to the repository, bypassing all checks for immediate availability

### 🤖 **AI Agent Integration**
The logging system is designed for AI-driven analysis and repair:

```bash
# View latest failure log
cat $(ls -t .codex/logs/ci_*.log | head -1)

# Search for errors across logs
grep -r "ERROR\|FAILED\|error:" .codex/logs/

# View recent performance metrics
tail -5 .codex/metrics/ci-metrics.jsonl | jq .
```

### 📊 **Workflow Integration**
- `save-failed-log.yml`: Captures complete CI logs when workflows fail
- `collect-ci-metrics.yml`: Tracks performance metrics for all CI runs
- Both workflows trigger automatically on CI completion and commit data immediately

## Self-hosted Runners

The CI pipelines rely on a pool of self-hosted runners labeled `ice-t` with additional role labels such as `build`, `test`, and `quality`. Ensure at least one runner for each role is online so workflows can execute.

## Modernization Guide

The long-term roadmap for this repository lives in `CODEX_T_MODERNIZATION_PLAN.md`.
Review that document regularly to understand current priorities and progress.

