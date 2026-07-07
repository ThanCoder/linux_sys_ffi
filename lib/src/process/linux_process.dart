import 'dart:ffi';

import 'package:linux_sys_ffi/src/process/process_bindings.dart';
import 'dart:io';

class ProcessItem {
  final int pid;
  final String name;
  ProcessItem({required this.pid, required this.name});

  @override
  String toString() => 'ProcessItem(pid: $pid, name: $name)';
}

class LinuxProcess {
  late final ProcessBindings _bindings;

  /// ### Used Lib -> `libc.so.6`
  LinuxProcess({String libPath = 'libc.so.6'}) {
    _bindings = ProcessBindings(DynamicLibrary.open(libPath));
  }

  /// လက်ရှိ Linux System ထဲမှာ Run နေတဲ့ active process list (PID နဲ့ Name) ကို ပြန်ပေးမယ်
  List<ProcessItem> getRunningProcesses() {
    final List<ProcessItem> processes = [];
    final procDir = Directory('/proc');

    if (!procDir.existsSync()) return processes;

    // /proc အောက်က နံပါတ်သီးသန့်ဖြစ်တဲ့ folder တွေက Process တွေဖြစ်ပါတယ်
    for (var entity in procDir.listSync()) {
      final name = entity.path.split('/').last;
      if (RegExp(r'^[0-9]+$').hasMatch(name)) {
        try {
          final commFile = File('${entity.path}/comm');
          if (commFile.existsSync()) {
            // processes.add({
            //   'pid': int.parse(name),
            //   'name': commFile.readAsStringSync().trim(),
            // });
            processes.add(
              ProcessItem(
                pid: int.parse(name),
                name: commFile.readAsStringSync().trim(),
              ),
            );
          }
        } catch (_) {}
      }
    }
    return processes;
  }

  /// 指定ထားသော PID ကို Native C `kill` အသုံးပြု၍ ပိတ်ပစ်မည်
  /// Return `true` ပြီးမြောက်လျှင်၊ `false` ပိတ်မရလျှင် (ဥပမာ- Permission မရှိခြင်း)
  bool killProcess(int pid) {
    // SIGKILL အမှတ်စဉ်က 9 ဖြစ်ပါတယ်
    const int sigKill = 9;

    // C API: kill(pid, signal)
    final int result = _bindings.kill(pid, sigKill);

    // C မှာ 0 ပြန်ပေးရင် success ဖြစ်ပြီး -1 ဆိုရင် fail ပါ
    return result == 0;
  }
}
