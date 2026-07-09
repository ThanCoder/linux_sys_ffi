part of '../linux_webkit.dart';

abstract class IWebkit {
  WebKitBindings get _bindings;
  Pointer<GtkWidget>? get _window;
  Pointer<GtkWidget>? get _webView;

  void _onScriptMessageReceived(
    Pointer<Void> manager,
    Pointer<Void> jsResult,
    Pointer<Void> userData,
  );

  void close();
}
