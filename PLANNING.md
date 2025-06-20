# Easy Alias CLI — High-Level Implementation & Planning

## Goals
- Provide an interactive, menu-driven CLI for managing shell aliases.
- Allow users to add, list, update, delete, activate, deactivate, and save aliases from a single session.
- Support global activation so the CLI can be run from anywhere as `ea`.
- Allow selective activation/deactivation of aliases.
- Show all aliases (managed and from shell config) with clear status.
- Provide a safe, user-friendly, and visually clear experience.

## Final Features
- **Interactive CLI Menu**: Number-based selection, cancel/exit at any prompt.
- **Alias Management**: Add, list, update (by shortcut or number), delete.
- **Selective Activation/Deactivation**: Choose which managed aliases to activate/deactivate by number or "all".
- **Alias Status**: Shows status (✅ active, ❌ inactive, 🔵 found in shell config) for each alias in all relevant menus.
- **All Aliases View**: Lists both managed and shell-config aliases, with clear emoji/status and grouping.
- **Safe Editing**: Only managed aliases can be updated or deleted; shell config aliases are read-only.
- **Global CLI Access**: `dart pub global activate --source=path .` and run with `ea` from anywhere.
- **Colorful, Emoji-rich UX**: For clarity and accessibility.

## Final Workflow
1. **Clone the repo** and install dependencies.
2. **Activate globally** for instant CLI access as `ea`.
3. **Use the menu** to manage aliases:
   - Add, list, update, delete
   - Selectively activate/deactivate
   - See all aliases and their status
   - Save & Activate to apply changes
4. **Restart your terminal** to apply changes.

## Implementation Notes
- **Alias Storage**: Managed aliases are stored in `~/.easy_aliases.json` and written to `~/.easy_aliases.sh`.
- **Shell Integration**: The tool adds/removes a `source ~/.easy_aliases.sh` line in your shell config (e.g., `.zshrc`).
- **Alias Discovery**: Reads all `alias` lines from common shell config files for display.
- **Status Detection**: Checks if each managed alias is currently active (present in the alias file).
- **Safety**: Does not modify or update aliases not managed by Easy Alias.

## Design Decisions
- **Interactive UX**: For simplicity and user-friendliness.
- **Staged Changes**: Prevents accidental overwrites and allows batch updates.
- **Selective Activation**: Empowers users to control which aliases are active.
- **Global Activation**: Makes the tool accessible from any directory.
- **Clear Status**: Emoji and color coding for instant clarity.

---
This file reflects the final design and implementation as of the latest release. 