# claude-ctags

A Claude Code plugin that automatically generates and maintains a ctags index for efficient code navigation. Reduces token usage by providing precise symbol-to-location lookups instead of broad grep searches.

## Features

- **Auto-indexing**: Generates ctags index on session start
- **Live updates**: Regenerates index after file edits
- **Pre-commit refresh**: Ensures fresh index before git commits
- **Efficient lookups**: Query symbols directly instead of grepping

## Requirements

- [Universal Ctags](https://github.com/universal-ctags/ctags) installed and available in PATH

### Installation

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

## Configuration

The tags file is stored at `.claude/tags` in your project root. This location is automatically added to `.gitignore`.

## License

MIT
