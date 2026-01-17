# claude-ctags

A Claude Code plugin that automatically generates and maintains a ctags index for efficient code navigation. Reduces token usage by providing precise symbol-to-location lookups instead of broad grep searches.

## Installation

Requires Claude Code version 1.0.33 or later.

**1. Add the marketplace:**
```bash
/plugin marketplace add DevonMorris/claude-ctags
```

**2. Install the plugin:**
```bash
/plugin install claude-ctags@claude-ctags
```

Or use the interactive installer with `/plugin` and navigate to the **Discover** tab.

## Features

- **Auto-indexing**: Generates ctags index on session start
- **Live updates**: Regenerates index after file edits
- **Pre-commit refresh**: Ensures fresh index before git commits
- **Efficient lookups**: Query symbols directly instead of grepping

## Requirements

[Universal Ctags](https://github.com/universal-ctags/ctags) must be installed and available in PATH:

**macOS:**
```bash
brew install universal-ctags
```

**Ubuntu/Debian:**
```bash
sudo apt install universal-ctags
```

**Arch Linux:**
```bash
sudo pacman -S ctags
```

## Usage

The plugin works automatically once installed:

1. **Session start**: Index generated at `.claude/tags`
2. **After edits**: Index regenerated automatically
3. **Before commits**: Index refreshed

### Manual Refresh

Use `/claude-ctags:refresh` to manually regenerate the index.

### How Claude Uses It

Instead of:
```
grep -r "UserService" .  # Returns 50+ matches
```

Claude can:
```
# Query tags file → src/services/user.ts:42
# Read just that file at the definition
```

## Token Usage Comparison

Real-world test using the [ripgrep](https://github.com/BurntSushi/ripgrep) codebase (~35k lines of Rust):

### Example 1: Finding `prioritized_alias` function

| Approach | Output | Results |
|----------|--------|---------|
| **Grep** | ~300 chars | 3 matches (1 definition + 2 usages) |
| **Ctags** | ~100 chars | 1 match (definition only) |

**Ctags output:**
```
prioritized_alias  crates/printer/src/hyperlink/aliases.rs  /^const fn prioritized_alias($/  f
```

### Example 2: Finding `fn new(` (common pattern)

| Approach | Output | Results |
|----------|--------|---------|
| **Grep** | ~4,500 chars | 74 matches across 35 files |
| **Ctags** | ~100 chars per lookup | Direct to specific struct's `new` |

When searching for a common symbol like `new`, grep returns **74 occurrences** across 35 files. With ctags, you query the specific type (e.g., `RegexMatcher::new`) and get the exact location.

### Token Savings

- **Simple lookups**: ~67% reduction (300 → 100 chars)
- **Common symbols**: ~97% reduction (4,500 → 100 chars)
- **Eliminates follow-up searches**: No need to filter through usages to find definitions

## Configuration

The tags file is stored at `.claude/tags` in your project root. This location is automatically added to `.gitignore`.

## License

MIT
