#!/usr/bin/env python3

from pathlib import Path
import re

# Mapping of files to their correct configuration
rule_config = {
    "000-mandatory-cursor-workflow.mdc": ("", "", True),  # Always
    "001-core-standards.mdc": (
        "",
        "src/codex_t/features/**/*.py, tests/features/**/*.py",
        False,
    ),  # Auto-attach
    "002-python-best-practices.mdc": (
        "",
        "**/*.py, src/**/*.py, tests/**/*.py",
        False,
    ),  # Auto-attach
    "003-testing-standards.mdc": (
        "",
        "tests/**/*.py, **/test_*.py, **/*_test.py",
        False,
    ),  # Auto-attach
    "004-ci-cd-protection.mdc": (
        "USE WHEN working with CI/CD configurations or deployment workflows",
        "",
        False,
    ),  # Agent
    "005-branch-naming.mdc": ("", "", True),  # Always
    "006-ai-agent-integration.mdc": (
        "USE WHEN setting up AI agents or integrating with AI systems",
        "",
        False,
    ),  # Agent
    "007-security-standards.mdc": (
        "USE WHEN implementing security features or handling sensitive data",
        "",
        False,
    ),  # Agent
    "008-performance-optimization.mdc": (
        "USE WHEN optimizing performance or implementing caching",
        "",
        False,
    ),  # Agent
}


def fix_file(file_path: Path):
    filename = file_path.name
    if filename not in rule_config:
        return

    description, globs, always_apply = rule_config[filename]

    with open(file_path) as f:
        content = f.read()

    # Find the end of the frontmatter
    pattern = r"^---\n.*?\n---\n(.*)$"
    match = re.match(pattern, content, re.DOTALL)

    if match:
        body = match.group(1)
    else:
        body = content

    new_frontmatter = f"""---
description: {description}
globs: {globs}
alwaysApply: {str(always_apply).lower()}
---"""

    new_content = new_frontmatter + "\n\n" + body.lstrip()

    with open(file_path, "w") as f:
        f.write(new_content)

    rule_type = (
        "Always" if always_apply else ("Auto-Attach" if globs else "Agent-Selected")
    )
    print(f"Fixed {filename} -> {rule_type}")


# Fix all files
rules_dir = Path(".cursor/rules")
for mdc_file in rules_dir.glob("*.mdc"):
    fix_file(mdc_file)

print("All rules fixed!")
