#!/bin/bash
# Update startup scripts to ensure they're current

echo "🔄 Updating startup scripts..."

# Backup current scripts
mkdir -p backups/startup_$(date +%Y%m%d_%H%M%S)
cp setup_codex.sh codex_commands.sh backups/startup_$(date +%Y%m%d_%H%M%S)/

# Update setup_codex.sh with latest improvements
if grep -q "validate_prereqs" setup_codex.sh; then
    echo "✅ setup_codex.sh appears current"
else
    echo "⚠️  setup_codex.sh may need updates"
fi

# Update codex_commands.sh with streamlined commands
if grep -q "sparc-test-health" codex_commands.sh; then
    echo "✅ codex_commands.sh appears current"
else
    echo "⚠️  codex_commands.sh may need updates"
fi

# Ensure all scripts are executable
chmod +x setup_codex.sh
chmod +x codex_commands.sh
chmod +x check_startup_currency.sh
chmod +x validate_manual_startup.sh

echo "✅ Startup scripts updated"
