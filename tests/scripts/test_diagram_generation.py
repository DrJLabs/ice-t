import os
import sys
import subprocess
from pathlib import Path

import pytest

# Add the repository 'scripts' directory to the path so we can import modules
REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPTS_DIR = REPO_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import generate_architecture_diagrams as arch
import generate_dependency_graphs as deps
import generate_workflow_diagrams as wf


def create_basic_project(root: Path):
    """Create a minimal project structure used by diagram generation."""
    # source files
    (root / "src" / "ice_t" / "core").mkdir(parents=True)
    (root / "src" / "ice_t" / "core" / "__init__.py").write_text("\n")
    (root / "scripts").mkdir()
    (root / "scripts" / "dummy.py").write_text("print('hi')\n")
    (root / "tests" / "unit").mkdir(parents=True)
    (root / "tests" / "unit" / "test_dummy.py").write_text("\n")
    (root / ".github" / "workflows").mkdir(parents=True)
    (root / ".github" / "workflows" / "dummy.yml").write_text(
        "name: Dummy\non: push\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - run: echo hi\n"
    )
    (root / "requirements.txt").write_text("pytest==6.0.0\n")
    (root / "dev-requirements.txt").write_text("ruff==0.0.1\n")


@pytest.mark.usefixtures("monkeypatch")
def test_generate_diagrams(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    create_basic_project(tmp_path)

    def fake_run(cmd, check=True, capture_output=True):
        return subprocess.CompletedProcess(cmd, 0, b"", b"")

    monkeypatch.setattr(subprocess, "run", fake_run)

    cwd = os.getcwd()
    os.chdir(tmp_path)
    try:
        arch.generate_diagrams()
        deps.generate_diagrams()
        wf.generate_diagrams()
    finally:
        os.chdir(cwd)

    docs = tmp_path / "docs" / "diagrams"
    expected = [
        "architecture_overview.mmd",
        "detailed_architecture.dot",
        "component_diagram.puml",
        "project_stats.json",
        "dependency_overview.mmd",
        "dependency_network.dot",
        "package_tree.txt",
        "dependency_analysis.json",
        "runner_mapping.mmd",
        "ci_pipeline_flow.mmd",
        "workflow_dependencies.dot",
        "workflow_metadata.json",
    ]

    for name in expected:
        assert (docs / name).exists(), f"{name} should exist"
