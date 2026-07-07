import 'dart:io';

class LinuxDistro {
  String get name {
    final file = File('/etc/os-release');
    if (!file.existsSync()) return 'Generic Linux';

    final lines = file.readAsLinesSync();
    for (var line in lines) {
      if (line.startsWith('NAME=')) {
        return line.split('=')[1].replaceAll('"', ''); // e.g., "Linux Mint"
      }
    }
    return 'Generic Linux';
  }

  String get osRelease {
    final file = File('/etc/os-release');
    if (!file.existsSync()) return '';
    return file.readAsStringSync();
  }
}
