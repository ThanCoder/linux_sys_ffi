import 'dart:io';

class LinuxSudoPrompt {
  LinuxSudoPrompt();

  /// GUI Password Box ကို တောင်းပြီး ကိုယ်လုပ်ချင်တဲ့ command ကို root အနေနဲ့ run မယ်
  /// ဥပမာ - `runWithGuiSudo('echo 500 > /sys/class/backlight/intel_backlight/brightness')`
  Future<bool> runWithGuiSudo(String command) async {
    try {
      // pkexec သည် Linux ရဲ့ Standard PolicyKit GUI Sudo Prompt ဖြစ်ပါတယ်
      // bash -c ကနေတဆင့် ကိုယ်ပေးလိုက်တဲ့ command ကို root အနေနဲ့ ပတ်ရလိမ့်မယ်
      final ProcessResult result = await Process.run('pkexec', [
        'bash',
        '-c',
        command,
      ]);

      // Exit code 0 ဆိုရင် user က password မှန်အောင်ရိုက်ပြီး permission ပေးလိုက်တာပါ
      if (result.exitCode == 0) {
        return true;
      } else {
        print(
          "Sudo ငြင်းပယ်ခံရသည် သို့မဟုတ် Box ကို ပိတ်လိုက်သည်: ${result.stderr}",
        );
        return false;
      }
    } catch (e) {
      print("pkexec မလုပ်ဆောင်နိုင်ပါ (Polkit မရှိပါ): $e");
      return false;
    }
  }
}
