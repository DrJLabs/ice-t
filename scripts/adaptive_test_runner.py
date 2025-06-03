#!/usr/bin/env python3
"""
Adaptive Test Runner for ice-t
Self-healing test runner. Coverage requirements are
configured in ``pyproject.toml``.
Supports running a sequence of test groups via ``--sequence``.
"""

import argparse
from pathlib import Path
import subprocess
import sys
from typing import Optional
import tomllib


class AdaptiveTestRunner:
    """Self-healing test runner with coverage tracking.

    The runner can execute individual test groups or a sequence of groups.
    This mirrors the GitHub Actions matrix and allows local replication of the
    CI workflow. Test groups are executed in the given order and the first
    failing group stops execution.
    """

    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = project_root or Path.cwd()
        self.src_dir = self.project_root / "src"
        self.tests_dir = self.project_root / "tests"
        self.coverage_threshold = 94.0

        pyproject = self.project_root / "pyproject.toml"
        if pyproject.is_file():
            with pyproject.open("rb") as f:
                try:
                    data = tomllib.load(f)
                    self.coverage_threshold = (
                        data.get("tool", {})
                        .get("adaptive_test_runner", {})
                        .get("coverage_threshold", self.coverage_threshold)
                    )
                except Exception:
                    pass

    def run_fast_tests(self) -> int:
        """Run fast smoke tests."""
        cmd = [
            sys.executable,
            "-m",
            "pytest",
            str(self.tests_dir / "smoke"),
            "-v",
            "--tb=short",
            "--maxfail=3",
        ]
        return subprocess.call(cmd)

    def run_smoke_tests(self) -> int:
        """Run smoke tests for pre-commit."""
        cmd = [
            sys.executable,
            "-m",
            "pytest",
            str(self.tests_dir / "smoke"),
            "-x",
            "--tb=line",
        ]
        return subprocess.call(cmd)

    def run_full_tests(self) -> int:
        """Run full test suite with coverage."""
        cmd = [
            sys.executable,
            "-m",
            "pytest",
            str(self.tests_dir),
            "--cov=ice_t",
            "--cov-report=term-missing",
            f"--cov-fail-under={self.coverage_threshold}",
            "-v",
        ]
        return subprocess.call(cmd)

    def run_integration_tests(self) -> int:
        """Run integration tests."""
        cmd = [
            sys.executable,
            "-m",
            "pytest",
            str(self.tests_dir / "integration"),
            "-v",
            "--tb=short",
        ]
        return subprocess.call(cmd)

    def run_group_tests(self, group: str, coverage: bool = True) -> int:
        """Run tests for a specific group directory."""
        cmd = [sys.executable, "-m", "pytest", str(self.tests_dir / group), "-v"]
        if coverage:
            cmd += [
                "--cov=ice_t",
                "--cov-report=term-missing",
                f"--cov-fail-under={self.coverage_threshold}",
            ]
        return subprocess.call(cmd)

    def run_sequence(self, groups: list[str]) -> int:
        """Run a sequence of test groups, stopping on first failure.

        Parameters
        ----------
        groups:
            Names of test groups (e.g. ``smoke`` or ``unit-core``).
        """
        mapping = {
            "fast": lambda: self.run_fast_tests(),
            "smoke": lambda: self.run_smoke_tests(),
            "full": lambda: self.run_full_tests(),
            "integration": lambda: self.run_integration_tests(),
            "unit-core": lambda: self.run_group_tests("core"),
            "core": lambda: self.run_group_tests("core"),
            "unit-features": lambda: self.run_group_tests("features"),
            "features": lambda: self.run_group_tests("features"),
            "unit-utils": lambda: self.run_group_tests("utils"),
            "utils": lambda: self.run_group_tests("utils"),
            "api": lambda: self.run_group_tests("api"),
        }

        for group in groups:
            action = mapping.get(group)
            if not action:
                print(f"Unknown test group: {group}")  # noqa: T201
                return 1
            result = action()
            if result != 0:
                return result
        return 0

    def heal_tests(self) -> int:
        """Self-healing mode: fix common test issues."""
        print("🔧 Running test healing...")  # noqa: T201

        # Create missing test directories
        test_dirs = ["smoke", "integration", "core", "features", "utils", "api"]
        for test_dir in test_dirs:
            (self.tests_dir / test_dir).mkdir(exist_ok=True)
            init_file = self.tests_dir / test_dir / "__init__.py"
            if not init_file.exists():
                init_file.write_text('"""Test module."""\n')

        # Create basic smoke test if missing
        smoke_test = self.tests_dir / "smoke" / "test_basic.py"
        if not smoke_test.exists():
            smoke_test.write_text('''"""Basic smoke tests."""

def test_import_ice_t():
    """Test that ice_t can be imported."""
    import ice_t
    assert ice_t.__version__

def test_project_structure():
    """Test basic project structure."""
    from pathlib import Path
    src_dir = Path(__file__).parent.parent.parent / "src" / "ice_t"
    assert src_dir.exists()
    assert (src_dir / "__init__.py").exists()
''')

        print("✅ Test healing complete")  # noqa: T201
        return 0


def main():  # noqa: PLR0911
    """Main entry point for adaptive test runner."""
    parser = argparse.ArgumentParser(description="Adaptive Test Runner for ice-t")
    parser.add_argument("command", choices=["run", "heal"], help="Command to execute")
    parser.add_argument(
        "--level",
        choices=["fast", "smoke", "full", "integration"],
        default="fast",
        help="Test level to run",
    )
    parser.add_argument(
        "--sequence",
        help=(
            "Comma separated list of test groups to run sequentially, e.g. "
            "'smoke,unit-core,unit-features'"
        ),
    )
    parser.add_argument("--smoke", action="store_true", help="Run smoke tests")

    args = parser.parse_args()

    runner = AdaptiveTestRunner()

    if args.command == "heal":
        return runner.heal_tests()

    if args.sequence:
        groups = [g.strip() for g in args.sequence.split(",") if g.strip()]
        return runner.run_sequence(groups)

    if args.smoke or args.level == "smoke":
        return runner.run_smoke_tests()
    if args.level == "fast":
        return runner.run_fast_tests()
    if args.level == "full":
        return runner.run_full_tests()
    if args.level == "integration":
        return runner.run_integration_tests()

    return 1


if __name__ == "__main__":
    sys.exit(main())
