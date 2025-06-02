#!/usr/bin/env python3
"""
Workflow Diagram Generator for ice-t
Generates visual representations of CI/CD workflows and runner relationships.
"""

import json
from pathlib import Path

import yaml


def parse_workflow_files() -> dict:
    """Parse all GitHub Actions workflow files."""
    workflows = {}
    workflows_dir = Path(".github/workflows")

    if not workflows_dir.exists():
        return workflows

    for workflow_file in workflows_dir.glob("*.yml"):
        try:
            with open(workflow_file) as f:
                workflow_data = yaml.safe_load(f)
                workflows[workflow_file.stem] = workflow_data
        except Exception as e:
            print(f"Warning: Could not parse {workflow_file}: {e}")

    return workflows


def generate_runner_mapping() -> str:
    """Generate Mermaid diagram showing runner assignments."""
    mermaid = """graph LR
    subgraph "ice-t Self-Hosted Runners"
        R1["🏗️ ice-t-runner-1<br/>build,setup"]
        R2["💨 ice-t-runner-2<br/>test,smoke"]
        R3["🧪 ice-t-runner-3<br/>test,unit"]
        R4["🔗 ice-t-runner-4<br/>test,integration"]
        R5["🔒 ice-t-runner-5<br/>quality,security"]
        R6["🌐 ice-t-runner-6<br/>test,api"]
        R7["📊 ice-t-runner-7<br/>diagrams,docs"]
    end

    subgraph "Workflow Jobs"
        BUILD["Build & Setup"]
        SMOKE["Smoke Tests"]
        UNIT["Unit Tests"]
        INTEG["Integration Tests"]
        QUALITY["Quality & Security"]
        API["API Tests"]
        DIAG["Generate Diagrams"]
    end

    subgraph "Triggers"
        PUSH["Push to main/develop"]
        PR["Pull Request"]
        SCHEDULE["Scheduled"]
        MANUAL["Manual Dispatch"]
    end

    %% Runner assignments
    R1 --> BUILD
    R2 --> SMOKE
    R3 --> UNIT
    R4 --> INTEG
    R5 --> QUALITY
    R6 --> API
    R7 --> DIAG

    %% Trigger relationships
    PUSH --> BUILD
    PUSH --> SMOKE
    PUSH --> UNIT
    PUSH --> INTEG
    PUSH --> QUALITY
    PUSH --> API
    PUSH --> DIAG

    PR --> BUILD
    PR --> SMOKE
    PR --> UNIT
    PR --> INTEG
    PR --> QUALITY
    PR --> DIAG

    SCHEDULE --> QUALITY
    MANUAL --> DIAG

    %% Styling
    classDef runnerStyle fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef jobStyle fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef triggerStyle fill:#e8f5e8,stroke:#388e3c,stroke-width:2px

    class R1,R2,R3,R4,R5,R6,R7 runnerStyle
    class BUILD,SMOKE,UNIT,INTEG,QUALITY,API,DIAG jobStyle
    class PUSH,PR,SCHEDULE,MANUAL triggerStyle
"""

    return mermaid


def generate_ci_pipeline_flow() -> str:
    """Generate CI/CD pipeline flow diagram."""
    mermaid = """graph TD
    START([Code Push/PR]) --> VALIDATE{Validation}

    VALIDATE -->|✅ Pass| PARALLEL[Parallel Execution]
    VALIDATE -->|❌ Fail| FAIL([❌ Pipeline Failed])

    PARALLEL --> BUILD[🏗️ Build & Setup]
    PARALLEL --> SMOKE[💨 Smoke Tests]
    PARALLEL --> UNIT[🧪 Unit Tests]
    PARALLEL --> INTEG[🔗 Integration Tests]
    PARALLEL --> QUALITY[🔒 Quality & Security]
    PARALLEL --> API[🌐 API Tests]
    PARALLEL --> DIAGRAMS[📊 Generate Diagrams]

    BUILD --> COLLECT{Collect Results}
    SMOKE --> COLLECT
    UNIT --> COLLECT
    INTEG --> COLLECT
    QUALITY --> COLLECT
    API --> COLLECT
    DIAGRAMS --> COLLECT

    COLLECT -->|All Pass| SUCCESS[✅ All Checks Passed]
    COLLECT -->|Any Fail| PARTIAL[⚠️ Some Checks Failed]

    SUCCESS --> MERGE{Auto-Merge?}
    PARTIAL --> BLOCK[🚫 Block Merge]

    MERGE -->|main branch| AUTOMERGE[🚀 Auto-Merge]
    MERGE -->|develop branch| MANUAL[👤 Manual Review]

    AUTOMERGE --> DEPLOY[🚀 Deploy]
    MANUAL --> REVIEW[👀 Code Review]
    REVIEW --> MANUALMERGE[✅ Manual Merge]

    BLOCK --> FIXREQUIRED[🔧 Fix Required]
    FIXREQUIRED --> START

    %% Failure handling
    FAIL --> REVERT{On main?}
    REVERT -->|Yes| AUTOREVERT[🔄 Auto-Revert]
    REVERT -->|No| NOTIFY[📧 Notify Author]

    %% Styling
    classDef startStyle fill:#e8f5e8,stroke:#4caf50,stroke-width:3px
    classDef processStyle fill:#e3f2fd,stroke:#2196f3,stroke-width:2px
    classDef decisionStyle fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    classDef successStyle fill:#e8f5e8,stroke:#4caf50,stroke-width:3px
    classDef failStyle fill:#ffebee,stroke:#f44336,stroke-width:3px

    class START startStyle
    class BUILD,SMOKE,UNIT,INTEG,QUALITY,API,DIAGRAMS,DEPLOY processStyle
    class VALIDATE,COLLECT,MERGE,REVERT decisionStyle
    class SUCCESS,AUTOMERGE,DEPLOY successStyle
    class FAIL,PARTIAL,BLOCK,AUTOREVERT failStyle
"""

    return mermaid


def create_workflow_dependency_graph() -> str:
    """Create a dependency graph of workflows."""
    workflows = parse_workflow_files()

    dot = """digraph workflow_dependencies {
    rankdir=TB;
    node [shape=box, style=filled];

    // Define workflow nodes
    """

    for workflow_name, workflow_data in workflows.items():
        dot += f'    "{workflow_name}" [fillcolor=lightblue];\n'

    dot += """
    // Add trigger relationships
    subgraph cluster_triggers {
        label="Triggers";
        style=filled;
        fillcolor=lightgreen;

        "push" [shape=ellipse];
        "pull_request" [shape=ellipse];
        "workflow_dispatch" [shape=ellipse];
        "schedule" [shape=ellipse];
    }

    // Connect triggers to workflows
    """

    for workflow_name, workflow_data in workflows.items():
        if "on" in workflow_data:
            triggers = workflow_data["on"]
            if isinstance(triggers, dict):
                for trigger in triggers.keys():
                    dot += f'    "{trigger}" -> "{workflow_name}";\n'
            elif isinstance(triggers, list):
                for trigger in triggers:
                    dot += f'    "{trigger}" -> "{workflow_name}";\n'

    dot += "}"

    return dot


def generate_diagrams():
    """Generate all workflow diagrams."""
    print("🔄 Generating workflow diagrams...")

    # Create output directory
    docs_dir = Path("docs/diagrams")
    docs_dir.mkdir(parents=True, exist_ok=True)

    # Generate runner mapping diagram
    runner_mapping = generate_runner_mapping()
    with open(docs_dir / "runner_mapping.mmd", "w") as f:
        f.write(runner_mapping)

    # Generate CI pipeline flow
    pipeline_flow = generate_ci_pipeline_flow()
    with open(docs_dir / "ci_pipeline_flow.mmd", "w") as f:
        f.write(pipeline_flow)

    # Generate workflow dependency graph
    workflow_deps = create_workflow_dependency_graph()
    with open(docs_dir / "workflow_dependencies.dot", "w") as f:
        f.write(workflow_deps)

    # Parse and save workflow metadata
    workflows = parse_workflow_files()
    workflow_metadata = {"total_workflows": len(workflows), "workflows": {}}

    for name, data in workflows.items():
        jobs = data.get("jobs", {})
        triggers = data.get("on", {})

        workflow_metadata["workflows"][name] = {
            "jobs": list(jobs.keys()),
            "job_count": len(jobs),
            "triggers": list(triggers.keys())
            if isinstance(triggers, dict)
            else triggers,
            "has_self_hosted": any(
                isinstance(job.get("runs-on"), list)
                and any("self-hosted" in str(runner) for runner in job["runs-on"])
                for job in jobs.values()
            ),
        }

    with open(docs_dir / "workflow_metadata.json", "w") as f:
        json.dump(workflow_metadata, f, indent=2)

    print(f"📊 Found {len(workflows)} workflow files")
    print("✅ Workflow diagrams generated successfully!")


if __name__ == "__main__":
    generate_diagrams()
