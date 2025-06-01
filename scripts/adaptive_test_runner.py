#!/usr/bin/env python3
"""
Adaptive Test Runner for ice-t
Self-healing test runner with ≥94% coverage baseline.
"""

import argparse
from pathlib import Path
import subprocess
import sys
from typing import Optional


class AdaptiveTestRunner:
    """Self-healing test runner with coverage tracking."""

    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = project_root or Path.cwd()
        self.src_dir = self.project_root / "src"
        self.tests_dir = self.project_root / "tests"
        self.coverage_threshold = 94.0

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
            "-p",
            "no:cov",
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
            "-p",
            "no:cov",
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
            "-p",
            "no:cov",
        ]
        return subprocess.call(cmd)

    def heal_tests(self) -> int:
        """Self-healing mode: fix common test issues."""
        print("🔧 Running test healing...")

        # Create missing test directories
        test_dirs = ["smoke", "integration", "core", "features", "utils"]
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

        print("✅ Test healing complete")
        return 0


def main():
    """Main entry point for adaptive test runner."""
    parser = argparse.ArgumentParser(description="Adaptive Test Runner for ice-t")
    parser.add_argument("command", choices=["run", "heal"], help="Command to execute")
    parser.add_argument(
        "--level",
        choices=["fast", "smoke", "full", "integration"],
        default="fast",
        help="Test level to run",
    )
    parser.add_argument("--smoke", action="store_true", help="Run smoke tests")

    args = parser.parse_args()

    runner = AdaptiveTestRunner()

    if args.command == "heal":
        return runner.heal_tests()

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
