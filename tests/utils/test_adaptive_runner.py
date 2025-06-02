from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from scripts.adaptive_test_runner import AdaptiveTestRunner, main


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
        sys.executable,
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
        sys.executable,
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


def test_main_uses_cwd_and_level_fast(monkeypatch, tmp_path):
    """`main` should initialize runner with CWD and run fast tests."""
    called: dict[str, object] = {}

    orig_init = AdaptiveTestRunner.__init__

    def fake_init(self, project_root=None):
        orig_init(self, project_root)
        called["root"] = self.project_root

    monkeypatch.setattr(AdaptiveTestRunner, "__init__", fake_init)
    monkeypatch.setattr(AdaptiveTestRunner, "run_fast_tests", lambda self: 0)

    monkeypatch.chdir(tmp_path)
    monkeypatch.setattr(sys, "argv", ["prog", "run", "--level", "fast"])

    assert main() == 0
    assert called["root"] == tmp_path


def test_main_sequence_argument(monkeypatch, tmp_path):
    """`main` should parse ``--sequence`` into a list of groups."""
    calls: dict[str, object] = {}
    orig_init = AdaptiveTestRunner.__init__

    def fake_init(self, project_root=None):
        orig_init(self, project_root)
        calls["root"] = self.project_root

    def fake_run_sequence(self, groups):
        calls["groups"] = groups
        return 0

    monkeypatch.setattr(AdaptiveTestRunner, "__init__", fake_init)
    monkeypatch.setattr(AdaptiveTestRunner, "run_sequence", fake_run_sequence)

    monkeypatch.chdir(tmp_path)
    monkeypatch.setattr(
        sys,
        "argv",
        ["prog", "run", "--sequence", "smoke,unit-core"],
    )

    assert main() == 0
    assert calls["root"] == tmp_path
    assert calls["groups"] == ["smoke", "unit-core"]


def test_main_heal_command(monkeypatch, tmp_path):
    """`main` should dispatch the ``heal`` command."""
    called: dict[str, object] = {}
    orig_init = AdaptiveTestRunner.__init__

    def fake_init(self, project_root=None):
        orig_init(self, project_root)
        called["root"] = self.project_root

    monkeypatch.setattr(AdaptiveTestRunner, "__init__", fake_init)
    monkeypatch.setattr(AdaptiveTestRunner, "heal_tests", lambda self: 0)

    monkeypatch.chdir(tmp_path)
    monkeypatch.setattr(sys, "argv", ["prog", "heal"])

    assert main() == 0
    assert called["root"] == tmp_path
