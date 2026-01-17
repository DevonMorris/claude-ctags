#!/bin/bash
# Query the ctags index for a symbol definition
# Usage: query-tags.sh <symbol>
# Output: file:line for the definition, or empty if not found

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TAGS_FILE="$PROJECT_DIR/.claude/tags"

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

# Use grep for exact match on symbol (first field)
# Then parse out file and line info
grep "^${SYMBOL}	" "$TAGS_FILE" 2>/dev/null | while IFS=$'\t' read -r name file pattern rest; do
    # Extract line number from pattern if it's a line number search
    # Pattern can be /^...$/;" or just a line number
    if [[ "$pattern" =~ ^[0-9]+\;\" ]]; then
        line="${pattern%%;*}"
        echo "$file:$line"
    elif [[ "$pattern" =~ ^/\^.*\$/\;\" ]]; then
        # It's a pattern, we need to find the line number
        # Extract the search pattern (remove /^ and $/;")
        search_pattern="${pattern#/^}"
        search_pattern="${search_pattern%\$/;\"}"
        # Escape special chars for grep and find line number
        line=$(grep -n -F "$search_pattern" "$PROJECT_DIR/$file" 2>/dev/null | head -1 | cut -d: -f1)
        if [ -n "$line" ]; then
            echo "$file:$line"
        else
            echo "$file:1"
        fi
    else
        echo "$file:1"
    fi
done | head -10  # Limit to 10 results to avoid flooding
