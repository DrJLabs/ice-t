from __future__ import annotations

from pathlib import Path

import pytest

# Skip the tests if yamllint is not available
yamllint = pytest.importorskip("yamllint")
from yamllint import linter
from yamllint.config import YamlLintConfig

WORKFLOWS_DIR = Path(__file__).resolve().parents[2] / ".github" / "workflows"
CONFIG = YamlLintConfig("extends: default")

def _workflow_files() -> list[Path]:
    return list(WORKFLOWS_DIR.glob("*.yml")) + list(WORKFLOWS_DIR.glob("*.yaml"))


@pytest.mark.parametrize("workflow_file", _workflow_files())
def test_workflow_yaml_is_valid(workflow_file: Path) -> None:
    """YAML files in .github/workflows should pass yamllint."""
    with workflow_file.open("r", encoding="utf-8") as f:
        content = f.read()
    problems = list(linter.lint(content, CONFIG, str(workflow_file)))
    assert not problems, "\n".join(str(p) for p in problems)
