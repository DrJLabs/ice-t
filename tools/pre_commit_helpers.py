#!/usr/bin/env python3
"""
Pre-commit helper utilities for ice-t project.

This module provides helper functions for pre-commit hooks that don't require
external dependencies or complex configurations.
"""

import argparse
from collections.abc import Sequence
import json
import re
import sys


def trailing_whitespace(filenames: Sequence[str]) -> int:
    """Remove trailing whitespace from files."""
    retval = 0
    for filename in filenames:
        try:
            with open(filename, "rb") as f:
                original_contents = f.read()

            # Remove trailing whitespace from each line
            fixed_contents = b"\n".join(
                line.rstrip() for line in original_contents.splitlines()
            )

            # Ensure file ends with exactly one newline if it's not empty
            if fixed_contents and not fixed_contents.endswith(b"\n"):
                fixed_contents += b"\n"

            if original_contents != fixed_contents:
                print(f"Fixed trailing whitespace in {filename}")
                with open(filename, "wb") as f:
                    f.write(fixed_contents)
                retval = 1

        except Exception as e:
            print(f"Error processing {filename}: {e}")
            retval = 1

    return retval


def end_of_file(filenames: Sequence[str]) -> int:
    """Ensure files end with exactly one newline."""
    retval = 0
    for filename in filenames:
        try:
            with open(filename, "rb") as f:
                original_contents = f.read()

            if not original_contents:
                continue  # Empty files are fine

            if not original_contents.endswith(b"\n"):
                print(f"Fixed end of file newline in {filename}")
                with open(filename, "ab") as f:
                    f.write(b"\n")
                retval = 1
            elif original_contents.endswith(b"\n\n"):
                # Remove extra trailing newlines
                fixed_contents = original_contents.rstrip(b"\n") + b"\n"
                if fixed_contents != original_contents:
                    print(f"Fixed multiple trailing newlines in {filename}")
                    with open(filename, "wb") as f:
                        f.write(fixed_contents)
                    retval = 1

        except Exception as e:
            print(f"Error processing {filename}: {e}")
            retval = 1

    return retval


def check_yaml(filenames: Sequence[str]) -> int:
    """Check YAML files for syntax errors."""
    try:
        import yaml
    except ImportError:
        print("⚠️ PyYAML not available - skipping YAML check")
        return 0

    retval = 0
    for filename in filenames:
        try:
            with open(filename) as f:
                yaml.safe_load(f)
            print(f"✅ {filename} - Valid YAML")
        except yaml.YAMLError as e:
            print(f"❌ {filename} - YAML error: {e}")
            retval = 1
        except Exception as e:
            print(f"❌ Error reading {filename}: {e}")
            retval = 1

    return retval


def check_json(filenames: Sequence[str]) -> int:
    """Check JSON files for syntax errors."""
    retval = 0
    for filename in filenames:
        try:
            with open(filename) as f:
                json.load(f)
            print(f"✅ {filename} - Valid JSON")
        except json.JSONDecodeError as e:
            print(f"❌ {filename} - JSON error: {e}")
            retval = 1
        except Exception as e:
            print(f"❌ Error reading {filename}: {e}")
            retval = 1

    return retval


def check_merge_conflict(filenames: Sequence[str]) -> int:
    """Check for merge conflict markers."""
    # More specific patterns that are actual merge conflict markers
    conflict_patterns = [
        (
            b"<" + b"<" + b"<" + b"<" + b"<" + b"<" + b"<" + b" ",
            "Git merge conflict start",
        ),
        (
            b"=" + b"=" + b"=" + b"=" + b"=" + b"=" + b"=" + b"\n",
            "Git merge conflict separator",
        ),
        (
            b">" + b">" + b">" + b">" + b">" + b">" + b">" + b" ",
            "Git merge conflict end",
        ),
    ]

    retval = 0
    for filename in filenames:
        try:
            with open(filename, "rb") as f:
                contents = f.read()

            for i, line in enumerate(contents.splitlines(), 1):
                for pattern, description in conflict_patterns:
                    # Check for exact patterns that indicate real merge conflicts
                    if line.startswith(pattern) or (
                        pattern.endswith(b"\n") and line == pattern.rstrip(b"\n")
                    ):
                        print(
                            f"❌ {filename}:{i} - {description}: {line.decode('utf-8', errors='replace')}"
                        )
                        retval = 1

        except Exception as e:
            print(f"❌ Error reading {filename}: {e}")
            retval = 1

    return retval


def security_check(filenames: Sequence[str]) -> int:
    """Basic security pattern check for Python files."""
    # Common security anti-patterns
    patterns = [
        (r"password\s*=\s*['\"][^'\"]+['\"]", "Hardcoded password detected"),
        (r"api_key\s*=\s*['\"][^'\"]+['\"]", "Hardcoded API key detected"),
        (r"secret\s*=\s*['\"][^'\"]+['\"]", "Hardcoded secret detected"),
        (r"subprocess\..*shell\s*=\s*True", "Shell injection risk detected"),
        (r"pickle\.loads?", "Pickle usage detected (security risk)"),
    ]

    retval = 0
    for filename in filenames:
        try:
            with open(filename) as f:
                content = f.read()

            for i, line in enumerate(content.splitlines(), 1):
                for pattern, message in patterns:
                    if re.search(pattern, line, re.IGNORECASE):
                        print(f"⚠️ {filename}:{i} - {message}: {line.strip()}")
                        retval = 1

        except Exception as e:
            print(f"❌ Error reading {filename}: {e}")
            retval = 1

    return retval


def main() -> int:
    """Main entry point for pre-commit helpers."""
    parser = argparse.ArgumentParser(description="Pre-commit helper utilities")
    parser.add_argument(
        "command",
        choices=[
            "trailing-whitespace",
            "end-of-file",
            "check-yaml",
            "check-json",
            "check-merge-conflict",
            "security-check",
        ],
    )
    parser.add_argument("filenames", nargs="*", help="Files to process")

    args = parser.parse_args()

    command_map = {
        "trailing-whitespace": trailing_whitespace,
        "end-of-file": end_of_file,
        "check-yaml": check_yaml,
        "check-json": check_json,
        "check-merge-conflict": check_merge_conflict,
        "security-check": security_check,
    }

    return command_map[args.command](args.filenames)


if __name__ == "__main__":
    sys.exit(main())
