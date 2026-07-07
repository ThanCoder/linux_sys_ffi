import 'dart:io';

class LinuxLauncher {
  /// URL သို့မဟုတ် File Path ကို သက်ဆိုင်ရာ Default App ဖြင့် ဖွင့်မည်
  Future<bool> open(String pathOrUrl) async {
    final result = await Process.run('xdg-open', [pathOrUrl]);
    return result.exitCode == 0;
  }
}
