---
name: refresh
description: Manually regenerate the ctags index
allowed-tools:
  - Bash
---

# Refresh Ctags Index

Regenerate the ctags index for the current project.

## Instructions

Execute the regeneration script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/regenerate-tags.sh
```

Report the result to the user, indicating:
- Whether the index was successfully updated
- The location of the tags file (`.claude/tags`)

## When This Command Is Useful

The index automatically regenerates after file edits and before commits. Manual refresh is useful when:
- Files were modified outside of Claude Code
- The user suspects the index is stale
- After checking out a different git branch
- After pulling changes from remote

## Notes

- Requires Universal Ctags to be installed
- Creates `.claude/tags` file
- Automatically updates `.gitignore`
