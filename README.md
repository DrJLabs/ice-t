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


## Self-hosted Runners

The CI pipelines rely on a pool of self-hosted runners labeled `ice-t` with additional role labels such as `build`, `test`, and `quality`. Ensure at least one runner for each role is online so workflows can execute.

