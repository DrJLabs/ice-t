#!/usr/bin/env python3
"""
Context Optimization Utility
Addresses "chat too long" issues by reducing context file sizes and pruning old data.
"""

from datetime import datetime, timedelta
from pathlib import Path
import sqlite3
import sys
from typing import Dict, Optional


class ContextOptimizer:
    """Optimizes context files to prevent 'chat too long' issues."""

    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.context_dir = self.project_root / ".context"
        self.context_db = self.context_dir / "context.db"
        self.backup_dir = self.context_dir / "backups"

        # Optimization settings
        self.max_conversations = 10  # Keep only recent conversations
        self.max_context_age_days = 30  # Remove context older than 30 days
        self.max_summary_length = 500  # Truncate long summaries
        self.max_file_contexts = 50  # Keep only most relevant file contexts

    def analyze_context_size(self) -> Dict[str, int]:
        """Analyze current context database size and content."""
        if not self.context_db.exists():
            print("❌ No context database found")
            return {}

        try:
            conn = sqlite3.connect(self.context_db)
            cursor = conn.cursor()

            # Get table sizes
            sizes = {}

            # Count conversations
            cursor.execute("SELECT COUNT(*) FROM conversation_context")
            sizes["conversations"] = cursor.fetchone()[0]

            # Count code contexts
            cursor.execute("SELECT COUNT(*) FROM code_context")
            sizes["code_contexts"] = cursor.fetchone()[0]

            # Get database file size
            sizes["db_size_bytes"] = self.context_db.stat().st_size
            sizes["db_size_mb"] = sizes["db_size_bytes"] / (1024 * 1024)

            # Get oldest and newest entries
            cursor.execute(
                "SELECT MIN(timestamp), MAX(timestamp) FROM conversation_context"
            )
            result = cursor.fetchone()
            if result[0]:
                sizes["oldest_conversation"] = result[0]
                sizes["newest_conversation"] = result[1]

            conn.close()

            return sizes

        except Exception as e:
            print(f"❌ Error analyzing context: {e}")
            return {}

    def backup_context(self) -> Optional[Path]:
        """Create a backup of the current context database."""
        if not self.context_db.exists():
            print("⚠️ No context database to backup")
            return None

        try:
            self.backup_dir.mkdir(exist_ok=True)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_path = self.backup_dir / f"context_backup_{timestamp}.db"

            # Copy database
            import shutil

            shutil.copy2(self.context_db, backup_path)

            print(f"✅ Context backed up to: {backup_path}")
            return backup_path

        except Exception as e:
            print(f"❌ Backup failed: {e}")
            return None

    def optimize_conversations(self) -> int:
        """Remove old conversations and truncate long summaries."""
        if not self.context_db.exists():
            return 0

        try:
            conn = sqlite3.connect(self.context_db)
            cursor = conn.cursor()

            # Get current conversation count
            cursor.execute("SELECT COUNT(*) FROM conversation_context")
            initial_count = cursor.fetchone()[0]

            # Remove conversations older than max_context_age_days
            cutoff_date = (
                datetime.now() - timedelta(days=self.max_context_age_days)
            ).isoformat()
            cursor.execute(
                "DELETE FROM conversation_context WHERE timestamp < ?", (cutoff_date,)
            )

            # Keep only the most recent conversations if still too many
            cursor.execute(
                """
                DELETE FROM conversation_context
                WHERE session_id NOT IN (
                    SELECT session_id FROM conversation_context
                    ORDER BY timestamp DESC
                    LIMIT ?
                )
            """,
                (self.max_conversations,),
            )

            # Truncate long context summaries
            cursor.execute(
                "SELECT session_id, context_summary FROM conversation_context"
            )
            for session_id, summary in cursor.fetchall():
                if summary and len(summary) > self.max_summary_length:
                    truncated = summary[: self.max_summary_length] + "... (truncated)"
                    cursor.execute(
                        "UPDATE conversation_context SET context_summary = ? WHERE session_id = ?",
                        (truncated, session_id),
                    )

            conn.commit()

            # Get final count
            cursor.execute("SELECT COUNT(*) FROM conversation_context")
            final_count = cursor.fetchone()[0]

            conn.close()

            removed = initial_count - final_count
            print(
                f"✅ Optimized conversations: {removed} removed, {final_count} remaining"
            )
            return removed

        except Exception as e:
            print(f"❌ Error optimizing conversations: {e}")
            return 0

    def optimize_code_contexts(self) -> int:
        """Remove old and irrelevant code contexts."""
        if not self.context_db.exists():
            return 0

        try:
            conn = sqlite3.connect(self.context_db)
            cursor = conn.cursor()

            # Get current count
            cursor.execute("SELECT COUNT(*) FROM code_context")
            initial_count = cursor.fetchone()[0]

            # Remove contexts for files that no longer exist
            cursor.execute("SELECT file_path FROM code_context")
            removed_missing = 0
            for (file_path,) in cursor.fetchall():
                if not (self.project_root / file_path).exists():
                    cursor.execute(
                        "DELETE FROM code_context WHERE file_path = ?", (file_path,)
                    )
                    removed_missing += 1

            # Remove very old contexts
            cutoff_date = (
                datetime.now() - timedelta(days=self.max_context_age_days)
            ).isoformat()
            cursor.execute(
                "DELETE FROM code_context WHERE last_modified < ?", (cutoff_date,)
            )

            # Keep only most relevant contexts (highest complexity scores)
            cursor.execute("SELECT COUNT(*) FROM code_context")
            current_count = cursor.fetchone()[0]

            if current_count > self.max_file_contexts:
                cursor.execute(
                    """
                    DELETE FROM code_context
                    WHERE file_path NOT IN (
                        SELECT file_path FROM code_context
                        ORDER BY complexity_score DESC
                        LIMIT ?
                    )
                """,
                    (self.max_file_contexts,),
                )

            conn.commit()

            # Get final count
            cursor.execute("SELECT COUNT(*) FROM code_context")
            final_count = cursor.fetchone()[0]

            conn.close()

            removed = initial_count - final_count
            print(
                f"✅ Optimized code contexts: {removed} removed, {final_count} remaining"
            )
            print(f"   - {removed_missing} removed (missing files)")
            return removed

        except Exception as e:
            print(f"❌ Error optimizing code contexts: {e}")
            return 0

    def vacuum_database(self) -> bool:
        """Vacuum the database to reclaim space."""
        if not self.context_db.exists():
            return False

        try:
            conn = sqlite3.connect(self.context_db)
            conn.execute("VACUUM")
            conn.close()

            print("✅ Database vacuumed (space reclaimed)")
            return True

        except Exception as e:
            print(f"❌ Error vacuuming database: {e}")
            return False

    def clean_temp_files(self) -> int:
        """Clean up temporary context files."""
        cleaned = 0

        patterns = [
            "ai_context_*.json",
            "session_handoff_*.json",
            "temp_*.log",
            ".ai_session_*",
            ".ai_changes_*.log",
        ]

        for pattern in patterns:
            for file_path in self.project_root.glob(pattern):
                try:
                    file_path.unlink()
                    cleaned += 1
                    print(f"🗑️ Removed: {file_path.name}")
                except Exception as e:
                    print(f"⚠️ Could not remove {file_path}: {e}")

        return cleaned

    def run_full_optimization(self) -> Dict[str, int]:
        """Run complete context optimization."""
        print("🧹 Starting Context Optimization")
        print("=" * 40)

        # Analyze current state
        print("\n📊 Analyzing current context...")
        initial_sizes = self.analyze_context_size()

        if initial_sizes:
            print(f"   📁 Database size: {initial_sizes.get('db_size_mb', 0):.2f} MB")
            print(f"   💬 Conversations: {initial_sizes.get('conversations', 0)}")
            print(f"   📄 Code contexts: {initial_sizes.get('code_contexts', 0)}")

        # Create backup
        print("\n💾 Creating backup...")
        backup_path = self.backup_context()

        # Optimize
        results = {}

        print("\n🔧 Optimizing conversations...")
        results["conversations_removed"] = self.optimize_conversations()

        print("\n🔧 Optimizing code contexts...")
        results["code_contexts_removed"] = self.optimize_code_contexts()

        print("\n🔧 Cleaning temporary files...")
        results["temp_files_removed"] = self.clean_temp_files()

        print("\n🔧 Vacuuming database...")
        self.vacuum_database()

        # Analyze final state
        print("\n📊 Final analysis...")
        final_sizes = self.analyze_context_size()

        if initial_sizes and final_sizes:
            size_reduction = initial_sizes.get("db_size_mb", 0) - final_sizes.get(
                "db_size_mb", 0
            )
            results["size_reduction_mb"] = size_reduction

            print(f"   📁 Database size: {final_sizes.get('db_size_mb', 0):.2f} MB")
            print(f"   📉 Size reduction: {size_reduction:.2f} MB")
            print(f"   💬 Conversations: {final_sizes.get('conversations', 0)}")
            print(f"   📄 Code contexts: {final_sizes.get('code_contexts', 0)}")

        print("\n✅ Optimization complete!")
        print(f"   Backup: {backup_path}")

        return results


def main():
    """CLI for context optimization."""
    if len(sys.argv) < 2:
        print("Usage: python optimize_context.py <command>")
        print("Commands:")
        print("  analyze   - Analyze current context size")
        print("  optimize  - Run full optimization")
        print("  backup    - Create backup only")
        print("  clean     - Clean temp files only")
        return

    optimizer = ContextOptimizer()
    command = sys.argv[1]

    if command == "analyze":
        sizes = optimizer.analyze_context_size()
        if sizes:
            print("📊 Context Analysis:")
            print(f"   Database size: {sizes.get('db_size_mb', 0):.2f} MB")
            print(f"   Conversations: {sizes.get('conversations', 0)}")
            print(f"   Code contexts: {sizes.get('code_contexts', 0)}")
            if "oldest_conversation" in sizes:
                print(
                    f"   Date range: {sizes['oldest_conversation']} to {sizes['newest_conversation']}"
                )

    elif command == "optimize":
        results = optimizer.run_full_optimization()

    elif command == "backup":
        optimizer.backup_context()

    elif command == "clean":
        cleaned = optimizer.clean_temp_files()
        print(f"✅ Cleaned {cleaned} temporary files")

    else:
        print("❌ Unknown command")


if __name__ == "__main__":
    main()
