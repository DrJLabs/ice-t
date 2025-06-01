#!/usr/bin/env python3
"""
Codex Compatibility Checker for Next-Generation Features
Validates environment compatibility and feature availability in sandboxed environments.
"""

from __future__ import annotations

import importlib
from pathlib import Path
import platform
import subprocess
import sys
import urllib.request


class CodexCompatibilityChecker:
    """Check compatibility with Codex's sandboxed environment"""

    def __init__(self):
        self.results = {
            "python_version": None,
            "core_dependencies": {},
            "enhanced_dependencies": {},
            "optional_dependencies": {},
            "sandboxed_features": {},
            "recommendations": [],
        }

    def check_python_version(self) -> bool:
        """Check Python version compatibility"""
        version = sys.version_info
        self.results["python_version"] = (
            f"{version.major}.{version.minor}.{version.micro}"
        )

        if version >= (3, 9):
            print(f"✅ Python {self.results['python_version']} (Compatible)")
            return True
        if version >= (3, 8):
            print(f"⚠️ Python {self.results['python_version']} (Minimum supported)")
            self.results["recommendations"].append(
                "Consider upgrading to Python 3.9+ for best compatibility"
            )
            return True
        print(f"❌ Python {self.results['python_version']} (Incompatible)")
        self.results["recommendations"].append("Upgrade to Python 3.8+ required")
        return False

    def check_core_dependencies(self) -> dict[str, bool]:
        """Check core dependencies required for basic functionality"""
        core_deps = ["pytest", "rich", "click", "pydantic", "ruff", "mypy"]

        print("\n📦 Core Dependencies:")
        for dep in core_deps:
            available = self._check_import(dep)
            self.results["core_dependencies"][dep] = available
            status = "✅" if available else "❌"
            print(f"  {status} {dep}")

            if not available:
                self.results["recommendations"].append(
                    f"Install {dep}: pip install {dep}"
                )

        return self.results["core_dependencies"]

    def check_enhanced_dependencies(self) -> dict[str, bool]:
        """Check enhanced dependencies for next-generation features"""
        enhanced_deps = {
            "numpy": "Enhanced Context Manager basic features",
            "sklearn": "Enhanced Context Manager advanced features",
            "sentence_transformers": "Enhanced Context Manager ML features",
            "faiss": "Enhanced Context Manager semantic search",
            "watchdog": "Real-time file monitoring",
            "psutil": "System monitoring",
            "coverage": "Quality automation",
            "bandit": "Security analysis",
            "safety": "Dependency vulnerability scanning",
        }

        print("\n🧠 Enhanced Dependencies (Next-Generation Features):")
        for dep, description in enhanced_deps.items():
            available = self._check_import(dep)
            self.results["enhanced_dependencies"][dep] = available
            status = "✅" if available else "⚠️"
            print(f"  {status} {dep} - {description}")

            if not available:
                self.results["recommendations"].append(
                    f"Optional: Install {dep} for {description}"
                )

        return self.results["enhanced_dependencies"]

    def check_sandboxed_features(self) -> dict[str, bool]:
        """Check features that work well in sandboxed environments"""
        features = {
            "file_system_access": self._check_file_system(),
            "subprocess_execution": self._check_subprocess(),
            "network_access": self._check_network(),
            "git_operations": self._check_git(),
            "virtual_environment": self._check_venv(),
        }

        print("\n🔒 Sandboxed Environment Features:")
        for feature, available in features.items():
            self.results["sandboxed_features"][feature] = available
            status = "✅" if available else "⚠️"
            print(f"  {status} {feature.replace('_', ' ').title()}")

        return features

    def check_next_generation_compatibility(self) -> dict[str, str]:
        """Check specific next-generation feature compatibility"""
        features = {
            "Enhanced Context Manager v2.0": self._check_context_manager(),
            "AI Agent Wrapper v3.0": self._check_agent_wrapper(),
            "Quality Automation v1.0": self._check_quality_automation(),
        }

        print("\n🚀 Next-Generation Features Compatibility:")
        for feature, status in features.items():
            print(f"  {self._get_status_icon(status)} {feature}: {status}")

        return features

    def _check_import(self, module_name: str) -> bool:
        """Check if a module can be imported"""
        try:
            # Handle special cases
            if module_name == "sklearn":
                importlib.import_module("sklearn")
            elif module_name == "faiss":
                try:
                    importlib.import_module("faiss")
                except ImportError:
                    importlib.import_module("faiss-cpu")
            else:
                importlib.import_module(module_name)
            return True
        except ImportError:
            return False

    def _check_file_system(self) -> bool:
        """Check file system access"""
        try:
            test_file = Path(".codex_test")
            test_file.write_text("test")
            test_file.unlink()
            return True
        except Exception:
            return False

    def _check_subprocess(self) -> bool:
        """Check subprocess execution"""
        try:
            result = subprocess.run(
                ["python3", "--version"],
                capture_output=True,
                text=True,
                timeout=5,
                check=False,
            )
            return result.returncode == 0
        except Exception:
            return False

    def _check_network(self) -> bool:
        """Check network access (limited in sandboxed environments)"""
        try:
            urllib.request.urlopen("https://httpbin.org/get", timeout=2)
            return True
        except Exception:
            return False

    def _check_git(self) -> bool:
        """Check git operations"""
        try:
            result = subprocess.run(
                ["git", "--version"],
                capture_output=True,
                text=True,
                timeout=5,
                check=False,
            )
            return result.returncode == 0
        except Exception:
            return False

    def _check_venv(self) -> bool:
        """Check virtual environment support"""
        return hasattr(sys, "real_prefix") or (
            hasattr(sys, "base_prefix") and sys.base_prefix != sys.prefix
        )

    def _check_context_manager(self) -> str:
        """Check Enhanced Context Manager compatibility"""
        if self.results["enhanced_dependencies"].get(
            "sentence_transformers"
        ) and self.results["enhanced_dependencies"].get("faiss"):
            return "Full ML features available"
        if self.results["enhanced_dependencies"].get("numpy") and self.results[
            "enhanced_dependencies"
        ].get("sklearn"):
            return "Basic features available"
        return "Text-based search only"

    def _check_agent_wrapper(self) -> str:
        """Check AI Agent Wrapper compatibility"""
        if self.results["sandboxed_features"].get("git_operations") and self.results[
            "sandboxed_features"
        ].get("subprocess_execution"):
            return "Full automation available"
        if self.results["sandboxed_features"].get("file_system_access"):
            return "Limited automation available"
        return "Manual mode only"

    def _check_quality_automation(self) -> str:
        """Check Quality Automation compatibility"""
        quality_deps = ["coverage", "bandit", "safety"]
        available_deps = sum(
            1 for dep in quality_deps if self.results["enhanced_dependencies"].get(dep)
        )

        if available_deps >= 3:
            return "Full quality automation"
        if available_deps >= 1:
            return "Partial quality automation"
        return "Basic quality checks only"

    def _get_status_icon(self, status: str) -> str:
        """Get appropriate status icon"""
        if "Full" in status or "available" in status:
            return "✅"
        if "Partial" in status or "Basic" in status or "Limited" in status:
            return "⚠️"
        return "❌"

    def generate_recommendations(self) -> list[str]:
        """Generate specific recommendations for the environment"""
        recommendations = self.results["recommendations"].copy()

        # Add specific recommendations based on results
        core_missing = [
            dep
            for dep, available in self.results["core_dependencies"].items()
            if not available
        ]
        if core_missing:
            recommendations.append(
                f"Priority: Install core dependencies: {', '.join(core_missing)}"
            )

        # Enhanced features recommendations
        if not self.results["enhanced_dependencies"].get("numpy"):
            recommendations.append(
                "For enhanced context: pip install numpy scikit-learn"
            )

        if not self.results["enhanced_dependencies"].get("sentence_transformers"):
            recommendations.append(
                "For ML features: pip install sentence-transformers faiss-cpu"
            )

        # Sandboxed environment specific recommendations
        if not self.results["sandboxed_features"].get("network_access"):
            recommendations.append(
                "Network limited: Use offline mode and local dependencies"
            )

        if not self.results["sandboxed_features"].get("git_operations"):
            recommendations.append(
                "Git limited: Use manual version control or file-based tracking"
            )

        return recommendations

    def run_full_check(self) -> dict:
        """Run complete compatibility check"""
        print("🔍 Codex Compatibility Check for Next-Generation Features")
        print("=" * 60)

        # Core checks
        python_ok = self.check_python_version()
        if not python_ok:
            print("\n❌ Python version incompatible. Please upgrade Python.")
            return self.results

        # Dependency checks
        self.check_core_dependencies()
        self.check_enhanced_dependencies()

        # Environment checks
        self.check_sandboxed_features()

        # Feature compatibility
        self.check_next_generation_compatibility()

        # Generate recommendations
        recommendations = self.generate_recommendations()

        print("\n💡 Recommendations:")
        for i, rec in enumerate(recommendations, 1):
            print(f"  {i}. {rec}")

        # Summary
        core_available = sum(self.results["core_dependencies"].values())
        core_total = len(self.results["core_dependencies"])
        enhanced_available = sum(self.results["enhanced_dependencies"].values())
        enhanced_total = len(self.results["enhanced_dependencies"])

        print("\n📊 Summary:")
        print(f"  Core Dependencies: {core_available}/{core_total}")
        print(f"  Enhanced Dependencies: {enhanced_available}/{enhanced_total}")
        sandboxed_available = sum(self.results["sandboxed_features"].values())
        sandboxed_total = len(self.results["sandboxed_features"])
        print(f"  Sandboxed Features: {sandboxed_available}/{sandboxed_total}")

        if core_available == core_total:
            print("\n✅ Environment is compatible with Codex next-generation features!")
        elif core_available >= core_total * 0.8:
            print(
                "\n⚠️ Environment is mostly compatible. "
                "Install missing core dependencies."
            )
        else:
            print(
                "\n❌ Environment needs significant setup. "
                "Follow recommendations above."
            )

        return self.results


def main():
    """Main function to run compatibility check"""
    checker = CodexCompatibilityChecker()
    results = checker.run_full_check()

    # Save results for later reference
    import json

    results_file = Path(".codex/compatibility_check.json")
    results_file.parent.mkdir(exist_ok=True)

    # Convert results to JSON-serializable format
    json_results = {
        "timestamp": str(sys.version_info),
        "platform": platform.platform(),
        "python_version": results["python_version"],
        "core_dependencies": results["core_dependencies"],
        "enhanced_dependencies": results["enhanced_dependencies"],
        "sandboxed_features": results["sandboxed_features"],
        "recommendations": results["recommendations"],
    }

    with open(results_file, "w") as f:
        json.dump(json_results, f, indent=2)

    print(f"\n📄 Results saved to: {results_file}")

    return (
        0
        if sum(results["core_dependencies"].values())
        >= len(results["core_dependencies"]) * 0.8
        else 1
    )


if __name__ == "__main__":
    sys.exit(main())
