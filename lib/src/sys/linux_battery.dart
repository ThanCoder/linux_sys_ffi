import 'dart:io';

enum BatteryStatus {
  unknown,
  discharging,
  charging;

  static BatteryStatus fromName(String name) {
    if (name == discharging.name || name == 'Discharging') {
      return discharging;
    }
    if (name == charging.name || name == 'Charging') {
      return charging;
    }
    return unknown;
  }
}

/// ### Binary Path
/// Laptop အလိုက် BAT0 သို့မဟုတ် BAT1 ဖြစ်နိုင်လို့ ရှာရပါမယ်
/// /sys/class/power_supply/BAT0
class LinuxBattery {
  ///
  final _batteryDir = Directory('/sys/class/power_supply/BAT0');
  bool get exists => _batteryDir.existsSync();

  int get capacity {
    if (!exists) return -1;
    try {
      final file = File('${_batteryDir.path}/capacity');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      print('[LinuxBattery:getCapacity]: $e');
      return -1;
    }
  }

  /// Battery အခြေအနေ (Charging, Discharging, Full) ကို ပြန်ပေးမယ်
  BatteryStatus get status {
    if (!exists) return .unknown;
    try {
      final file = File('${_batteryDir.path}/status');
      final status = file.readAsStringSync().trim(); // e.g., "Charging"
      return BatteryStatus.fromName(status);
    } catch (_) {
      return .unknown;
    }
  }

  String get capacityLevel {
    try {
      final file = File('${_batteryDir.path}/capacity_level');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  String get manufacturer {
    try {
      final file = File('${_batteryDir.path}/manufacturer');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  String get model_name {
    try {
      final file = File('${_batteryDir.path}/model_name');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  String get serial_number {
    try {
      final file = File('${_batteryDir.path}/serial_number');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  String get technology {
    try {
      final file = File('${_batteryDir.path}/technology');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  String get type {
    try {
      final file = File('${_batteryDir.path}/type');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  String get uevent {
    try {
      final file = File('${_batteryDir.path}/uevent');
      return file.readAsStringSync();
    } catch (e) {
      return 'Unknown';
    }
  }

  int get cycle_count {
    try {
      final file = File('${_batteryDir.path}/cycle_count');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get energy_full {
    try {
      final file = File('${_batteryDir.path}/energy_full');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get energy_full_design {
    try {
      final file = File('${_batteryDir.path}/energy_full_design');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get energy_now {
    try {
      final file = File('${_batteryDir.path}/energy_now');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get power_now {
    try {
      final file = File('${_batteryDir.path}/power_now');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get present {
    try {
      final file = File('${_batteryDir.path}/present');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get voltage_min_design {
    try {
      final file = File('${_batteryDir.path}/voltage_min_design');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }

  int get voltage_now {
    try {
      final file = File('${_batteryDir.path}/voltage_now');
      return int.parse(file.readAsStringSync().trim());
    } catch (e) {
      return -1;
    }
  }
}
