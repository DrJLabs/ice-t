# AI Agent Guidance Overview

This repository uses a hierarchical guidance system for human and AI contributors, particularly the ChatGPT Codex agent. This document serves as the entry point and index to this guidance.

The [AI Charter](agents/charter/AI_CHARTER.md) (see below) describes the agent's primary role as a **Senior Python Full-Stack Developer**. Key responsibilities include modernizing the project by implementing features, fixing bugs, and diligently keeping tests and documentation current and comprehensive.

## Key Guiding Documents

-   **[AI Charter](agents/charter/AI_CHARTER.md)** (`agents/charter/AI_CHARTER.md`): The foundational document. It outlines the agent's mission, high-level operational guidelines, core principles, responsibilities, and resources for CI failure analysis.
-   **[Modernization Plan](CODEX_T_MODERNIZATION_PLAN.md)** (`CODEX_T_MODERNIZATION_PLAN.md`): Provides the overall strategic context and goals for the project's ongoing modernization efforts.

## Detailed Guidance Directory Structure

The primary guidance directories are structured as follows:

-   **`agents/core/`**: Contains fundamental protocols, high-level rules, and core principles that complement and expand upon the AI Charter.
-   **`agents/conventions/`**: Specifies detailed coding conventions, style guides, and instructions for tool usage (including, for example, how to run `scripts/adaptive_test_runner.py`).
-   **`agents/playbooks/`**: Provides step-by-step instructions (playbooks) for common development tasks, feature implementation processes, bug fixing procedures, and other routine operations.
-   **`agents/features/`**: Offers established best practices, architectural patterns, and domain-specific guides relevant to implementing various types of features within the project.

## Supporting Documentation

-   **CI Logging and Metrics System** (`docs/CI_LOGGING_SYSTEM.md`): Details the architecture and usage of the logging and metrics system integrated into the CI pipeline. This system is also referenced within the AI Charter.

**Always consult these guides thoroughly before initiating or modifying code or documentation. This ensures alignment with project standards, architectural consistency, and the agent's operational protocols.**
