// ignore_for_file: unused_import

import 'dart:async';
import 'dart:isolate';
import 'package:linux_sys_ffi/linux_sys_ffi.dart';
import 'package:linux_sys_ffi/src/webview/linux_webkit.dart';

void main() async {
  final sys = LinuxSysFfi.instance;

  // Object ဆောက်ပြီး OOP Style (Method Chaining) ဖြင့် Configuration သတ်မှတ်ခြင်း
  var curl = sys.curl
      .setSilent(true)
      .setIncludeHeaders(true)
      .setUserAgent("DartCurlAgent/1.0");
  curl.verbose;
  curl.version;

  print(await curl.run());
}
