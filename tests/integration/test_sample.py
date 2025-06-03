"""Basic integration test for package API."""

import os
from pathlib import Path
import subprocess
import sys


def test_import_subprocess():
    """Ensure ice_t can be imported in a subprocess and exposes a version."""
    env = dict(**os.environ)
    env["PYTHONPATH"] = str(Path(__file__).resolve().parents[2] / "src")
    result = subprocess.run(
        [sys.executable, "-c", "import ice_t; print(ice_t.__version__)"],
        capture_output=True,
        text=True,
        env=env,
        check=True,
    )
    assert result.stdout.strip()
