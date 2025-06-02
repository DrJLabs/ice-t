from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from scripts.adaptive_test_runner import AdaptiveTestRunner


def test_run_group_tests_with_coverage(monkeypatch, tmp_path):
    """`run_group_tests` should invoke pytest with coverage flags."""
    called = {}

    def fake_call(cmd):
        called['cmd'] = cmd
        return 0

    monkeypatch.setattr(subprocess, "call", fake_call)
    runner = AdaptiveTestRunner(project_root=tmp_path)
    result = runner.run_group_tests("core")

    expected_cmd = [
        "python",
        "-m",
        "pytest",
        str(tmp_path / "tests" / "core"),
        "-v",
        "--cov=ice_t",
        "--cov-report=term-missing",
        f"--cov-fail-under={runner.coverage_threshold}",
    ]

    assert result == 0
    assert called["cmd"] == expected_cmd


def test_run_group_tests_no_coverage(monkeypatch, tmp_path):
    """`run_group_tests` should allow disabling coverage."""
    called = {}

    def fake_call(cmd):
        called['cmd'] = cmd
        return 0

    monkeypatch.setattr(subprocess, "call", fake_call)
    runner = AdaptiveTestRunner(project_root=tmp_path)
    result = runner.run_group_tests("core", coverage=False)

    expected_cmd = [
        "python",
        "-m",
        "pytest",
        str(tmp_path / "tests" / "core"),
        "-v",
    ]

    assert result == 0
    assert called["cmd"] == expected_cmd


def test_heal_tests_creates_structure(tmp_path):
    """`heal_tests` should create expected directories and files."""
    tests_root = tmp_path / "tests"
    tests_root.mkdir()
    runner = AdaptiveTestRunner(project_root=tmp_path)

    result = runner.heal_tests()

    assert result == 0
    for name in ["smoke", "integration", "core", "features", "utils"]:
        group_dir = tests_root / name
        init_file = group_dir / "__init__.py"
        assert group_dir.is_dir()
        assert init_file.read_text() == '"""Test module."""\n'

    smoke_test = tests_root / "smoke" / "test_basic.py"
    assert "Basic smoke tests" in smoke_test.read_text()
