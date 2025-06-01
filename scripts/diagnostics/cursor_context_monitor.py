#!/usr/bin/env python3
"""
Cursor Context Monitor - Diagnostic tool for "chat too long" issues
Estimates token usage of Cursor configuration files.
"""

import json
from pathlib import Path
from typing import Dict, List


def estimate_tokens(text: str) -> int:
    """
    Robust token estimation with edge case protection.

    Edge case fix: Handle unparseable objects that could cause
    token count ≈ ∞ → guardrail fires instantly.
    """
    try:
        # Ensure we have a string
        if not isinstance(text, str):
            # If it's not a string, try to convert safely
            try:
                if text is None:
                    return 0
                # Convert to string safely
                text = str(text)
            except (RecursionError, RuntimeError, MemoryError):
                # Handle recursive or memory issues during conversion
                return 1
            except Exception:
                # If conversion fails, return minimal token count
                return 1

        # Check for empty or whitespace-only text
        if not text or not text.strip():
            return 0

        # Protect against extremely long strings that might be corrupted
        if len(text) > 10_000_000:  # 10MB limit
            print(
                f"⚠️ Warning: Text length {len(text):,} exceeds safe limit, truncating for token estimation"
            )
            text = text[:10_000_000]

        # Rough token estimation: ~3.5 chars per token for English text
        token_count = len(text) // 3

        # Sanity check: ensure token count is reasonable
        if token_count < 0:
            return 0
        if token_count > 5_000_000:  # ~5M token limit
            print(
                f"⚠️ Warning: Token count {token_count:,} seems unreasonably high, capping at 5M"
            )
            return 5_000_000

        return token_count

    except (RecursionError, RuntimeError, MemoryError):
        print("❌ Critical error in token estimation (memory/recursion)")
        return 1
    except Exception as e:
        print(f"❌ Error in token estimation: {e}")
        # Return a safe fallback value instead of crashing
        return 1


def analyze_cursor_config() -> Dict[str, int]:
    """Analyze current Cursor configuration token usage."""
    results = {}

    # Check main configuration files
    config_files = [
        ".cursorrules",
        ".cursor/config.md",
    ]  # .cursor/config-claude.md disabled

    for file_path in config_files:
        path = Path(file_path)
        if path.exists():
            content = path.read_text()
            tokens = estimate_tokens(content)
            results[file_path] = tokens
            print(f"📄 {file_path}: {len(content):,} chars → ~{tokens:,} tokens")

    # Check rule files
    rules_dir = Path(".cursor/rules")
    if rules_dir.exists():
        total_rules_tokens = 0
        print("\n📁 Rule Files:")

        for rule_file in sorted(rules_dir.glob("*.mdc")):
            content = rule_file.read_text()
            tokens = estimate_tokens(content)
            total_rules_tokens += tokens
            print(f"   {rule_file.name}: {len(content):,} chars → ~{tokens:,} tokens")

        results["rules_total"] = total_rules_tokens

    return results


def check_cursor_settings() -> Dict:
    """Check Cursor system settings for problematic configurations."""
    settings_path = Path.home() / ".config/Cursor/User/settings.json"

    if not settings_path.exists():
        return {"error": "Cursor settings not found"}

    try:
        with open(settings_path) as f:
            settings = json.load(f)

        problematic_settings = []
        good_settings = []

        # Check for settings that might cause context issues
        if settings.get("update.releaseTrack") == "prerelease":
            problematic_settings.append("Using prerelease track (may have bugs)")
        elif settings.get("update.releaseTrack") == "stable":
            good_settings.append("Using stable release track")

        if not settings.get("cursor.composer.backspaceRemoveContext", True):
            problematic_settings.append("Context accumulation enabled")
        else:
            good_settings.append("Context cleanup on backspace enabled")

        # Check token limits - NEW ANALYSIS
        max_tokens = settings.get("cursor.chat.maxContextTokens", 0)
        if max_tokens < 50000:
            problematic_settings.append(
                f"Token limit too low: {max_tokens} (may trigger buggy summarization)"
            )
        elif max_tokens >= 100000:
            good_settings.append(f"Adequate token limit: {max_tokens:,}")
        else:
            problematic_settings.append(
                f"Token limit moderate: {max_tokens} (consider increasing for better performance)"
            )

        # Check context strategy
        strategy = settings.get("cursor.chat.contextBudgetStrategy", "none")
        if strategy == "strict":
            problematic_settings.append(
                "Using 'strict' context strategy (may trigger aggressive summarization)"
            )
        elif strategy == "adaptive":
            good_settings.append("Using 'adaptive' context strategy")

        # Check web search settings
        if not settings.get("cursor.general.disableAutoWebSearch", False):
            problematic_settings.append("Auto web search enabled (may cause hangs)")
        else:
            good_settings.append("Auto web search disabled")

        if not settings.get("cursor.composer.disableWebSearch", False):
            problematic_settings.append("Composer web search enabled (may cause hangs)")
        else:
            good_settings.append("Composer web search disabled")

        return {
            "settings": settings,
            "issues": problematic_settings,
            "good": good_settings,
        }

    except Exception as e:
        return {"error": f"Failed to read settings: {e}"}


def generate_recommendations(token_usage: Dict[str, int]) -> List[str]:
    """Generate optimization recommendations based on token usage."""
    recommendations = []

    total_static = sum(token_usage.values())

    # General recommendations for context usage
    if total_static > 150000:
        recommendations.append("🚨 CRITICAL: Total static context > 150K tokens")
        recommendations.append("   → Exceeds recommended context capacity")
    elif total_static > 50000:
        recommendations.append("⚠️  Large static context > 50K tokens")
        recommendations.append("   → Monitor for performance impacts")
    else:
        recommendations.append("✅ Static context within reasonable limits")

    if token_usage.get("rules_total", 0) > 20000:
        recommendations.append("⚠️  Rules consume > 20K tokens")
        recommendations.append("   → Consider selective rule loading")

    if token_usage.get(".cursor/config.md", 0) > 5000:
        recommendations.append("⚠️  Main config file is large")
        recommendations.append("   → Consider optimizing configuration size")

    return recommendations


def main():
    print("🔍 Cursor Context Diagnostic Tool")
    print("=" * 50)

    # Analyze token usage
    print("\n📊 Token Usage Analysis:")
    token_usage = analyze_cursor_config()

    total_tokens = sum(token_usage.values())
    print(f"\n📈 Total Static Context: ~{total_tokens:,} tokens")

    # Check system settings
    print("\n⚙️  System Settings Check:")
    settings_analysis = check_cursor_settings()

    if "error" in settings_analysis:
        print(f"❌ {settings_analysis['error']}")
    else:
        if settings_analysis["good"]:
            print("✅ Good Settings:")
            for setting in settings_analysis["good"]:
                print(f"   • {setting}")

        if settings_analysis["issues"]:
            print("🚨 Issues Found:")
            for issue in settings_analysis["issues"]:
                print(f"   • {issue}")

        if not settings_analysis["issues"]:
            print("✅ No problematic settings detected")

    # Generate recommendations
    print("\n💡 Recommendations:")
    recommendations = generate_recommendations(token_usage)

    for rec in recommendations:
        print(f"   {rec}")

    # General context assessment - Claude-specific guidance disabled
    print("\n🤖 General Context Assessment:")
    if total_tokens > 150000:
        print("   🚨 EXCEEDS recommended usage (>150K tokens)")
        print("   → Immediate optimization required")
    elif total_tokens > 100000:
        print("   ⚠️  High usage (>100K tokens)")
        print("   → Monitor for performance issues")
    elif total_tokens > 50000:
        print("   📊 Moderate usage (50-100K tokens)")
        print("   → Good balance of features vs performance")
    else:
        print("   ✅ Low usage (<50K tokens)")
        print("   → Excellent performance expected")

    # Check for hang risk
    settings = settings_analysis.get("settings", {})
    max_tokens = settings.get("cursor.chat.maxContextTokens", 0)
    if max_tokens < 50000:
        print("\n🚨 HANG RISK DETECTED:")
        print(f"   Token limit {max_tokens} is too low and may trigger")
        print("   infinite 'summarizing chat context' loops with web search")
        print("   → Increase to a higher limit for better performance")


if __name__ == "__main__":
    main()
