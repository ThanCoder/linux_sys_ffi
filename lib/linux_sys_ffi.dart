library;

import 'package:linux_sys_ffi/src/client/curl_client.dart';
import 'package:linux_sys_ffi/src/ffmpeg/linux_ffmpeg.dart';
import 'package:linux_sys_ffi/src/network/linux_wifi.dart';
import 'package:linux_sys_ffi/src/notification/linux_notify.dart';
import 'package:linux_sys_ffi/src/pdf/pdf.dart';
import 'package:linux_sys_ffi/src/process/linux_process.dart';
import 'package:linux_sys_ffi/src/screenshot/screenshot.dart';
import 'package:linux_sys_ffi/src/sys/linux_battery.dart';
import 'package:linux_sys_ffi/src/sys/linux_brightness.dart';
import 'package:linux_sys_ffi/src/sys/linux_distro.dart';
import 'package:linux_sys_ffi/src/sys/linux_launcher.dart';
import 'package:linux_sys_ffi/src/sys/linux_power.dart';
import 'package:linux_sys_ffi/src/sys/linux_sudo_prompt.dart';
import 'package:linux_sys_ffi/src/sys/linux_sys_info.dart';
import 'package:linux_sys_ffi/src/webview/linux_webkit.dart';

import 'src/security/linux_security.dart';
import 'src/sound/linux_sound.dart';

export 'src/ffmpeg/ffmpeg_cancel_token.dart';
export 'src/ffmpeg/ffmpeg_audio_format.dart';
export 'src/ffmpeg/ffmpeg_audio_bitrate.dart';
export 'src/network/network_types.dart';

class LinuxSysFfi {
  // Singleton pattern သုံးထားလို့ instance တစ်ခုတည်းနဲ့ သုံးနိုင်ပါတယ်
  static final LinuxSysFfi instance = LinuxSysFfi._internal();
  LinuxSysFfi._internal();

  final _battery = LinuxBattery();
  final _brightness = LinuxBrightness();
  final _security = LinuxSecurity();
  final _sound = LinuxSound();
  final _wifi = LinuxWifi();
  final _noti = LinuxNotify();
  final _sudoPrompt = LinuxSudoPrompt();
  final _power = LinuxPower();
  final _sysInfo = LinuxSysInfo();
  final _distro = LinuxDistro();
  final _launcher = LinuxLauncher();
  final _process = LinuxProcess();
  final _ffmpeg = LinuxFFmpeg();
  final _screenshot = Screenshot();
  final _pdf = Pdf();
  final _curl = CurlClient();

  // getter;
  CurlClient get curl => _curl;
  Pdf get pdf => _pdf;
  Screenshot get screenshot => _screenshot;
  LinuxFFmpeg get ffmpeg => _ffmpeg;
  LinuxProcess get process => _process;
  LinuxLauncher get launcher => _launcher;
  LinuxDistro get distro => _distro;
  LinuxSysInfo get sysInfo => _sysInfo;
  LinuxPower get power => _power;
  LinuxSudoPrompt get sudoPrompt => _sudoPrompt;
  LinuxNotify get notify => _noti;
  LinuxBattery get battery => _battery;
  LinuxBrightness get brightness => _brightness;
  LinuxSecurity get security => _security;
  LinuxSound get sound => _sound;
  LinuxWifi get wifi => _wifi;
}
