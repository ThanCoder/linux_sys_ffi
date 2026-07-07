// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:linux_sys_ffi/src/notification/notify_bindings.dart';

class Notify {
  static Future<void> sendTerminal({
    required String title,
    required String body,
  }) async {
    await Process.run('notify-send', [title, body]);
  }

  late NotifyBindings _bindings;

  Notify init(String appName) {
    _bindings = NotifyBindings(DynamicLibrary.open('libnotify.so.4'));
    final app_name = appName.toNativeUtf8();
    _bindings.notify_init(app_name.cast<Char>());
    return this;
  }

  Notify show(String title, String body) {
    final c_title = title.toNativeUtf8();
    final c_body = body.toNativeUtf8();
    final c_icon = 'dialog-information'.toNativeUtf8();

    final noti = _bindings.notify_notification_new(
      c_title.cast<Char>(),
      c_body.cast<Char>(),
      c_icon.cast<Char>(),
    );
    _bindings.notify_notification_show(noti, nullptr);

    calloc.free(c_title);
    calloc.free(c_body);
    calloc.free(c_icon);
    return this;
  }

  void close() {
    _bindings.notify_uninit();
  }
}
