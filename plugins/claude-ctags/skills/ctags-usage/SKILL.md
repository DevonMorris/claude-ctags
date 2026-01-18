---
name: ctags-usage
description: This skill should be used when the user asks to "find where X is defined", "find references to X", "where is X used", "locate the definition of", "where is the class/function/method", "jump to definition", "find symbol", or when needing to navigate code efficiently. Provides guidance on using the ctags index for token-efficient code navigation instead of broad grep searches.
version: 0.2.0
---

# Ctags Usage for Efficient Code Navigation

## Overview

This plugin maintains a ctags index at `.claude/tags` that maps symbol names to their locations. The index includes both definitions and references, making it useful for finding where symbols are defined AND where they are used. Use this index for efficient code navigation with minimal token usage instead of running broad grep or tree searches.

## When to Use Ctags

**Use ctags lookup FIRST when:**
- Finding where a class, function, method, or type is defined
- Finding references to a symbol (where it's used, imported, called)
- Navigating to a symbol's source location
- The user asks "where is X defined?" or "find references to X"

**Fall back to grep when:**
- Searching for text patterns that aren't symbol names
- Searching for string literals, comments, or documentation
- The ctags lookup returns no results
- Searching in file types not indexed by ctags

## How to Query the Tags Index

### Direct Tags File Query

Query the tags file using grep for the symbol name:

```bash
grep "^SymbolName	" .claude/tags
```

The tags file format is tab-separated:
```
symbol_name<TAB>file_path<TAB>pattern_or_line<TAB>kind
```

### Using the Query Script

For cleaner output with file:line format:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/query-tags.sh SymbolName
```

Returns results like:
```
src/services/user.ts:42
src/models/user.ts:15
```

### Interpreting Results

- Multiple results indicate the symbol appears in multiple places (definitions AND references)
- Use the `kind` field to distinguish:
  - `c` = class, `f` = function, `m` = method, `v` = variable (definitions)
  - `r` = reference (where the symbol is used/imported/called)
- Filter by kind to narrow results: `grep "^Symbol\t" .claude/tags | grep "kind:r"` for references only
- Read the specific file at the returned line number

## Token Efficiency Strategy

### Before (Inefficient)

```
User: "Where is UserService defined?"

Step 1: grep -r "UserService" .
Result: 50 lines (imports, usages, comments, definition)
Tokens: ~2000

Step 2: Read several files to find the actual definition
Tokens: ~3000 more

Total: ~5000 tokens
```

### After (Efficient with Ctags)

```
User: "Where is UserService defined?"

Step 1: grep "^UserService	" .claude/tags
Result: src/services/user.ts:42 (1 line)
Tokens: ~20

Step 2: Read src/services/user.ts at line 42
Tokens: ~500

Total: ~520 tokens (90% reduction)
```

## Index Management

### Automatic Updates

The tags index automatically regenerates:
- On session start
- After any Edit or Write tool use
- Before git commit commands

### Manual Refresh

If the index seems stale, use the refresh command:
```
/claude-ctags:refresh
```

Or run directly:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/regenerate-tags.sh
```

### Index Location

- Tags file: `.claude/tags`
- Added to `.gitignore` automatically

## Supported Languages

Universal Ctags supports 100+ languages including:
- JavaScript/TypeScript
- Python
- Go
- Rust
- Java
- C/C++
- Ruby
- PHP
- And many more

Check language support:
```bash
ctags --list-languages
```

## Workflow Integration

### Finding Definitions

1. Receive query about symbol location
2. Query ctags index first
3. If found, read the specific file at that line
4. If not found, fall back to grep

### Code Navigation

When exploring unfamiliar code:
1. Identify key symbol names from context
2. Use ctags to jump directly to definitions
3. Avoid scanning entire directories with tree or find

### Before Code Changes

When about to modify code:
1. Use ctags to locate the exact definition
2. Understand the implementation before changing
3. Index updates automatically after edits

## Limitations

- **Language support**: Some languages have limited tag extraction
- **Dynamic code**: Runtime-generated symbols not indexed
- **Freshness**: Index may lag briefly after rapid edits
- **Reference coverage**: Not all references may be captured depending on language

For patterns not captured by ctags, fall back to grep:
```bash
grep -r "SymbolName" --include="*.ts" .
```

## Quick Reference

| Task | Command |
|------|---------|
| Find definition | `grep "^Symbol	" .claude/tags` |
| Query script | `bash ${CLAUDE_PLUGIN_ROOT}/scripts/query-tags.sh Symbol` |
| Manual refresh | `/claude-ctags:refresh` |
| Check if indexed | `grep "Symbol" .claude/tags \| wc -l` |

## Best Practices

1. **Query ctags first** for definition lookups
2. **Read the specific line** returned, not the whole file
3. **Use grep for references** when ctags is inappropriate
4. **Trust the auto-refresh** - manual refresh rarely needed
5. **Check symbol kind** when multiple results returned
