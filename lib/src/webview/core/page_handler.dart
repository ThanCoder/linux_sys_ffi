part of '../linux_webkit.dart';

mixin PageHandler on IWebkit {
  set _bindings(WebKitBindings res);
  set _window(Pointer<GtkWidget> res);
  set _webView(Pointer<GtkWidget> res);

  /// အရေးကြီး - Callback ကို GC က မစားသွားအောင် Class Level မှာ သိမ်းထားရပါမယ်
  NativeCallable<Void Function()>? _destroyCallback;
  NativeCallable<Void Function(Pointer<Void>, Int32, Pointer<Void>)>?
  _loadedCallback;
  NativeCallable<Void Function(Pointer<Void>, Pointer<Void>, Pointer<Void>)>?
  _scriptMessageCallback;
  void Function()? _onPageLoadedCallback;
  void onPageLoaded(void Function() callback) {
    _onPageLoadedCallback = callback;
  }

  void _onPageLoaded(
    Pointer<Void> view,
    int loadEvent,
    Pointer<Void> userData,
  ) {
    // page loaded

    if (loadEvent == 3 && _onPageLoadedCallback != null) {
      _onPageLoadedCallback!();
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
    // _webView = _bindings.webkit_web_view_new();

    if (_window == null) {
      throw Exception('Failed to initialize GTK Window');
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
    // 💡 ၁။ User Content Manager ကို ဆောက်ပြီး "external" ဆိုပြီး Register လုပ်မယ်
    final cm = _bindings.webkit_user_content_manager_new();
    final cHandlerName = 'external'.toNativeUtf8();
    _bindings.webkit_user_content_manager_register_script_message_handler(
      cm,
      cHandlerName.cast<Char>(),
    );
    calloc.free(cHandlerName);

    // 💡 ၂။ JS ကနေ လှမ်းခေါ်ရင် Dart ဘက်က ဖမ်းမယ့် callback ကို ချိတ်မယ်
    _scriptMessageCallback =
        NativeCallable<
          Void Function(Pointer<Void>, Pointer<Void>, Pointer<Void>)
        >.listener(_onScriptMessageReceived);

    final cSignal = 'script-message-received::external'.toNativeUtf8();
    _bindings.g_signal_connect_data(
      cm.cast<Void>(),
      cSignal.cast<Char>(),
      _scriptMessageCallback!.nativeFunction.cast(),
      nullptr,
      nullptr,
      GConnectFlags.G_CONNECT_DEFAULT,
    );
    calloc.free(cSignal);

    // 💡 ၃။ WebView ကို Content Manager နဲ့ တွဲပြီး ဆောက်မယ်
    // (သင့် bindings ထဲမှာ webkit_web_view_new_with_user_content_manager ပါရပါမယ်)
    _webView = _bindings.webkit_web_view_new_with_user_content_manager(cm);
    _bindings.gtk_container_add(_window!.cast<GtkContainer>(), _webView!);

    _eventListener();

    _bindings.gtk_widget_show_all(_window!);
  }

  void _eventListener() {
    // ပြင်ဆင်ရန်နေရာ: local variable မဟုတ်ဘဲ class property ထဲ ထည့်သိမ်းလိုက်ပါ
    _destroyCallback = NativeCallable<Void Function()>.listener(
      // သူက IWebkit override method
      close,
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
    calloc.free(destroySignal);
    // page loaded
    _loadedCallback =
        NativeCallable<
          Void Function(Pointer<Void>, Int32, Pointer<Void>)
        >.listener(_onPageLoaded);

    // load changed
    final loadSignal = 'load-changed'.toNativeUtf8();
    _bindings.g_signal_connect_data(
      _webView!.cast<Void>(),
      loadSignal.cast<Char>(),
      _loadedCallback!.nativeFunction.cast(),
      nullptr,
      nullptr,
      GConnectFlags.G_CONNECT_DEFAULT,
    );
    calloc.free(loadSignal);
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
    calloc.free(cUrl);
  }

  bool _isLoopRunning = false;
  Completer<void>? _loopCompleter;

  Future<void> startLoop() async {
    if (_isLoopRunning) return;
    _isLoopRunning = true;
    _loopCompleter = Completer();

    final context = _bindings.g_main_context_default();

    // blocking မဖြစ်စေဘဲ Dart Event Loop ထဲမှာ GTK Event Loop ကို ကြားညှပ်မောင်းနှင်ခြင်း
    Future.doWhile(() async {
      if (!_isLoopRunning) return false;

      // may_block ကို 1 (true) ပေးရင် handle လုပ်စရာ event ရှိလာတဲ့အထိ စောင့်ပါမယ်။
      // ဒါပေမယ့် Dart runtime ကို မပိတ်ဆို့ဖို့ အောက်က Future.delayed နဲ့ တွဲသုံးပါမယ်။
      // လောလောဆယ် non-blocking (0) နဲ့ပဲ ညင်ညင်သာသာ ပတ်ကြည့်ရအောင်။
      final hasMoreEvents = _bindings.g_main_context_iteration(context, 0);

      // Dart ရဲ့ Microtask နဲ့ Asynchronous execution တွေ အသက်ရှူဖို့ အချိန်ပေးတာပါ
      await Future.delayed(Duration.zero);

      return _isLoopRunning;
    }).then((_) {
      if (_loopCompleter != null && !_loopCompleter!.isCompleted) {
        _loopCompleter!.complete();
      }
    });

    return _loopCompleter!.future;
  }

  void stopLoop() {
    _isLoopRunning = false;
  }

  bool _isDestroying = false;

  /// Window ကို ကိုယ်တိုင် ကုဒ်နဲ့ ပိတ်ချင်ရင် သုံးရန်
  void closePageHanlder() {
    if (_isDestroying) {
      return; // 💡 ဖျက်နေဆဲဆိုရင် အောက်ကကုဒ်တွေကို ထပ်မလုပ်တော့ဘူး
    }
    _isDestroying = true;
    // ၁။ Loop အရင် ရပ်ခိုင်းမယ်
    stopLoop();

    if (_window != null && _window != nullptr) {
      final windowPtr = _window!.cast<GtkWidget>();
      _window = nullptr;
      _webView = nullptr;

      _bindings.gtk_widget_destroy(windowPtr);
    }

    // ၃။ Callback တွေကို ပိတ်သိမ်းပါမယ်
    _destroyCallback?.close();
    _destroyCallback = null;
    _loadedCallback?.close();
    _loadedCallback = null;
    _scriptMessageCallback?.close();
    _scriptMessageCallback = null;

    _isDestroying = false; // Reset ပြန်လုပ်ပေးမယ်
  }
}
