#!/bin/bash
# Regenerate ctags index for the project
# Stores tags in .claude/tags to keep project root clean

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TAGS_DIR="$PROJECT_DIR/.claude"
TAGS_FILE="$TAGS_DIR/tags"
GITIGNORE="$PROJECT_DIR/.gitignore"

# Ensure .claude directory exists
mkdir -p "$TAGS_DIR"

# Check if ctags is available
if ! command -v ctags &> /dev/null; then
    echo "Warning: ctags not found. Install universal-ctags to enable code indexing." >&2
    exit 0
fi

# Regenerate tags file
# Using universal-ctags with common options:
# -R: recursive
# --tag-relative=yes: use relative paths
# --exclude common non-code directories
ctags -R \
    --tag-relative=yes \
    --exclude=.git \
    --exclude=node_modules \
    --exclude=vendor \
    --exclude=.venv \
    --exclude=venv \
    --exclude=__pycache__ \
    --exclude='*.min.js' \
    --exclude='*.bundle.js' \
    --exclude=dist \
    --exclude=build \
    --exclude=coverage \
    --exclude=.claude \
    -f "$TAGS_FILE" \
    "$PROJECT_DIR" 2>/dev/null || true

# Auto-manage .gitignore
if [ -f "$GITIGNORE" ]; then
    if ! grep -q "^\.claude/tags$" "$GITIGNORE" 2>/dev/null; then
        echo "" >> "$GITIGNORE"
        echo "# Claude Code ctags index" >> "$GITIGNORE"
        echo ".claude/tags" >> "$GITIGNORE"
    fi
else
    echo "# Claude Code ctags index" > "$GITIGNORE"
    echo ".claude/tags" >> "$GITIGNORE"
fi

echo "Tags index updated: $TAGS_FILE"
