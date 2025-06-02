#!/usr/bin/env python3
"""
Dependency Graph Generator for ice-t
Generates visual representations of code and system dependencies.
"""

import ast
import json
from pathlib import Path
import subprocess
from typing import Dict, Set


def scan_python_imports(file_path: Path) -> Set[str]:
    """Extract imports from a Python file."""
    try:
        with open(file_path, encoding="utf-8") as f:
            content = f.read()

        tree = ast.parse(content)
        imports = set()

        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.add(alias.name.split(".")[0])
            elif isinstance(node, ast.ImportFrom):
                if node.module:
                    imports.add(node.module.split(".")[0])

        return imports
    except Exception as e:
        print(f"Warning: Could not parse {file_path}: {e}")
        return set()


def build_dependency_graph() -> Dict[str, Dict[str, Set[str]]]:
    """Build a complete dependency graph for the project."""
    dependencies = {
        "internal": {},  # Internal module dependencies
        "external": {},  # External package dependencies
        "system": {},  # System/script dependencies
    }

    # Scan source code
    src_path = Path("src/ice_t")
    if src_path.exists():
        for py_file in src_path.rglob("*.py"):
            if py_file.name == "__init__.py":
                continue

            relative_path = py_file.relative_to(src_path)
            module_name = str(relative_path.with_suffix(""))

            imports = scan_python_imports(py_file)

            # Separate internal and external imports
            internal_imports = {imp for imp in imports if imp.startswith("ice_t")}
            external_imports = (
                imports
                - internal_imports
                - {"os", "sys", "json", "typing", "pathlib", "subprocess"}
            )

            dependencies["internal"][module_name] = internal_imports
            dependencies["external"][module_name] = external_imports

    # Scan scripts
    scripts_path = Path("scripts")
    if scripts_path.exists():
        for py_file in scripts_path.rglob("*.py"):
            imports = scan_python_imports(py_file)
            script_name = f"scripts/{py_file.relative_to(scripts_path)}"
            dependencies["system"][script_name] = imports

    return dependencies


def parse_requirements() -> Dict[str, str]:
    """Parse requirements.txt files to get package versions."""
    packages = {}

    for req_file in ["requirements.txt", "dev-requirements.txt"]:
        if Path(req_file).exists():
            with open(req_file) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#"):
                        if ">=" in line:
                            name, version = line.split(">=")
                            packages[name.strip()] = version.strip()
                        elif "==" in line:
                            name, version = line.split("==")
                            packages[name.strip()] = version.strip()
                        else:
                            packages[line] = "latest"

    return packages


def generate_mermaid_dependency_graph() -> str:
    """Generate Mermaid diagram for dependencies."""
    dependencies = build_dependency_graph()
    packages = parse_requirements()

    mermaid = """graph TD
    subgraph "External Dependencies"
        pytest["pytest (testing)"]
        ruff["ruff (linting)"]
        mypy["mypy (type checking)"]
        pydantic["pydantic (data validation)"]
        rich["rich (CLI output)"]
    end

    subgraph "ice-t Core"
        core["Core Modules"]
        features["Features"]
        utils["Utilities"]
        integrations["Integrations"]
    end

    subgraph "Development Tools"
        scripts["Scripts"]
        tests["Tests"]
        workflows["CI/CD Workflows"]
    end

    subgraph "Documentation"
        diagrams["Auto-Generated Diagrams"]
        docs["Documentation"]
    end

    %% External dependencies
    pytest --> tests
    ruff --> workflows
    mypy --> workflows
    pydantic --> core
    rich --> scripts

    %% Internal dependencies
    core --> features
    utils --> core
    utils --> features
    integrations --> features
    scripts --> core
    scripts --> features
    tests --> core
    tests --> features
    workflows --> tests
    workflows --> scripts
    diagrams --> docs

    %% Styling
    classDef external fill:#ffeb3b,stroke:#f57c00,stroke-width:2px
    classDef internal fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef tools fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef docs fill:#e8f5e8,stroke:#388e3c,stroke-width:2px

    class pytest,ruff,mypy,pydantic,rich external
    class core,features,utils,integrations internal
    class scripts,tests,workflows tools
    class diagrams,docs docs
"""

    return mermaid


def create_dot_dependency_network() -> str:
    """Create detailed DOT graph of dependencies."""
    dependencies = build_dependency_graph()
    packages = parse_requirements()

    dot = """digraph dependency_network {
    rankdir=TB;
    node [shape=box, style=filled];

    // External packages
    subgraph cluster_external {
        label="External Dependencies";
        style=filled;
        fillcolor=lightyellow;
        """

    for package, version in packages.items():
        dot += f'        "{package}" [label="{package}\\n{version}"];\n'

    dot += """    }

    // Internal modules
    subgraph cluster_internal {
        label="Internal Modules";
        style=filled;
        fillcolor=lightblue;
        """

    for module in dependencies["internal"].keys():
        dot += f'        "{module}" [fillcolor=lightblue];\n'

    dot += """    }

    // Scripts and tools
    subgraph cluster_tools {
        label="Scripts & Tools";
        style=filled;
        fillcolor=lightgreen;
        """

    for script in dependencies["system"].keys():
        dot += f'        "{script}" [fillcolor=lightgreen];\n'

    dot += """    }

    // Add dependency relationships
    """

    # Add internal dependencies
    for module, deps in dependencies["internal"].items():
        for dep in deps:
            dot += f'    "{dep}" -> "{module}";\n'

    # Add external dependencies (sample - would need more analysis for real deps)
    common_deps = ["pytest", "ruff", "mypy", "pydantic", "rich"]
    for dep in common_deps:
        if dep in packages:
            dot += f'    "{dep}" -> "core";\n'

    dot += "}"

    return dot


def generate_package_dependency_tree() -> str:
    """Generate a simple tree view of dependencies."""
    packages = parse_requirements()

    tree = "ice-t Package Dependencies\n"
    tree += "==========================\n\n"

    categories = {
        "Testing": [
            "pytest",
            "pytest-cov",
            "pytest-mock",
            "pytest-asyncio",
            "pytest-xdist",
        ],
        "Code Quality": ["ruff", "mypy", "bandit", "safety", "pre-commit"],
        "Core Libraries": ["pydantic", "rich", "typer", "click"],
        "Development": ["tox", "build", "setuptools", "wheel"],
    }

    for category, category_packages in categories.items():
        tree += f"{category}:\n"
        for package in category_packages:
            if package in packages:
                tree += f"  ├── {package} ({packages[package]})\n"
        tree += "\n"

    # Add any remaining packages
    used_packages = set()
    for cat_packages in categories.values():
        used_packages.update(cat_packages)

    remaining = set(packages.keys()) - used_packages
    if remaining:
        tree += "Other Dependencies:\n"
        for package in sorted(remaining):
            tree += f"  ├── {package} ({packages[package]})\n"

    return tree


def generate_diagrams():
    """Generate all dependency diagrams."""
    print("📈 Generating dependency graphs...")

    # Create output directory
    docs_dir = Path("docs/diagrams")
    docs_dir.mkdir(parents=True, exist_ok=True)

    # Generate Mermaid dependency graph
    mermaid_deps = generate_mermaid_dependency_graph()
    with open(docs_dir / "dependency_overview.mmd", "w") as f:
        f.write(mermaid_deps)

    # Generate DOT dependency network
    dot_deps = create_dot_dependency_network()
    with open(docs_dir / "dependency_network.dot", "w") as f:
        f.write(dot_deps)

    # Generate package tree
    package_tree = generate_package_dependency_tree()
    with open(docs_dir / "package_tree.txt", "w") as f:
        f.write(package_tree)

    # Build full dependency analysis
    dependencies = build_dependency_graph()
    packages = parse_requirements()

    analysis = {
        "total_external_packages": len(packages),
        "total_internal_modules": len(dependencies["internal"]),
        "total_scripts": len(dependencies["system"]),
        "package_categories": {
            "testing": len([p for p in packages if "test" in p.lower()]),
            "quality": len(
                [
                    p
                    for p in packages
                    if any(q in p.lower() for q in ["ruff", "mypy", "bandit", "safety"])
                ]
            ),
            "core": len(
                [p for p in packages if p in ["pydantic", "rich", "typer", "click"]]
            ),
        },
        "external_packages": packages,
        "internal_structure": {
            module: list(deps) for module, deps in dependencies["internal"].items()
        },
    }

    with open(docs_dir / "dependency_analysis.json", "w") as f:
        json.dump(analysis, f, indent=2)

    # Try to render DOT diagram
    try:
        subprocess.run(
            [
                "dot",
                "-Tpng",
                str(docs_dir / "dependency_network.dot"),
                "-o",
                str(docs_dir / "dependency_network.png"),
            ],
            check=True,
            capture_output=True,
        )
        print("✅ Generated dependency_network.png")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("⚠️  Graphviz not available for DOT rendering")

    print(f"📊 Analyzed {len(packages)} external packages")
    print(f"📊 Found {len(dependencies['internal'])} internal modules")
    print("✅ Dependency graphs generated successfully!")


if __name__ == "__main__":
    generate_diagrams()
