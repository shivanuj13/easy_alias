import 'dart:convert';
import 'dart:io';
import 'package:easy_alias/models/alias.dart';

class AliasManager {
  final String aliasFilePath;
  List<Alias> _aliases = [];

  AliasManager({String? aliasFilePath})
      : aliasFilePath = aliasFilePath ?? '${Platform.environment['HOME']}/.easy_aliases.json' {
    _loadAliases();
  }

  List<Alias> get aliases => List.unmodifiable(_aliases);

  void addAlias(Alias alias) {
    if (_aliases.any((a) => a.shortcut == alias.shortcut)) {
      throw Exception('Alias with shortcut "${alias.shortcut}" already exists.');
    }
    _aliases.add(alias);
    _saveAliases();
  }

  void updateAlias(String shortcut, String newCommand) {
    final index = _aliases.indexWhere((a) => a.shortcut == shortcut);
    if (index == -1) {
      throw Exception('Alias with shortcut "$shortcut" not found.');
    }
    _aliases[index] = Alias(shortcut: shortcut, command: newCommand);
    _saveAliases();
  }

  void deleteAlias(String shortcut) {
    final index = _aliases.indexWhere((a) => a.shortcut == shortcut);
    if (index == -1) {
      throw Exception('Alias with shortcut "$shortcut" not found.');
    }
    _aliases.removeAt(index);
    _saveAliases();
  }

  List<Alias> listAllAliases() {
    return List.unmodifiable(_aliases);
  }

  void _loadAliases() {
    final file = File(aliasFilePath);
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final List<dynamic> jsonList = jsonDecode(content);
      _aliases = jsonList.map((e) => Alias.fromJson(e)).toList();
    } else {
      _aliases = [];
    }
  }

  void _saveAliases() {
    final file = File(aliasFilePath);
    final jsonList = _aliases.map((a) => a.toJson()).toList();
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  void setAliases(List<Alias> aliases) {
    _aliases = List<Alias>.from(aliases);
  }

  void saveAliases() {
    _saveAliases();
  }
} 