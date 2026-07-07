// ignore_for_file: unused_local_variable, unused_import

import 'dart:io';

import 'package:linux_sys_ffi/linux_sys_ffi.dart';
import 'package:linux_sys_ffi/src/file_selector/file_selector.dart';
import 'package:linux_sys_ffi/src/network/linux_wifi.dart';
import 'package:linux_sys_ffi/src/notification/linux_notify.dart';
import 'package:linux_sys_ffi/src/security/linux_security.dart';
import 'package:linux_sys_ffi/src/sound/linux_sound.dart';
import 'package:linux_sys_ffi/src/sys/linux_power.dart';
import 'package:linux_sys_ffi/src/sys/linux_sudo_prompt.dart';

void main() async {
  final sys = LinuxSysFfi.instance;
  final ffmpeg = sys.ffmpeg;

  // 1. Token တစ်ခု ဆောက်မယ်
  final cancelToken = FFmpegCancelToken();

  // 2. ၅ စက္ကန့်ပြည့်ရင် လမ်းဝက်ကနေ လှမ်းဖျက်ခိုင်းမယ့် စမ်းသပ်ချက်
  // Future.delayed(const Duration(seconds: 5), () {
  //   print("🛑 User က Cancel ခလုတ်ကို နှိပ်လိုက်ပါပြီ။");
  //   cancelToken.cancel();
  // });

  print('getWifiIpList: ${await sys.wifi.getWifiIpList()}');
  print('getAllActiveLocalIps: ${await sys.wifi.getAllActiveLocalIps()}');
  // print('getAllNetworkIps: ${await sys.wifi.getAllNetworkIps()}');
  for (var wifi in await sys.wifi.getWifiListNmCli()) {
    print("--------------------------------");
    print("SSID: ${wifi.ssid}");
    print("Signal: ${wifi.signalStrength}% (${wifi.bars})");
    print("Security: ${wifi.securityType}");
  }
}
