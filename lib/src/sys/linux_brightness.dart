import 'dart:io';

import 'package:linux_sys_ffi/src/security/linux_security.dart';
import 'package:linux_sys_ffi/src/sys/linux_sudo_prompt.dart';

class LinuxBrightness {
  late final Directory _backlightDir;
  bool _isValid = false;

  LinuxBrightness({String backlightName = 'intel_backlight'}) {
    try {
      // ၁။ Symlink လမ်းကြောင်းကို အရင်သတ်မှတ်မယ်
      final symlink = Link('/sys/class/backlight/$backlightName');

      if (symlink.existsSync()) {
        // ၂။ Symlink ကို ဖြေချပြီး ၎င်းညွှန်းထားတဲ့ Path အစစ်ကို ယူမယ်
        final String realPath = symlink.resolveSymbolicLinksSync();
        _backlightDir = Directory(realPath);
        _isValid = _backlightDir.existsSync();
      }
    } catch (e) {
      _isValid = false;
      print("Brightness path အား ဖတ်မရပါ: $e");
    }
  }

  bool get exists => _isValid;

  int getCurrentBrightness() {
    if (!exists) return -1;
    return int.parse(
      File('${_backlightDir.path}/actual_brightness').readAsStringSync().trim(),
    );
  }

  int getMaxBrightness() {
    if (!exists) return -1;
    return int.parse(
      File('${_backlightDir.path}/max_brightness').readAsStringSync().trim(),
    );
  }

  bool setBrightness(int value) {
    if (!exists) return false;

    // အရှေ့က Security API နဲ့ Permission အရင်စစ်မယ်
    if (!LinuxSecurity().isRoot) {
      print(
        "Error: Brightness ကို ပြောင်းလဲရန် Sudo/Root Permission လိုအပ်ပါသည်။",
      );
      return false;
    }

    try {
      final max = getMaxBrightness();
      if (value < 0 || value > max) return false;

      // Path အစစ်ထဲက brightness file ထဲကို တန်ဖိုးလှမ်းရေးမယ်
      File('${_backlightDir.path}/brightness').writeAsStringSync('$value');
      return true;
    } catch (_) {
      return false;
    }
  }

  String? getBrightnessCommand(int value) {
    if (!_backlightDir.existsSync()) return null;

    // အမြင့်ဆုံး limit ဖတ်မယ်
    final max = int.parse(
      File('${_backlightDir.path}/max_brightness').readAsStringSync().trim(),
    );
    if (value < 0 || value > max) return null;

    // Kernel file ထဲကို တန်ဖိုးထည့်မယ့် command string ဆောက်မယ်
    // echo value > file_path ကို root အနေနဲ့ run ဖို့ ပြင်တာပါ
    final String targetPath = '${_backlightDir.path}/brightness';
    final String command = 'echo $value > $targetPath';
    return command;
  }

  Future<bool> setBrightnessWithPrompt(int value) async {
    if (!_backlightDir.existsSync()) return false;

    // အမြင့်ဆုံး limit ဖတ်မယ်
    final max = int.parse(
      File('${_backlightDir.path}/max_brightness').readAsStringSync().trim(),
    );
    if (value < 0 || value > max) return false;

    // Kernel file ထဲကို တန်ဖိုးထည့်မယ့် command string ဆောက်မယ်
    // echo value > file_path ကို root အနေနဲ့ run ဖို့ ပြင်တာပါ
    final String targetPath = '${_backlightDir.path}/brightness';
    final String command = 'echo $value > $targetPath';

    // GUI Sudo Box ကို လှမ်းခေါ်ပြီး ရေးခိုင်းလိုက်မယ်
    return await LinuxSudoPrompt().runWithGuiSudo(command);
  }
}
