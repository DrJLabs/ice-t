#!/usr/bin/env python3
"""Utility helpers for custom pre-commit hooks.

Provides simple offline implementations for several basic checks used in this
repository. Each helper operates on the files given as arguments and exits
with status code ``0`` on success or ``1`` on failure. The available commands
are:

- ``trailing-whitespace``: remove trailing whitespace from text files.
- ``end-of-file``: ensure files end with a single newline.
- ``check-yaml``: validate YAML files using ``PyYAML`` when available.
- ``check-json``: validate JSON files.
- ``check-merge-conflict``: detect typical merge conflict markers.
- ``security-check``: look for risky debug statements such as ``pdb`` usage
  or ``eval`` calls.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except Exception:  # pragma: no cover - PyYAML may not be available
    yaml = None  # type: ignore


def trailing_whitespace(files: list[str]) -> bool:
    changed = False
    pattern = re.compile(r"[ \t]+$")
    for file in files:
        path = Path(file)
        if not path.is_file():
            continue
        lines = path.read_text().splitlines(keepends=True)
        new_lines = []
        for line in lines:
            if line.endswith("\n"):
                stripped = pattern.sub("", line[:-1]) + "\n"
            else:
                stripped = pattern.sub("", line)
            new_lines.append(stripped)
        if lines != new_lines:
            path.write_text("".join(new_lines))
            changed = True
    return changed


def end_of_file(files: list[str]) -> bool:
    changed = False
    for file in files:
        path = Path(file)
        if not path.is_file():
            continue
        data = path.read_bytes()
        if not data.endswith(b"\n"):
            path.write_bytes(data + b"\n")
            changed = True
    return changed


def check_yaml(files: list[str]) -> bool:
    if yaml is None:
        print("PyYAML is required for YAML validation", file=sys.stderr)
        return False
    ok = True
    for file in files:
        try:
            with open(file, "r", encoding="utf-8") as fh:
                yaml.safe_load(fh)
        except Exception as exc:  # pragma: no cover - simple reporting
            print(f"YAML validation failed for {file}: {exc}", file=sys.stderr)
            ok = False
    return ok


def check_json(files: list[str]) -> bool:
    ok = True
    for file in files:
        try:
            with open(file, "r", encoding="utf-8") as fh:
                json.load(fh)
        except Exception as exc:
            print(f"JSON validation failed for {file}: {exc}", file=sys.stderr)
            ok = False
    return ok


def check_merge_conflict(files: list[str]) -> bool:
    ok = True
    conflict = re.compile(r"^(<<<<<<<|=======|>>>>>>>)", re.MULTILINE)
    for file in files:
        text = Path(file).read_text(errors="ignore")
        if conflict.search(text):
            print(f"Merge conflict marker found in {file}", file=sys.stderr)
            ok = False
    return ok


def security_check(files: list[str]) -> bool:
    ok = True
    patterns = [
        re.compile(r"\bimport\s+pdb\b"),
        re.compile(r"pdb\.set_trace\s*\("),
        re.compile(r"\beval\s*\("),
        re.compile(r"\bexec\s*\("),
    ]
    for file in files:
        text = Path(file).read_text(errors="ignore")
        for pat in patterns:
            if pat.search(text):
                print(f"Potential insecure code in {file}: pattern '{pat.pattern}'", file=sys.stderr)
                ok = False
    return ok


COMMANDS = {
    "trailing-whitespace": trailing_whitespace,
    "end-of-file": end_of_file,
    "check-yaml": check_yaml,
    "check-json": check_json,
    "check-merge-conflict": check_merge_conflict,
    "security-check": security_check,
}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run pre-commit helper commands")
    parser.add_argument("command", choices=COMMANDS.keys(), help="Command to run")
    parser.add_argument("files", nargs="*", help="Files to operate on")
    args = parser.parse_args(argv)

    func = COMMANDS[args.command]
    success = func(args.files)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
