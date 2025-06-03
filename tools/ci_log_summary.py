#!/usr/bin/env python3
"""Summarize errors from CI logs stored in `.codex/logs/`.

This utility scans log files named `ci_*.log` and extracts lines
containing common error patterns. Use it to quickly identify
failure causes from the collected logs.
"""

from __future__ import annotations

import argparse
from collections.abc import Iterable
import json
from pathlib import Path
import re
from typing import List

DEFAULT_PATTERNS = [
    re.compile(p, re.IGNORECASE) for p in ["ERROR", "FAILED", "Traceback"]
]


def extract_error_lines(
    log_file: Path, patterns: Iterable[re.Pattern[str]] = DEFAULT_PATTERNS
) -> List[str]:
    """Return lines from *log_file* matching any of the patterns."""
    if not log_file.is_file():
        return []
    lines = log_file.read_text(errors="ignore").splitlines()
    matches = [line for line in lines if any(p.search(line) for p in patterns)]
    return matches


def summarize_logs(directory: Path, limit: int = 5) -> dict[str, List[str]]:
    """Summarize the newest *limit* logs in *directory*."""
    summaries: dict[str, List[str]] = {}
    for log_file in sorted(directory.glob("ci_*.log"))[-limit:]:
        summaries[log_file.name] = extract_error_lines(log_file)
    return summaries


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Summarize CI error logs")
    parser.add_argument(
        "--dir", default=".codex/logs", help="Directory containing log files"
    )
    parser.add_argument(
        "--limit", type=int, default=5, help="Number of recent logs to process"
    )
    parser.add_argument("--json", action="store_true", help="Output summary as JSON")
    args = parser.parse_args(argv)

    log_dir = Path(args.dir)
    if not log_dir.exists():
        print(f"⚠️  Log directory not found: {log_dir}")
        return 1

    summaries = summarize_logs(log_dir, args.limit)

    if args.json:
        print(json.dumps(summaries, indent=2))
    else:
        for name, lines in summaries.items():
            print(f"\n=== {name} ===")
            if lines:
                for line in lines:
                    print(line)
            else:
                print("No errors found")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
