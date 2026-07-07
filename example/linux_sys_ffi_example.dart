// ignore_for_file: unused_import

import 'dart:io';

import 'package:linux_sys_ffi/src/file_selector/file_selector.dart';
import 'package:linux_sys_ffi/src/notification/notify.dart';

void main() async {
  // await Process.run('notify-send', ['ခေါင်းစဉ်', 'မက်ဆေ့ခ်ျ အကြောင်းအရာပါဗျာ']);
  Notify().init('appName').show('title', 'body').close();
  // final selector = FileChooser();
  // selector.init();
  // final res = selector.openFile();
  // print(res);
}
