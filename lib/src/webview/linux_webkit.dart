import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:linux_sys_ffi/src/webview/webkit_bindings.dart';

class LinuxWebkit {
  late final WebKitBindings _bindings;
  Pointer<GtkWidget>? _window;
  Pointer<GtkWidget>? _webView;

  LinuxWebkit({String libPath = 'libwebkit2gtk-4.1.so.0'}) {
    _bindings = WebKitBindings(DynamicLibrary.open(libPath));
  }

  // / အရေးကြီး - Callback ကို GC က မစားသွားအောင် Class Level မှာ သိမ်းထားရပါမယ်
  NativeCallable<Void Function()>? _destroyCallback;

  void _onPageLoaded(Pointer<Void> view, int loadEvent) {
    // page loaded
    if (loadEvent == 3) {
      print('loaded event: $loadEvent');
    }
  }

  /// GTK Window နဲ့ WebKit WebView ကို ဆောက်ပြီး Window ပေါ်တင်ပေးမည့် Method
  void createWindow({
    String title = 'Linux Native WebKit',
    int width = 1024,
    int height = 768,
  }) {
    _bindings.gtk_init(nullptr, nullptr);
    _window = _bindings.gtk_window_new(GtkWindowType.GTK_WINDOW_TOPLEVEL);
    _webView = _bindings.webkit_web_view_new();

    if (_window == null || _webView == null) {
      throw Exception('Failed to initialize GTK Window or WebKit WebView');
    }
    final c_title = title.toNativeUtf8();
    _bindings.gtk_window_set_title(
      _window!.cast<GtkWindow>(),
      c_title.cast<Char>(),
    );
    calloc.free(c_title);

    _bindings.gtk_window_set_default_size(
      _window!.cast<GtkWindow>(),
      width,
      height,
    );

    _bindings.gtk_container_add(_window!.cast<GtkContainer>(), _webView!);

    // ပြင်ဆင်ရန်နေရာ: local variable မဟုတ်ဘဲ class property ထဲ ထည့်သိမ်းလိုက်ပါ
    _destroyCallback = NativeCallable<Void Function()>.isolateLocal(
      _bindings.gtk_main_quit,
    );

    final destroySignal = 'destroy'.toNativeUtf8();
    _bindings.g_signal_connect_data(
      _window!.cast<Void>(),
      destroySignal.cast<Char>(),
      _destroyCallback!.nativeFunction, // class property က pointer ကို ပေးမယ်
      nullptr,
      nullptr,
      GConnectFlags.G_CONNECT_DEFAULT,
    );
    malloc.free(destroySignal);
    // page loaded
    final loadedCallback =
        NativeCallable<Void Function(Pointer<Void>, Int32)>.isolateLocal(
          _onPageLoaded,
        );
    // loaded
    final loadSignal = 'load-changed'.toNativeUtf8();
    _bindings.g_signal_connect_data(
      _webView!.cast<Void>(),
      loadSignal.cast<Char>(),
      loadedCallback.nativeFunction.cast(),
      nullptr,
      nullptr,
      GConnectFlags.G_CONNECT_DEFAULT,
    );
    calloc.free(loadSignal);

    _bindings.gtk_widget_show_all(_window!);
  }

  /// သတ်မှတ်ထားတဲ့ URL ကို Load လုပ်ခိုင်းခြင်း
  void loadUrl(String url) {
    if (_webView == null || _webView == nullptr) {
      print('WebView is not initialized. Call createWindow() first.');
      return;
    }
    final cUrl = url.toNativeUtf8();
    _bindings.webkit_web_view_load_uri(
      _webView!.cast<WebKitWebView>(),
      cUrl.cast<Char>(),
    );
    malloc.free(cUrl);
  }

  /// GTK Main Loop ကို စတင်မောင်းနှင်ခြင်း (ဒါခေါ်မှ Window က အသက်ဝင်လာမှာပါ)
  void startLoop() {
    _bindings.gtk_main();
  }

  /// Window ကို ကိုယ်တိုင် ကုဒ်နဲ့ ပိတ်ချင်ရင် သုံးရန်
  void close() {
    // ⚠️ gtk_widget_destroy ကို ဖြုတ်လိုက်ပါပြီ (Crash မဖြစ်တော့အောင်)
    _window = nullptr;
    _webView = nullptr;

    // Callback pointer ကို ပိတ်သိမ်းပေးပါ
    _destroyCallback?.close();
    _destroyCallback = null;
    print('close webkit');
  }

  //****************js*************************** */
  // JS Result ကို စောင့်မယ့် Completer
  Completer<String>? _jsCompleter;

  // Callback signature ကို webkit_web_view_evaluate_javascript ရဲ့ သတ်မှတ်ချက်အတိုင်း ပြောင်းလဲကြေညာပါမယ်
  NativeCallable<
    Void Function(Pointer<GObject>, Pointer<GAsyncResult>, Pointer<Void>)
  >?
  _jsResultCallback;

  Future<String?> runJs(String jsCode) async {
    if (_jsCompleter != null && _jsCompleter!.isCompleted) {
      return Future.error("Previous JS execution is still pending.");
    }
    _jsCompleter = Completer<String>();
    final cJsCode = jsCode.toNativeUtf8();

    // String length ကို ယူခြင်း (WebKit က string အလျားကို လိုအပ်လို့ပါ)
    final jsLength = cJsCode.length;

    // Callback Setup (အထဲက parameters ၃ ခုကို သတိပြုပါ)
    _jsResultCallback =
        NativeCallable<
          Void Function(Pointer<GObject>, Pointer<GAsyncResult>, Pointer<Void>)
        >.isolateLocal(_onJsResultReady);

    // evaluate javascript ခေါ်ခြင်း
    _bindings.webkit_web_view_evaluate_javascript(
      _webView!.cast<WebKitWebView>(),
      cJsCode.cast<Char>(),
      jsLength,
      nullptr, // world_name (null ပေးလို့ရပါတယ်)
      nullptr, // source_uri (null ပေးလို့ရပါတယ်)
      nullptr, // cancellable
      _jsResultCallback!
          .nativeFunction, // cast() လုပ်စရာမလိုတော့ပါ၊ signature ကွက်တိမို့လို့ပါ
      nullptr, // user_data
    );

    malloc.free(cJsCode);
    return _jsCompleter!.future;
  }

  void _onJsResultReady(
    Pointer<GObject> sourceObject,
    Pointer<GAsyncResult> res,
    Pointer<Void> userData,
  ) {
    try {
      // ၁။ evaluate_javascript_finish ကနေ Pointer<_JSCValue> ကို တိုက်ရိုက် ရပါမယ်
      final jscValue = _bindings.webkit_web_view_evaluate_javascript_finish(
        sourceObject.cast<WebKitWebView>(),
        res.cast<GAsyncResult>(),
        nullptr,
      );

      if (jscValue != nullptr) {
        // ၂။ ကြားထဲက webkit_javascript_result_get_js_value ကို ကျော်ပြီး
        // jsc_value_to_string ထဲ တန်းထည့်လို့ ရပါပြီ
        final jsStringPtr = _bindings.jsc_value_to_string(
          jscValue.cast<JSCValue>(),
        );

        if (jsStringPtr != nullptr) {
          final resultString = jsStringPtr.cast<Utf8>().toDartString();

          // 🎯 Completer ထဲ ရလဒ်ထည့်ပေးခြင်း
          _jsCompleter?.complete(resultString);

          // GLib ရဲ့ သတ်မှတ်ချက်အရ jsc_value_to_string က ပြန်ပေးတဲ့ string ကို g_free လုပ်ပေးရပါမယ်
          // သင့် bindings ထဲမှာ g_free ရှိရင် ခေါ်ပေးပါ (မရှိရင် ခဏချန်ထားနိုင်ပါတယ်)
          // _bindings.g_free(jsStringPtr.cast());
        } else {
          _jsCompleter?.completeError("Failed to convert JSCValue to String.");
        }

        // JSCValue ကို unref လုပ်ပေးရန် (Memory leak မဖြစ်အောင်)
        // _bindings.g_object_unref(jscValue.cast());
      } else {
        _jsCompleter?.completeError(
          "JS evaluation returned null (JSCValue is nullptr).",
        );
      }
    } catch (e) {
      _jsCompleter?.completeError("Failed to get JS result: $e");
    } finally {
      // သုံးပြီးသား Callback ကို ပိတ်သိမ်းခြင်း
      _jsResultCallback?.close();
      _jsResultCallback = null;
    }
  }
}
