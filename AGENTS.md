
# Agents Documentation Index
 repository provides detailed guides for human and AI contributors. Start here to understand the hierarchy and where to find specific rules.

## Hierarchy

- **AI Charter** (`agents/charter/AI_CHARTER.md`) – mission guidelines and CI failure analysis resources.
- **Conventions** (`agents/conventions/`) – coding conventions and tool usage, including how to run `scripts/adaptive_test_runner.py`.
- **Playbooks** (`agents/playbooks/`) – step-by-step instructions for implementing features and other tasks.

Additional information about the CI logging and metrics system lives in `docs/CI_LOGGING_SYSTEM.md` and is referenced from the charter.

Always consult these guides before modifying code or documentation.

# AI Agent Overview

This repository uses a hierarchical guidance system for the ChatGPT Codex agent.
The [AI Charter](agents/charter/AI_CHARTER.md) describes the agent as a **Senior
Python Full-Stack Developer** responsible for modernizing the project by
implementing features, fixing bugs, and keeping tests and documentation current.

## Hierarchical Structure

- `agents/core/` – core protocols and high‑level rules.
- `agents/conventions/` – coding conventions and tool usage.
- `agents/playbooks/` – task‑specific playbooks.
- `agents/features/` – feature patterns and domain guides.

Detailed rules reside within these subdirectories, while this file provides the
entry point.

For overall modernization context, see
[CODEX_T_MODERNIZATION_PLAN.md](CODEX_T_MODERNIZATION_PLAN.md).
>
