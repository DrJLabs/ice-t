from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.ci_log_summary import extract_error_lines, summarize_logs


def test_extract_error_lines(tmp_path: Path) -> None:
    log = tmp_path / "ci_1.log"
    log.write_text(
        """INFO start\nERROR failed step\nline\nTraceback (most recent call last):\nValueError: bad\n"""
    )
    errors = extract_error_lines(log)
    assert "ERROR failed step" in errors
    assert any("Traceback" in e for e in errors)


def test_summarize_logs(tmp_path: Path) -> None:
    (tmp_path / "ci_2.log").write_text("ALL GOOD\n")
    (tmp_path / "ci_3.log").write_text("FAIL\nERROR boom\n")
    summaries = summarize_logs(tmp_path, limit=2)
    assert "ci_3.log" in summaries
    assert summaries["ci_3.log"]
    assert summaries["ci_2.log"] == []
