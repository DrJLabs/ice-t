#!/bin/bash
# Validate that dependency lockfiles are up-to-date

set -euo pipefail

status=0

for file in requirements.txt dev-requirements.txt; do
  if [ -f "$file" ]; then
    echo "Checking $file..."
    if pip-compile --quiet --dry-run "$file"; then
      echo "✅ $file is up-to-date"
    else
      echo "❌ $file requires regeneration. Run 'pip-compile $file'"
      status=1
    fi
  fi
done

exit $status
