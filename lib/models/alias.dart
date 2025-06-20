class Alias {
  final String shortcut;
  final String command;

  Alias({required this.shortcut, required this.command});

  factory Alias.fromJson(Map<String, dynamic> json) {
    return Alias(
      shortcut: json['shortcut'] as String,
      command: json['command'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortcut': shortcut,
      'command': command,
    };
  }
} 