#!/usr/bin/env python3
"""
Fix Cursor Rules Frontmatter
Converts legacy frontmatter format to correct Cursor .mdc format

Usage: python scripts/fix_cursor_rules.py
"""

from pathlib import Path
import re
from typing import Dict


def extract_legacy_frontmatter(content: str) -> tuple[Dict[str, str], str]:
    """Extract legacy frontmatter and return normalized values + remaining content."""

    # Match frontmatter block
    frontmatter_pattern = r"^---\n(.*?)\n---\n(.*)$"
    match = re.match(frontmatter_pattern, content, re.DOTALL)

    if not match:
        return {}, content

    frontmatter_text = match.group(1)
    body_content = match.group(2)

    # Parse legacy frontmatter
    legacy_data = {}
    for line in frontmatter_text.split("\n"):
        line = line.strip()
        if ":" in line and not line.startswith("#"):
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            legacy_data[key] = value

    return legacy_data, body_content


def determine_rule_type(
    legacy_data: Dict[str, str], filename: str
) -> tuple[str, str, bool]:
    """Determine the correct Cursor rule type from legacy data."""

    # Check filename for type hints
    if filename.startswith("000-") or "mandatory" in filename.lower():
        return "", "", True  # Always rule

    # Check legacy type field
    legacy_type = legacy_data.get("type", "").lower()

    if legacy_type == "always" or legacy_data.get("auto_attach") == "false":
        return "", "", True

    if legacy_type == "auto-attach" or legacy_data.get("auto_attach") == "true":
        # Auto-attach rule - extract globs
        globs = []

        # Check various glob fields
        for key in ["globs", "applies_to"]:
            value = legacy_data.get(key, "")
            if value and value not in ["all_files", "python_files"]:
                globs.append(value)

        # Default globs based on filename
        if not globs:
            if "python" in filename:
                globs = ["**/*.py", "src/**/*.py", "tests/**/*.py"]
            elif "testing" in filename:
                globs = ["**/*test*.py", "tests/**/*.py", "**/test_*.py"]
            elif "security" in filename:
                globs = ["**/*.py", "**/*.ts", "**/*.js"]
            elif "branch" in filename:
                globs = [".github/**/*.yml", ".github/**/*.yaml"]

        globs_str = ", ".join(globs) if globs else ""
        return "", globs_str, False

    if legacy_type == "agent-requested" or legacy_data.get("agent_requested") == "true":
        # Agent-selected rule
        description = legacy_data.get("description", "")
        if not description.startswith("USE WHEN"):
            description = f"USE WHEN {description.lower()}"
        return description, "", False

    # Default to manual rule
    return "", "", False


def create_correct_frontmatter(description: str, globs: str, always_apply: bool) -> str:
    """Create properly formatted Cursor frontmatter."""

    return f"""---
description: {description}
globs: {globs}
alwaysApply: {str(always_apply).lower()}
---"""


def fix_rule_file(file_path: Path) -> bool:
    """Fix a single rule file. Returns True if changes were made."""

    try:
        with open(file_path, encoding="utf-8") as f:
            content = f.read()

        # Extract legacy frontmatter
        legacy_data, body_content = extract_legacy_frontmatter(content)

        if not legacy_data:
            print(f"  ⚠️  No frontmatter found in {file_path.name}")
            return False

        # Check if already correct format
        if set(legacy_data.keys()) <= {"description", "globs", "alwaysApply"}:
            print(f"  ✅ Already correct format: {file_path.name}")
            return False

        # Determine correct rule type
        description, globs, always_apply = determine_rule_type(
            legacy_data, file_path.name
        )

        # Create new frontmatter
        new_frontmatter = create_correct_frontmatter(description, globs, always_apply)

        # Combine with body
        new_content = new_frontmatter + "\n\n" + body_content.lstrip()

        # Write back to file
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(new_content)

        rule_type = (
            "Always"
            if always_apply
            else (
                "Auto-Attach"
                if globs
                else ("Agent-Selected" if description else "Manual")
            )
        )
        print(f"  🔧 Fixed {file_path.name} -> {rule_type}")
        return True

    except Exception as e:
        print(f"  ❌ Error fixing {file_path.name}: {e}")
        return False


def main():
    """Main function to fix all rule files."""

    print("🔧 Fixing Cursor Rules Frontmatter")
    print("=" * 50)

    # Find .cursor/rules directory
    rules_dir = Path(".cursor/rules")
    if not rules_dir.exists():
        print("❌ .cursor/rules directory not found")
        return

    # Find all .mdc files
    mdc_files = list(rules_dir.rglob("*.mdc"))

    if not mdc_files:
        print("❌ No .mdc files found in .cursor/rules")
        return

    print(f"📋 Found {len(mdc_files)} rule files:")

    fixed_count = 0
    for file_path in sorted(mdc_files):
        if fix_rule_file(file_path):
            fixed_count += 1

    print("=" * 50)
    print(f"✅ Fixed {fixed_count} out of {len(mdc_files)} rule files")

    if fixed_count > 0:
        print("\n📝 Next steps:")
        print("1. Test rules by starting a new chat session (Cmd+N)")
        print("2. Check Cursor Settings > Rules to verify detection")
        print("3. Add this to your Cursor settings:")
        print('   "workbench.editorAssociations": { "*.mdc": "default" }')


if __name__ == "__main__":
    main()
