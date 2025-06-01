#!/usr/bin/env python3
"""CI debugging script to diagnose environment issues."""

import logging
from pathlib import Path
import subprocess
import sys

# Configure logging for CI debugging
logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger(__name__)

MAX_MARKERS_TO_SHOW = 5


def run_command(cmd: str, check: bool = True) -> tuple[int, str, str]:
    """Run a command and return exit code, stdout, stderr."""
    try:
        result = subprocess.run(
            cmd.split(), capture_output=True, text=True, check=check
        )
    except subprocess.CalledProcessError as e:
        return e.returncode, e.stdout, e.stderr
    except FileNotFoundError:
        return 127, "", f"Command not found: {cmd.split()[0]}"
    else:
        return result.returncode, result.stdout, result.stderr


def check_environment():
    """Check the CI environment setup."""
    logger.info("🔍 CI Environment Diagnostics")
    logger.info("=" * 50)

    # Python environment
    logger.info("🐍 Python version: %s", sys.version)
    logger.info("📍 Python executable: %s", sys.executable)
    logger.info("📦 Python path: %s...", ":".join(sys.path[:3]))

    # Virtual environment
    venv_path = Path(sys.executable).parent.parent
    logger.info("🏠 Virtual env: %s", venv_path)
    logger.info("🏠 VIRTUAL_ENV: %s", sys.prefix)

    # Check pytest installation
    exit_code, stdout, stderr = run_command("pytest --version", check=False)
    if exit_code == 0:
        logger.info("✅ pytest: %s", stdout.strip())
    else:
        logger.error("❌ pytest not available: %s", stderr)

    # Check pytest plugins
    exit_code, stdout, stderr = run_command("pytest --trace-config", check=False)
    if exit_code == 0:
        logger.info("✅ pytest config traceable")
        plugins = [line for line in stdout.split("\n") if "plugin" in line.lower()]
        logger.info("🔌 Found %d plugin references", len(plugins))
    else:
        logger.error("❌ pytest config error: %s", stderr)

    # Check specific plugins
    plugins_to_check = ["pytest_xdist", "pytest_cov", "pytest_mock"]
    for plugin in plugins_to_check:
        try:
            __import__(plugin)
            logger.info("✅ %s available", plugin)
        except ImportError:
            logger.info("❌ %s not available", plugin)

    # Check test discovery
    logger.info("\n🔍 Test Discovery")
    exit_code, stdout, stderr = run_command("pytest --collect-only -q", check=False)
    if exit_code == 0:
        lines = stdout.strip().split("\n")
        test_count = len([line for line in lines if "::" in line])
        logger.info("✅ Discovered %d tests", test_count)
    else:
        logger.error("❌ Test discovery failed: %s", stderr)

    # Check markers
    logger.info("\n🏷️ Available markers:")
    exit_code, stdout, stderr = run_command("pytest --markers", check=False)
    if exit_code == 0:
        markers = [
            line.strip()
            for line in stdout.split("\n")
            if line.strip().startswith("@pytest.mark.")
        ]
        for marker in markers[:MAX_MARKERS_TO_SHOW]:  # Show first 5
            logger.info("  %s", marker)
        if len(markers) > MAX_MARKERS_TO_SHOW:
            logger.info("  ... and %d more", len(markers) - MAX_MARKERS_TO_SHOW)

    logger.info("\n%s", "=" * 50)
    return exit_code == 0


if __name__ == "__main__":
    success = check_environment()
    if not success:
        logger.error("❌ Environment issues detected")
        sys.exit(1)
    else:
        logger.info("✅ Environment looks good")
        sys.exit(0)
