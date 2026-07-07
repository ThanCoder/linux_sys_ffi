// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/src/process/linux_process_manager.dart ဥပမာပုံစံ
import 'dart:io';

class ProcessItem {
  final int pid;
  final String name;
  ProcessItem({required this.pid, required this.name});

  @override
  String toString() => 'ProcessItem(pid: $pid, name: $name)';
}

class LinuxProcessManager {
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
}
