#!/bin/bash
# Validate that dependency lockfiles are up-to-date

set -euo pipefail

status=0

declare -A lockfiles=(
  ["requirements.in"]="requirements.txt"
  ["dev-requirements.in"]="dev-requirements.txt"
)

for input in "${!lockfiles[@]}"; do
  output="${lockfiles[$input]}"
  if [[ -f "$input" && -f "$output" ]]; then
    echo "Checking $output..."
    if pip-compile --quiet --dry-run "$input" --output-file "$output"; then
      echo "✅ $output is up-to-date"
    else
      echo "❌ $output requires regeneration. Run 'pip-compile $input --output-file $output'"
      status=1
    fi
  fi
done

exit $status
