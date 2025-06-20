import 'dart:io';
import 'package:test/test.dart';
import 'package:easy_alias/models/alias.dart';
import 'package:easy_alias/alias_manager.dart';

void main() {
  group('AliasManager', () {
    late String tempFilePath;
    late AliasManager manager;

    setUp(() {
      tempFilePath = '${Directory.systemTemp.createTempSync().path}/aliases.json';
      manager = AliasManager(aliasFilePath: tempFilePath);
    });

    tearDown(() {
      final file = File(tempFilePath);
      if (file.existsSync()) file.deleteSync();
    });

    test('can add an alias', () {
      final alias = Alias(shortcut: 'ga', command: 'git add .');
      manager.addAlias(alias);
      expect(manager.aliases.length, 1);
      expect(manager.aliases.first.shortcut, 'ga');
      expect(manager.aliases.first.command, 'git add .');
    });

    test('cannot add duplicate alias', () {
      final alias = Alias(shortcut: 'ga', command: 'git add .');
      manager.addAlias(alias);
      expect(() => manager.addAlias(alias), throwsException);
    });

    test('can update an alias', () {
      final alias = Alias(shortcut: 'gc', command: 'git commit');
      manager.addAlias(alias);
      manager.updateAlias('gc', 'git commit -m');
      expect(manager.aliases.first.command, 'git commit -m');
    });

    test('update throws if alias not found', () {
      expect(() => manager.updateAlias('notfound', 'cmd'), throwsException);
    });

    test('can delete an alias', () {
      final alias = Alias(shortcut: 'gs', command: 'git status');
      manager.addAlias(alias);
      manager.deleteAlias('gs');
      expect(manager.aliases, isEmpty);
    });

    test('delete throws if alias not found', () {
      expect(() => manager.deleteAlias('notfound'), throwsException);
    });

    test('can list all aliases', () {
      manager.addAlias(Alias(shortcut: 'a', command: 'a')); 
      manager.addAlias(Alias(shortcut: 'b', command: 'b'));
      final all = manager.listAllAliases();
      expect(all.length, 2);
      expect(all[0].shortcut, 'a');
      expect(all[1].shortcut, 'b');
    });

    test('setAliases replaces all aliases', () {
      manager.addAlias(Alias(shortcut: 'a', command: 'a'));
      manager.setAliases([Alias(shortcut: 'b', command: 'b')]);
      expect(manager.aliases.length, 1);
      expect(manager.aliases.first.shortcut, 'b');
    });

    test('saveAliases persists to file', () {
      final alias = Alias(shortcut: 'ga', command: 'git add .');
      manager.addAlias(alias);
      manager.saveAliases();
      final file = File(tempFilePath);
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('git add .'));
    });
  });
} 