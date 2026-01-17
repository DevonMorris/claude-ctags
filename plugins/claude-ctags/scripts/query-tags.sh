#!/bin/bash
# Query the ctags index for a symbol definition
# Usage: query-tags.sh <symbol>
# Output: file:line for the definition, or empty if not found

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TAGS_FILE="$PROJECT_DIR/.claude/tags"
TAGS_DIR="$PROJECT_DIR/.claude"

if [ $# -lt 1 ]; then
    echo "Usage: query-tags.sh <symbol>" >&2
    exit 1
fi

SYMBOL="$1"

if [ ! -f "$TAGS_FILE" ]; then
    echo "Tags file not found: $TAGS_FILE" >&2
    echo "Run regenerate-tags.sh first." >&2
    exit 1
fi

# Query tags file
# Format: symbol<TAB>file<TAB>pattern;"<TAB>kind...
# We extract symbol, file, and line number
#
# Note: Paths in tags file are relative to the tags file location (.claude/)
# so we resolve them relative to TAGS_DIR

grep "^${SYMBOL}	" "$TAGS_FILE" 2>/dev/null | while IFS=$'\t' read -r name file pattern rest; do
    # Resolve file path relative to tags directory
    full_path=$(cd "$TAGS_DIR" && realpath -m "$file" 2>/dev/null || echo "$TAGS_DIR/$file")
    # Make path relative to project dir for cleaner output
    relative_path="${full_path#$PROJECT_DIR/}"

    # Extract line number from pattern if it's a line number search
    # Pattern can be /^...$/;" or just a line number
    if [[ "$pattern" =~ ^[0-9]+\;\" ]]; then
        line="${pattern%%;*}"
        echo "$relative_path:$line"
    elif [[ "$pattern" =~ ^/\^.*\$/\;\" ]]; then
        # It's a pattern, we need to find the line number
        # Extract the search pattern (remove /^ and $/;")
        search_pattern="${pattern#/^}"
        search_pattern="${search_pattern%\$/;\"}"
        # Find line number by searching for the pattern
        line=$(grep -n -F "$search_pattern" "$full_path" 2>/dev/null | head -1 | cut -d: -f1)
        if [ -n "$line" ]; then
            echo "$relative_path:$line"
        else
            echo "$relative_path:1"
        fi
    else
        echo "$relative_path:1"
    fi
done | head -10  # Limit to 10 results to avoid flooding
