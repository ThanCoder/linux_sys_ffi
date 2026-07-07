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

  /// CPU Model နာမည်ကို ဖတ်မည်
  String getCpuModel() {
    final file = File('/proc/cpuinfo');
    if (!file.existsSync()) return 'Unknown';

    for (var line in file.readAsLinesSync()) {
      if (line.startsWith('model name')) {
        return line.split(':')[1].trim(); // e.g., "Intel(R) Core(TM) i7-..."
      }
    }
    return 'Unknown';
  }

  /// CPU Cores အရေအတွက်ကို ဖတ်မည်
  int getCpuCores() {
    return Platform
        .numberOfProcessors; // Dart standard library ကနေလည်း တိုက်ရိုက်ရပါတယ်
  }
}
