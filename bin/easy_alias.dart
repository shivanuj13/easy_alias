import 'dart:io';
import 'package:prompts/prompts.dart' as prompts;
import 'package:easy_alias/models/alias.dart';
import 'package:easy_alias/alias_manager.dart';
import 'package:easy_alias/alias_file_generator.dart';
import 'package:easy_alias/shell_manager.dart';

// ANSI color codes
const String reset = '\x1B[0m';
const String green = '\x1B[32m';
const String red = '\x1B[31m';
const String yellow = '\x1B[33m';
const String blue = '\x1B[34m';
const String cyan = '\x1B[36m';
const String bold = '\x1B[1m';

void printSuccess(String msg) => print('$green$msg$reset');
void printError(String msg) => print('$red$msg$reset');
void printInfo(String msg) => print('$cyan$msg$reset');
void printMenuTitle(String msg) => print('$bold$blue$msg$reset');
void printWarning(String msg) => print('$yellow$msg$reset');

void main(List<String> arguments) {
  final manager = AliasManager();
  final shellManager = ShellManager();
  final aliasFilePath = '${Platform.environment['HOME']}/.easy_aliases.sh';
  var inMemoryAliases = List<Alias>.from(manager.aliases);
  var unsavedChanges = false;

  void regenerateAliasFile() {
    generateAliasFile(inMemoryAliases, aliasFilePath);
  }

  void saveAndActivate() {
    manager.setAliases(List<Alias>.from(inMemoryAliases));
    manager.saveAliases();
    regenerateAliasFile();
    shellManager.activate();
    unsavedChanges = false;
    printSuccess('\n✅ Changes saved and aliases activated!');
    printInfo('Please restart your terminal to see the changes.');
    // Note: Restarting the terminal automatically is not possible from a CLI tool because
    // it would require closing and reopening the user's shell process, which is managed by the OS/user.
    // The best we can do is prompt the user to restart or re-source their shell config.';
  }

  bool isAliasActive(Alias alias) {
    final file = File(aliasFilePath);
    if (!file.existsSync()) return false;
    final lines = file.readAsLinesSync();
    return lines.any((line) => line.trim().startsWith('alias ${alias.shortcut}=') );
  }

  void listAliases({bool showNumbers = true}) {
    if (inMemoryAliases.isEmpty) {
      printWarning('No managed aliases found.');
    } else {
      printMenuTitle('\nManaged Aliases:');
      for (var i = 0; i < inMemoryAliases.length; i++) {
        final alias = inMemoryAliases[i];
        final statusEmoji = isAliasActive(alias) ? '✅' : '❌';
        if (showNumbers) {
          print('  ${i + 1}. $statusEmoji ${cyan}${alias.shortcut}$reset => ${green}${alias.command}$reset');
        } else {
          print('  $statusEmoji ${cyan}${alias.shortcut}$reset => ${green}${alias.command}$reset');
        }
      }
    }
  }

  List<Map<String, dynamic>> getAllShellAliases() {
    final List<Map<String, dynamic>> allAliases = [];
    final home = Platform.environment['HOME'] ?? '';
    final shellConfigs = [
      '$home/.zshrc',
      '$home/.bashrc',
      '$home/.bash_profile',
      '$home/.profile',
    ];
    final managedShortcuts = inMemoryAliases.map((a) => a.shortcut).toSet();
    for (final configPath in shellConfigs) {
      final file = File(configPath);
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('alias ') && trimmed.contains('=')) {
          final aliasPart = trimmed.substring(6);
          final eqIdx = aliasPart.indexOf('=');
          if (eqIdx > 0) {
            final shortcut = aliasPart.substring(0, eqIdx).trim();
            var command = aliasPart.substring(eqIdx + 1).trim();
            if (command.startsWith("'")) command = command.substring(1);
            if (command.endsWith("'")) command = command.substring(0, command.length - 1);
            if (command.startsWith('"')) command = command.substring(1);
            if (command.endsWith('"')) command = command.substring(0, command.length - 1);
            allAliases.add({
              'shortcut': shortcut,
              'command': command,
              'managed': managedShortcuts.contains(shortcut),
            });
          }
        }
      }
    }
    // Add managed aliases not found in shell config (e.g., not yet activated)
    for (final alias in inMemoryAliases) {
      if (!allAliases.any((a) => a['shortcut'] == alias.shortcut)) {
        allAliases.add({
          'shortcut': alias.shortcut,
          'command': alias.command,
          'managed': true,
        });
      }
    }
    return allAliases;
  }

  void listAllAliasesWithDiff() {
    final allAliases = getAllShellAliases();
    if (allAliases.isEmpty) {
      printWarning('No aliases found in shell config or managed by Easy Alias.');
      return;
    }
    // Sort: managed first, then others
    allAliases.sort((a, b) {
      if (a['managed'] == b['managed']) return 0;
      return a['managed'] == true ? -1 : 1;
    });
    printMenuTitle('\nAll Aliases:');
    for (final alias in allAliases) {
      final isManaged = alias['managed'] == true;
      final color = isManaged ? green : cyan;
      final statusEmoji = isManaged
        ? (isAliasActive(Alias(shortcut: alias['shortcut'], command: alias['command'])) ? '✅' : '❌')
        : '🔵';
      print('$statusEmoji ${color}${alias['shortcut']}$reset => ${alias['command']}');
    }
    printInfo('\n🔵 = found in shell config | ✅ = active | ❌ = inactive');
  }

  List<Alias> selectManagedAliases(String action) {
    if (inMemoryAliases.isEmpty) {
      printWarning('No managed aliases available.');
      return [];
    }
    printMenuTitle('\nManaged Aliases:');
    for (var i = 0; i < inMemoryAliases.length; i++) {
      final alias = inMemoryAliases[i];
      final statusEmoji = isAliasActive(alias) ? '✅' : '❌';
      print('  ${i + 1}. $statusEmoji ${green}${alias.shortcut}$reset => ${alias.command}');
    }
    stdout.write('Enter numbers of aliases to $action (comma-separated, or "all" for all): ');
    final input = stdin.readLineSync();
    if (input == null || input.trim().isEmpty) return [];
    if (input.trim().toLowerCase() == 'all') return List<Alias>.from(inMemoryAliases);
    final indices = input.split(',').map((s) => int.tryParse(s.trim())).where((n) => n != null && n > 0 && n <= inMemoryAliases.length).map((n) => n! - 1).toSet();
    return indices.map((i) => inMemoryAliases[i]).toList();
  }

  List<String> menuOptions = [
    'Add Alias',
    'List Aliases',
    'Update Alias',
    'Delete Alias',
    'Activate Aliases',
    'Deactivate Aliases',
    'Save & Activate',
    'Exit',
  ];

  int menuPrompt() {
    while (true) {
      printMenuTitle('\n=== Easy Alias CLI ===');
      if (unsavedChanges) {
        printWarning('(!) You have unsaved changes.');
      }
      for (var i = 0; i < menuOptions.length; i++) {
        print('  ${yellow}${i + 1}.$reset ${menuOptions[i]}');
      }
      final input = prompts.get('${bold}Select an option (number, or type "exit" to exit):$reset');
      if (input.trim().toLowerCase() == 'exit') {
        printInfo('👋 Exiting Easy Alias CLI. Have a productive day!');
        exit(0);
      }
      final numChoice = int.tryParse(input);
      if (numChoice != null && numChoice > 0 && numChoice <= menuOptions.length) {
        return numChoice - 1;
      }
      printError('❌ Invalid input. Please enter a number.');
    }
  }

  String? getInputOrCancel(String prompt) {
    stdout.write('$prompt (or type "cancel" to abort): ');
    final input = stdin.readLineSync();
    if (input == null) {
      printInfo('🚫 Operation cancelled. Returning to main menu.');
      return null;
    }
    if (input.trim().toLowerCase() == 'cancel') {
      printInfo('🚫 Operation cancelled. Returning to main menu.');
      return null;
    }
    return input;
  }

  while (true) {
    final choiceIndex = menuPrompt();
    final choice = menuOptions[choiceIndex];
    switch (choice) {
      case 'Add Alias':
        final shortcut = getInputOrCancel('Enter shortcut:');
        if (shortcut == null) break;
        final command = getInputOrCancel('Enter command:');
        if (command == null) break;
        if (inMemoryAliases.any((a) => a.shortcut == shortcut)) {
          printError('❌ Alias "$shortcut" already exists.');
        } else {
          inMemoryAliases.add(Alias(shortcut: shortcut, command: command));
          unsavedChanges = true;
          printSuccess('✅ Alias "$shortcut" added.');
        }
        break;
      case 'List Aliases':
        listAllAliasesWithDiff();
        break;
      case 'Update Alias':
        listAliases();
        String? shortcut;
        if (inMemoryAliases.isEmpty) break;
        final input = getInputOrCancel('Enter shortcut or number to update (only managed aliases can be updated):');
        if (input == null) break;
        final numChoice = int.tryParse(input);
        int index = -1;
        if (numChoice != null && numChoice > 0 && numChoice <= inMemoryAliases.length) {
          index = numChoice - 1;
          shortcut = inMemoryAliases[index].shortcut;
        } else {
          shortcut = input;
          index = inMemoryAliases.indexWhere((a) => a.shortcut == shortcut);
        }
        if (index == -1) {
          printError('Alias "$input" not found or is not managed by Easy Alias.');
        } else {
          final newShortcut = getInputOrCancel('Enter new shortcut (leave blank to keep "$shortcut"):');
          if (newShortcut == null) break;
          final newCommand = getInputOrCancel('Enter new command (leave blank to keep current):');
          if (newCommand == null) break;
          final updatedShortcut = newShortcut.trim().isEmpty ? shortcut : newShortcut.trim();
          final updatedCommand = newCommand.trim().isEmpty ? inMemoryAliases[index].command : newCommand.trim();
          // Check for shortcut conflict if changed
          if (updatedShortcut != shortcut && inMemoryAliases.any((a) => a.shortcut == updatedShortcut)) {
            printError('❌ Alias "$updatedShortcut" already exists.');
          } else {
            inMemoryAliases[index] = Alias(shortcut: updatedShortcut, command: updatedCommand);
            unsavedChanges = true;
            printSuccess('✅ Alias "$shortcut" updated to "$updatedShortcut" => "$updatedCommand".');
          }
        }
        break;
      case 'Delete Alias':
        listAliases();
        final shortcut = getInputOrCancel('Enter shortcut to delete:');
        if (shortcut == null) break;
        final index = inMemoryAliases.indexWhere((a) => a.shortcut == shortcut);
        if (index == -1) {
          printError('❌ Alias "$shortcut" not found.');
        } else {
          inMemoryAliases.removeAt(index);
          unsavedChanges = true;
          printSuccess('✅ Alias "$shortcut" deleted.');
        }
        break;
      case 'Activate Aliases': {
        final selected = selectManagedAliases('activate');
        if (selected.isEmpty) {
          printWarning('No aliases selected for activation.');
          break;
        }
        generateAliasFile(selected, aliasFilePath);
        shellManager.activate();
        printSuccess('🚀 Selected aliases activated. Restart your terminal to apply changes.');
        break;
      }
      case 'Deactivate Aliases': {
        final selected = selectManagedAliases('deactivate');
        if (selected.isEmpty) {
          printWarning('No aliases selected for deactivation.');
          break;
        }
        // Remove selected aliases from the alias file
        final file = File(aliasFilePath);
        if (file.existsSync()) {
          final lines = file.readAsLinesSync();
          final shortcutsToRemove = selected.map((a) => a.shortcut).toSet();
          final newLines = lines.where((line) {
            for (final shortcut in shortcutsToRemove) {
              if (line.trim().startsWith('alias $shortcut=')) return false;
            }
            return true;
          }).toList();
          file.writeAsStringSync(newLines.join('\n'));
        }
        shellManager.activate(); // Ensure sourcing line is present
        printWarning('🛑 Selected aliases deactivated. Restart your terminal to apply changes.');
        break;
      }
      case 'Save & Activate':
        saveAndActivate();
        break;
      case 'Exit':
        if (unsavedChanges) {
          final save = prompts.getBool('You have unsaved changes. Save & activate before exit?');
          if (save) {
            saveAndActivate();
          }
        }
        printInfo('👋 Goodbye!');
        exit(0);
    }
  }
}
