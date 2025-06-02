#!/usr/bin/env python3
"""Evaluate pull requests for auto-merge eligibility."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from typing import Any, Dict, Optional


def run(cmd: str) -> subprocess.CompletedProcess:
    """Run shell command and capture output."""
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, check=False)


def write_output(key: str, value: str) -> None:
    """Write key=value to $GITHUB_OUTPUT and echo for logging."""
    output_file = os.environ.get("GITHUB_OUTPUT")
    if output_file:
        with open(output_file, "a", encoding="utf-8") as fh:
            fh.write(f"{key}={value}\n")
    print(f"{key}={value}")


def load_event() -> Dict[str, Any]:
    path = os.environ.get("GITHUB_EVENT_PATH")
    if not path:
        return {}
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def get_pr_info(event: Dict[str, Any]) -> tuple[Optional[str], Optional[str]]:
    event_name = os.environ.get("GITHUB_EVENT_NAME", "")
    repository = os.environ.get("GITHUB_REPOSITORY", "")
    sha = os.environ.get("GITHUB_SHA", "")

    if event_name == "pull_request":
        pr = event.get("pull_request", {})
        return str(pr.get("number")), pr.get("node_id")

    head_sha = event.get("check_suite", {}).get("head_sha") or sha
    cmd = (
        "gh api "
        f"repos/{repository}/pulls "
        "--jq '.[] | select(.head.sha == \"" + head_sha + "\") | {""number"": .number, ""node_id"": .node_id}'"
    )
    result = run(cmd)
    if result.returncode == 0 and result.stdout.strip():
        try:
            data = json.loads(result.stdout.strip().splitlines()[0])
            return str(data.get("number")), data.get("node_id")
        except json.JSONDecodeError:
            return None, None
    return None, None


def main() -> int:
    event = load_event()
    pr_number, pr_node_id = get_pr_info(event)

    if not pr_number:
        write_output("reason", "No PR found for this event")
        write_output("should-auto-merge", "false")
        return 0

    write_output("pr-number", pr_number)
    if pr_node_id:
        write_output("pr-node-id", pr_node_id)

    cmd = (
        f"gh pr view {pr_number} --json "
        "author,baseRefName,headRefName,title,labels,mergeable,mergeStateStatus,reviewDecision"
    )
    result = run(cmd)
    if result.returncode != 0:
        write_output("reason", "Failed to fetch PR details")
        write_output("should-auto-merge", "false")
        return 1

    details = json.loads(result.stdout)
    author = details["author"]["login"]
    base_branch = details["baseRefName"]
    head_branch = details["headRefName"]
    mergeable = details.get("mergeable")
    review_decision = details.get("reviewDecision") or "NONE"
    labels = [lbl["name"] for lbl in details.get("labels", [])]

    print("📋 PR Analysis:")
    print(f"  - Number: {pr_number}")
    print(f"  - Author: {author}")
    print(f"  - Branch: {head_branch} → {base_branch}")
    print(f"  - Mergeable: {mergeable}")
    print(f"  - Review Decision: {review_decision}")

    should_auto_merge = False
    reason = ""

    if base_branch not in {"main", "develop"}:
        reason = f"Auto-merge only enabled for main/develop branches (targeting: {base_branch})"
    elif (
        author == "dependabot[bot]"
        or head_branch.startswith("cursor/")
        or head_branch.startswith("codex/")
        or "auto-merge" in labels
    ):
        if mergeable != "MERGEABLE":
            reason = f"PR is not mergeable (state: {mergeable})"
        elif base_branch == "main" and review_decision != "APPROVED":
            reason = f"Main branch requires review approval (current: {review_decision})"
        else:
            should_auto_merge = True
            reason = "PR meets auto-merge criteria"
    else:
        reason = "PR not eligible: not from dependabot/AI agents and no auto-merge label"

    write_output("should-auto-merge", str(should_auto_merge).lower())
    write_output("reason", reason)
    merge_method = "SQUASH" if base_branch == "main" else "MERGE"
    write_output("merge-method", merge_method)

    print(f"🤖 Auto-merge Decision: {should_auto_merge}")
    print(f"📝 Reason: {reason}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
