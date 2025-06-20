# Easy Alias CLI

A simple Dart CLI tool to manage shell aliases on macOS and Linux. Create, list, update, activate, and deactivate your custom command shortcuts easily with a colorful, interactive menu.

---

## 🚀 Quick Start

### Option 1: Download Pre-built Executable (Recommended)
1. **Download the latest `ea` executable** from the [Releases](https://github.com/shivanuj13/easy_alias/releases) page for your platform.
2. **Make it executable and move to your PATH:**
   ```sh
   chmod +x ea
   sudo mv ea /usr/local/bin/ea
   ```
3. **Run from anywhere:**
   ```sh
   ea
   ```

### Option 2: Build from Source (Requires Dart)
1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd easy_alias
   ```
2. **Run the install script:**
   ```sh
   ./install.sh
   ```
   This will build the executable and place it in your PATH as `ea`.
3. **Run from anywhere:**
   ```sh
   ea
   ```

---

## 🛠️ Development Setup (For Contributors)

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd easy_alias
   ```
2. **Install dependencies:**
   ```sh
   dart pub get
   ```
3. **Run tests:**
   ```sh
   dart test
   ```
4. **Run locally (without global activation):**
   ```sh
   dart run bin/easy_alias.dart
   ```
5. **Make changes and submit a pull request!**

---

## Features
- Interactive, number-based menu for all actions
- Add, list, update, and delete aliases
- Update alias by shortcut or by number
- Cancel any operation by typing `cancel` or exit the app by typing `exit`
- Colorful output and emoji feedback for success and errors
- Save & Activate writes all changes and updates your shell config
- Selectively activate or deactivate aliases
- Shows all aliases (managed and from shell config) with clear status

## Usage

Just run:
```sh
ea
```

### Example: Adding an Alias

When you run `ea`, select `Add Alias` from the menu. You will be prompted:

```
=== Easy Alias CLI ===
  1. Add Alias
  2. List Aliases
  3. Update Alias
  4. Delete Alias
  5. Activate Aliases
  6. Deactivate Aliases
  7. Save & Activate
  8. Exit
Select an option (number, or type "exit" to exit): 1
Enter shortcut: gs
Enter command: git status
✅ Alias "gs" added.
```

You can now use the menu to activate, list, or manage your aliases.

> **Note:** After adding, updating, or deleting aliases, you must select **Save & Activate** from the menu for your changes to take effect in your shell. Then, restart your terminal or re-source your shell config to use the updated aliases.

### Menu Options
- Add Alias
- List Aliases (shows status: ✅ active, ❌ inactive, 🔵 found in shell config)
- Update Alias (choose by shortcut or number, only managed aliases)
- Delete Alias
- Activate Aliases (select which to activate)
- Deactivate Aliases (select which to deactivate)
- Save & Activate
- Exit

### Notes
- After activating or saving aliases, **restart your terminal** to see the changes take effect.
- Aliases are stored in `~/.easy_aliases.json`.
- The generated shell alias file is `~/.easy_aliases.sh`.
- The tool modifies your `~/.zshrc` (or other shell config) to source the alias file.
- Only aliases managed by Easy Alias can be updated or deleted from the CLI.

---

## 📝 Contributing
- Fork this repo and submit a pull request!
- Please write tests for new features or bugfixes.
