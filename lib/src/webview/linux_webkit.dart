import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:linux_sys_ffi/src/webview/webkit_bindings.dart';

part 'core/i_webkit.dart';
part 'core/js_handler.dart';
part 'core/page_handler.dart';

class LinuxWebkit extends IWebkit with JsHandler, PageHandler {
  @override
  late final WebKitBindings _bindings;
  @override
  Pointer<GtkWidget>? _window;
  @override
  Pointer<GtkWidget>? _webView;

  LinuxWebkit({String libPath = 'libwebkit2gtk-4.1.so.0'}) {
    _bindings = WebKitBindings(DynamicLibrary.open(libPath));
  }

  @override
  void close() {
    print("🧹 Total Cleanup initiated...");

    closePageHanlder();
    closeJsHandler();
  }
}
