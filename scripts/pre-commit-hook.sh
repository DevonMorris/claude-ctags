#!/bin/bash
# Pre-commit hook: regenerate tags before git commit
# Only runs regeneration if the Bash command is a git commit

set -euo pipefail

# Read hook input from stdin
input=$(cat)

# Extract the command from tool_input
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Check if this is a git commit command
if [[ "$command" == *"git commit"* ]]; then
    # Regenerate tags before commit
    bash "${CLAUDE_PLUGIN_ROOT}/scripts/regenerate-tags.sh" >/dev/null 2>&1 || true
fi

# Always allow the command to proceed
exit 0
