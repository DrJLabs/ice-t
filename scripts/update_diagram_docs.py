#!/usr/bin/env python3
"""
Documentation Updater for ice-t
Updates README and documentation with auto-generated diagrams.
"""

from datetime import datetime
import json
from pathlib import Path


def update_readme_with_diagrams():
    """Update README.md with diagram links and project stats."""
    readme_path = Path("README.md")
    docs_dir = Path("docs/diagrams")

    if not readme_path.exists():
        print("⚠️  README.md not found, creating basic one...")
        create_basic_readme()
        return

    # Read current README
    with open(readme_path) as f:
        content = f.read()

    # Generate diagrams section
    diagrams_section = generate_diagrams_section()
    stats_section = generate_stats_section()

    # Look for existing sections to replace
    if "## 📊 Project Architecture" in content:
        # Replace existing section
        lines = content.split("\n")
        start_idx = None
        end_idx = None

        for i, line in enumerate(lines):
            if line.startswith("## 📊 Project Architecture"):
                start_idx = i
            elif (
                start_idx is not None
                and line.startswith("## ")
                and not line.startswith("## 📊")
            ):
                end_idx = i
                break

        if start_idx is not None:
            if end_idx is not None:
                lines = (
                    lines[:start_idx] + diagrams_section.split("\n") + lines[end_idx:]
                )
            else:
                lines = lines[:start_idx] + diagrams_section.split("\n")

            content = "\n".join(lines)
    else:
        # Add new section before any existing "##" sections or at the end
        lines = content.split("\n")
        insert_idx = len(lines)

        for i, line in enumerate(lines):
            if line.startswith("## ") and i > 0:  # Skip the first title
                insert_idx = i
                break

        lines.insert(insert_idx, diagrams_section)
        content = "\n".join(lines)

    # Add stats badge if not present
    if "![Project Stats]" not in content and docs_dir.exists():
        stats_badge = f"\n{stats_section}\n"
        content = content.replace("# ice-t", f"# ice-t\n{stats_badge}")

    # Write updated README
    with open(readme_path, "w") as f:
        f.write(content)

    print("✅ README.md updated with diagrams and stats")


def create_basic_readme():
    """Create a basic README if none exists."""
    readme_content = """# ice-t
Autonomous high-performance template for web-app projects driven by Cursor & Codex.

## 🚀 Quick Start

```bash
# Setup development environment
./scripts/setup/setup_env.sh

# Run tests
source .venv/bin/activate
python scripts/adaptive_test_runner.py run --level full
```

## 📊 Project Architecture

> Diagrams are auto-generated and updated on each commit.

### Architecture Overview
![Architecture Overview](docs/diagrams/architecture_overview.mmd)

### CI/CD Pipeline
![CI Pipeline](docs/diagrams/ci_pipeline_flow.mmd)

### Runner Configuration
![Runner Mapping](docs/diagrams/runner_mapping.mmd)

## 🧪 Testing

The project uses an adaptive test runner with ≥94% coverage baseline:

- **Smoke Tests**: Quick validation
- **Unit Tests**: Component testing
- **Integration Tests**: End-to-end workflows
- **Security Tests**: Code security scanning

## 🏗️ Development

ice-t follows a modular architecture:

- `src/ice_t/core/` - Core functionality
- `src/ice_t/features/` - Feature implementations
- `src/ice_t/utilities/` - Utility functions
- `src/ice_t/integrations/` - External integrations

## 🚀 CI/CD

The project uses 7 self-hosted runners for 6-way parallel testing:

1. **Build & Setup** (`ice-t-runner-1`)
2. **Smoke Tests** (`ice-t-runner-2`)
3. **Unit Tests** (`ice-t-runner-3`)
4. **Integration Tests** (`ice-t-runner-4`)
5. **Quality & Security** (`ice-t-runner-5`)
6. **API Tests** (`ice-t-runner-6`)
7. **Diagram Generation** (`ice-t-runner-7`)

## 📈 Project Statistics

Statistics are auto-generated from the codebase and updated automatically.
"""

    with open("README.md", "w") as f:
        f.write(readme_content)

    print("✅ Created basic README.md")


def generate_diagrams_section() -> str:
    """Generate the diagrams section for README."""
    docs_dir = Path("docs/diagrams")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M UTC")

    section = f"""## 📊 Project Architecture

> Auto-generated diagrams updated on {timestamp}

### 🏗️ System Architecture
```mermaid
graph TB
    subgraph "ice-t System"
        subgraph "Core Layer"
            CORE[Core Modules]
        end

        subgraph "Feature Layer"
            FEAT[Features]
        end

        subgraph "CI/CD Pipeline"
            RUNNERS[7 Self-Hosted Runners]
            WORKFLOWS[Automated Workflows]
        end
    end

    CORE --> FEAT
    RUNNERS --> WORKFLOWS
    WORKFLOWS --> CORE
    WORKFLOWS --> FEAT
```

### 📋 Available Diagrams

"""

    if docs_dir.exists():
        diagram_files = {
            "architecture_overview.mmd": "🏗️ System Architecture Overview",
            "ci_pipeline_flow.mmd": "🔄 CI/CD Pipeline Flow",
            "runner_mapping.mmd": "🏃 Runner Assignment Map",
            "dependency_overview.mmd": "📦 Dependency Graph",
            "detailed_architecture.png": "🎯 Detailed Architecture",
            "component_diagram.png": "🧩 Component Diagram",
        }

        for filename, description in diagram_files.items():
            filepath = docs_dir / filename
            if filepath.exists():
                if filename.endswith(".mmd"):
                    section += f"- **{description}**: [View Mermaid Source](docs/diagrams/{filename})\n"
                else:
                    section += f"- **{description}**: ![{description}](docs/diagrams/{filename})\n"

    section += "\n### 🔄 Diagram Generation\n\n"
    section += "Diagrams are automatically generated when:\n"
    section += "- Code is pushed to `main` or `develop`\n"
    section += "- Pull requests are created\n"
    section += "- Manual workflow dispatch is triggered\n"
    section += "\nGeneration runs on `ice-t-runner-7` with labels: `diagrams`, `documentation`, `visualization`\n"

    return section


def generate_stats_section() -> str:
    """Generate project statistics section."""
    stats_files = [
        "docs/diagrams/project_stats.json",
        "docs/diagrams/workflow_metadata.json",
        "docs/diagrams/dependency_analysis.json",
    ]

    stats = {}
    for stats_file in stats_files:
        if Path(stats_file).exists():
            with open(stats_file) as f:
                file_stats = json.load(f)
                stats.update(file_stats)

    if not stats:
        return (
            "![Project Status](https://img.shields.io/badge/status-active-brightgreen)"
        )

    badges = []

    # Add module count badge
    if "total_modules" in stats:
        badges.append(
            f"![Modules](https://img.shields.io/badge/modules-{stats['total_modules']}-blue)"
        )

    # Add package count badge
    if "total_external_packages" in stats:
        badges.append(
            f"![Dependencies](https://img.shields.io/badge/dependencies-{stats['total_external_packages']}-orange)"
        )

    # Add workflow count badge
    if "total_workflows" in stats:
        badges.append(
            f"![Workflows](https://img.shields.io/badge/workflows-{stats['total_workflows']}-purple)"
        )

    # Add runner count badge
    badges.append("![Runners](https://img.shields.io/badge/runners-7-green)")

    # Add coverage badge (assuming ≥94% target)
    badges.append(
        "![Coverage](https://img.shields.io/badge/coverage-%E2%89%A594%25-brightgreen)"
    )

    return " ".join(badges)


def create_docs_index():
    """Create or update docs/index.md with diagram links."""
    docs_dir = Path("docs")
    docs_dir.mkdir(exist_ok=True)

    index_content = f"""# ice-t Documentation

Auto-generated on {datetime.now().strftime("%Y-%m-%d %H:%M UTC")}

## 📊 Architecture Diagrams

### System Overview
- [Architecture Overview](diagrams/architecture_overview.mmd) - High-level system structure
- [Component Diagram](diagrams/component_diagram.puml) - Detailed component relationships

### CI/CD Pipeline
- [Pipeline Flow](diagrams/ci_pipeline_flow.mmd) - Complete CI/CD workflow
- [Runner Mapping](diagrams/runner_mapping.mmd) - Self-hosted runner assignments
- [Workflow Dependencies](diagrams/workflow_dependencies.dot) - Workflow trigger relationships

### Dependencies
- [Dependency Overview](diagrams/dependency_overview.mmd) - Package and module dependencies
- [Dependency Network](diagrams/dependency_network.dot) - Detailed dependency graph
- [Package Tree](diagrams/package_tree.txt) - Hierarchical package view

## 📈 Statistics

### Project Metrics
"""

    # Add statistics if available
    stats_file = Path("docs/diagrams/project_stats.json")
    if stats_file.exists():
        with open(stats_file) as f:
            stats = json.load(f)

        index_content += f"""
- **Total Modules**: {stats.get("total_modules", "Unknown")}
- **Core Modules**: {stats.get("core_modules", "Unknown")}
- **Feature Modules**: {stats.get("feature_modules", "Unknown")}
- **Test Files**: {stats.get("test_files", "Unknown")}
- **Scripts**: {stats.get("scripts", "Unknown")}
"""

    index_content += """
## 🔄 Auto-Generation

These diagrams are automatically updated by the `ice-t-runner-7` when:
- Code is pushed to main/develop branches
- Pull requests are created or updated
- Manual workflow dispatch is triggered

The generation process analyzes:
- Source code structure and imports
- GitHub Actions workflows
- Package dependencies
- Test organization
- Script relationships
"""

    with open(docs_dir / "index.md", "w") as f:
        f.write(index_content)

    print("✅ Created/updated docs/index.md")


def main():
    """Main function to update all documentation."""
    print("📚 Updating documentation with generated diagrams...")

    # Update README
    update_readme_with_diagrams()

    # Create/update docs index
    create_docs_index()

    print("✅ Documentation updated successfully!")


if __name__ == "__main__":
    main()
