import 'dart:io';

class LinuxSysInfo {
  /// RAM Usage ကို MB အလိုက် ပြန်ပေးမယ် (Total, Available)
  Map<String, String> getMemoryInfo() {
    final file = File('/proc/meminfo');
    if (!file.existsSync()) return {};
    Map<String, String> memMap = {};

    final lines = file.readAsLinesSync();
    // int total = 0;
    // int available = 0;

    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(':');
      memMap[parts[0].trim()] = parts[1].trim();
    }
    return memMap;
  }
}
