import 'dart:io';
import 'package:easy_alias/models/alias.dart';

void generateAliasFile(List<Alias> aliases, String filePath) {
  final file = File(filePath);
  final buffer = StringBuffer();
  for (final alias in aliases) {
    buffer.writeln("alias ${alias.shortcut}='${alias.command.replaceAll("'", "'\\''")}'");
  }
  file.writeAsStringSync(buffer.toString());
} 