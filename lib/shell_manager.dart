import 'dart:io';

class ShellManager {
  final String shellConfigPath;
  final String aliasFilePath;
  final String sourceLine;

  ShellManager({
    String? shellConfigPath,
    String? aliasFilePath,
  })  : shellConfigPath = shellConfigPath ?? '${Platform.environment['HOME']}/.zshrc',
        aliasFilePath = aliasFilePath ?? '${Platform.environment['HOME']}/.easy_aliases.sh',
        sourceLine = 'source ~/.easy_aliases.sh';

  void activate() {
    final file = File(shellConfigPath);
    if (!file.existsSync()) file.createSync(recursive: true);
    final lines = file.readAsLinesSync();
    if (!lines.any((line) => line.trim() == sourceLine)) {
      file.writeAsStringSync('\n$sourceLine\n', mode: FileMode.append);
    }
  }

  void deactivate() {
    final file = File(shellConfigPath);
    if (!file.existsSync()) return;
    final lines = file.readAsLinesSync();
    final filtered = lines.where((line) => line.trim() != sourceLine).toList();
    file.writeAsStringSync(filtered.join('\n') + '\n');
  }
} 