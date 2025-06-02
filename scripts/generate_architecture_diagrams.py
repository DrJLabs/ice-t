#!/usr/bin/env python3
"""
Architecture Diagram Generator for ice-t
Automatically generates visual representations of the project architecture.
"""

import json
from pathlib import Path
import subprocess
from typing import Dict, List


def scan_project_structure() -> Dict[str, List[str]]:
    """Scan the project and build a structure map."""
    structure = {
        "core": [],
        "features": [],
        "utilities": [],
        "integrations": [],
        "workflows": [],
        "scripts": [],
        "tests": [],
    }

    # Scan source code
    src_path = Path("src/ice_t")
    if src_path.exists():
        for module_dir in src_path.iterdir():
            if module_dir.is_dir() and module_dir.name in structure:
                py_files = list(module_dir.glob("**/*.py"))
                structure[module_dir.name] = [
                    f.stem for f in py_files if f.stem != "__init__"
                ]

    # Scan workflows
    workflows_path = Path(".github/workflows")
    if workflows_path.exists():
        structure["workflows"] = [f.stem for f in workflows_path.glob("*.yml")]

    # Scan scripts
    scripts_path = Path("scripts")
    if scripts_path.exists():
        py_scripts = list(scripts_path.glob("**/*.py"))
        sh_scripts = list(scripts_path.glob("**/*.sh"))
        structure["scripts"] = [f.stem for f in py_scripts + sh_scripts]

    # Scan tests
    tests_path = Path("tests")
    if tests_path.exists():
        for test_dir in tests_path.iterdir():
            if test_dir.is_dir():
                test_files = list(test_dir.glob("**/*.py"))
                structure["tests"].extend(
                    [f"{test_dir.name}/{f.stem}" for f in test_files]
                )

    return structure


def generate_mermaid_architecture() -> str:
    """Generate Mermaid diagram for architecture."""
    structure = scan_project_structure()

    mermaid = """graph TB
    subgraph "ice-t Architecture"
        subgraph "Core Layer"
            CORE[Core Modules]
        end

        subgraph "Feature Layer"
            FEAT[Features]
        end

        subgraph "Support Layer"
            UTIL[Utilities]
            INTEG[Integrations]
        end

        subgraph "CI/CD Pipeline"
            WF[Workflows]
            TEST[Tests]
        end

        subgraph "Development Tools"
            SCRIPTS[Scripts]
        end
    end

    %% Connections
    CORE --> FEAT
    UTIL --> CORE
    UTIL --> FEAT
    INTEG --> FEAT
    WF --> TEST
    SCRIPTS --> CORE
    SCRIPTS --> FEAT
    TEST --> CORE
    TEST --> FEAT

    %% Styling
    classDef coreStyle fill:#e1f5fe
    classDef featStyle fill:#f3e5f5
    classDef utilStyle fill:#e8f5e8
    classDef ciStyle fill:#fff3e0

    class CORE coreStyle
    class FEAT featStyle
    class UTIL,INTEG utilStyle
    class WF,TEST,SCRIPTS ciStyle
"""

    return mermaid


def generate_dot_detailed_architecture() -> str:
    """Generate detailed Graphviz DOT diagram."""
    structure = scan_project_structure()

    dot = """digraph ice_t_architecture {
    rankdir=TB;
    node [shape=box, style=filled];

    // Core components
    subgraph cluster_core {
        label="Core Layer";
        style=filled;
        fillcolor=lightblue;
        """

    # Add core modules
    for i, module in enumerate(structure.get("core", [])):
        dot += f'        core_{i} [label="{module}"];\n'

    dot += """    }

    // Feature components
    subgraph cluster_features {
        label="Features Layer";
        style=filled;
        fillcolor=lightgreen;
        """

    # Add feature modules
    for i, module in enumerate(structure.get("features", [])):
        dot += f'        feat_{i} [label="{module}"];\n'

    dot += """    }

    // Utility components
    subgraph cluster_utilities {
        label="Utilities & Integrations";
        style=filled;
        fillcolor=lightyellow;
        """

    # Add utility modules
    for i, module in enumerate(structure.get("utilities", [])):
        dot += f'        util_{i} [label="{module}"];\n'

    for i, module in enumerate(structure.get("integrations", [])):
        dot += f'        integ_{i} [label="{module}"];\n'

    dot += """    }

    // CI/CD components
    subgraph cluster_cicd {
        label="CI/CD & Testing";
        style=filled;
        fillcolor=lightcoral;
        """

    # Add workflows and tests
    for i, workflow in enumerate(structure.get("workflows", [])):
        dot += f'        wf_{i} [label="{workflow}"];\n'

    dot += """    }

    // Add some example connections
    // (In a real implementation, you'd parse imports to find actual dependencies)
}"""

    return dot


def create_plantuml_component_diagram() -> str:
    """Generate PlantUML component diagram."""
    return """@startuml ice-t-components
!define RECTANGLE class

package "ice-t System" {
    package "Core Layer" {
        [Core Modules] as Core
        [Configuration] as Config
        [Base Classes] as Base
    }

    package "Feature Layer" {
        [Features] as Features
        [Business Logic] as BizLogic
    }

    package "Utilities" {
        [Utilities] as Utils
        [Helpers] as Helpers
    }

    package "Integrations" {
        [External APIs] as APIs
        [Third Party] as ThirdParty
    }

    package "CI/CD Pipeline" {
        [GitHub Actions] as GHA
        [Test Runners] as TestRunners
        [Quality Gates] as Quality
    }
}

' Relationships
Core --> Features
Utils --> Core
Utils --> Features
APIs --> Features
ThirdParty --> Features
GHA --> TestRunners
TestRunners --> Core
TestRunners --> Features
Quality --> Core
Quality --> Features

@enduml"""


def generate_diagrams():
    """Generate all architecture diagrams."""
    print("🎨 Generating architecture diagrams...")

    # Create output directory
    docs_dir = Path("docs/diagrams")
    docs_dir.mkdir(parents=True, exist_ok=True)

    # Generate Mermaid diagram
    mermaid_content = generate_mermaid_architecture()
    with open(docs_dir / "architecture_overview.mmd", "w") as f:
        f.write(mermaid_content)

    # Generate DOT diagram
    dot_content = generate_dot_detailed_architecture()
    with open(docs_dir / "detailed_architecture.dot", "w") as f:
        f.write(dot_content)

    # Generate PlantUML diagram
    plantuml_content = create_plantuml_component_diagram()
    with open(docs_dir / "component_diagram.puml", "w") as f:
        f.write(plantuml_content)

    # Try to render diagrams if tools are available
    try:
        # Render DOT to PNG
        subprocess.run(
            [
                "dot",
                "-Tpng",
                str(docs_dir / "detailed_architecture.dot"),
                "-o",
                str(docs_dir / "detailed_architecture.png"),
            ],
            check=True,
            capture_output=True,
        )
        print("✅ Generated detailed_architecture.png")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("⚠️  Graphviz not available, skipping DOT rendering")

    try:
        # Render PlantUML to PNG
        subprocess.run(
            ["plantuml", "-tpng", str(docs_dir / "component_diagram.puml")],
            check=True,
            capture_output=True,
        )
        print("✅ Generated component_diagram.png")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("⚠️  PlantUML not available, skipping PlantUML rendering")

    # Create project statistics
    structure = scan_project_structure()
    stats = {
        "total_modules": sum(len(modules) for modules in structure.values()),
        "core_modules": len(structure.get("core", [])),
        "feature_modules": len(structure.get("features", [])),
        "utility_modules": len(structure.get("utilities", [])),
        "integration_modules": len(structure.get("integrations", [])),
        "workflows": len(structure.get("workflows", [])),
        "test_files": len(structure.get("tests", [])),
        "scripts": len(structure.get("scripts", [])),
    }

    with open(docs_dir / "project_stats.json", "w") as f:
        json.dump(stats, f, indent=2)

    print(f"📊 Project Statistics: {stats['total_modules']} total modules")
    print("✅ Architecture diagrams generated successfully!")


if __name__ == "__main__":
    generate_diagrams()
