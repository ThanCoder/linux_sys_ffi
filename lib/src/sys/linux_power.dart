import 'dart:io';

class LinuxPower {
  /// စက်ချက်ချင်းပိတ်မည် (Poweroff)
  Future<ProcessResult> shutdown() async => await Process.run('poweroff', []);

  /// စက်ကို ပြန်ပွင့်စေမည် (Restart)
  Future<ProcessResult> reboot() async => await Process.run('reboot', []);

  /// Suspend (Sleep) ချမည်
  Future<ProcessResult> suspend() async =>
      await Process.run('systemctl', ['suspend']);

  /// စက်ကို ယခုချက်ချင်းပိတ်မည်
  Future<ProcessResult> shutdownNow() async =>
      await Process.run('shutdown', ['now']);

  /// မိနစ်သတ်မှတ်ပြီး စက်ပိတ်မည် (ဥပမာ - minutes: "10" ဆိုလျှင် ၁၀ မိနစ်နေမှ ပိတ်မည်)
  Future<ProcessResult> shutdownWithTimer(Duration duration) async {
    // Linux shutdown command အတွက် မိနစ်ရှေ့မှာ '+' ထည့်ပေးရပါမယ် (ဥပမာ - "+10")
    String minutesArg = '+${duration.inMinutes}';

    return await Process.run('shutdown', [minutesArg]);
  }

  /// စက်ပိတ်ရန် ချိန်းထားသည်များကို ပြန်ဖျက်မည်
  Future<ProcessResult> shutdownCancel() async =>
      await Process.run('shutdown', ['-c']);

  /// စက်ပိတ်ရန် ချိန်းထားသည်များကို Text (String) ဖြင့် ပြန်ပေးမည်
  Future<String> showPendingShutdown() async {
    ProcessResult result = await Process.run('shutdown', ['--show']);
    // print('exitCode: ${result.exitCode}');
    // print('stderr: ${result.stderr}');
    // print('stdout: ${result.stdout}');

    // Output စာသားကို String အဖြစ် ပြန်ပေးမည် (Error ရှိလျှင်လည်း Error message ကို ပြန်ပေးမည်)
    return result.stderr.toString().trim();
  }
}
