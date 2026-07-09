part of '../linux_webkit.dart';

mixin JsHandler on IWebkit {
  //****************js*************************** */
  // JS Result ကို စောင့်မယ့် Completer
  Completer<String>? _jsCompleter;

  NativeCallable<
    Void Function(Pointer<GObject>, Pointer<GAsyncResult>, Pointer<Void>)
  >?
  _jsResultCallback;

  void closeJsHandler() {
    _jsResultCallback?.close();
    _jsResultCallback = null;
    _jsCompleter?.complete('');
    _jsCompleter = null;
  }

  Future<String?> runJsCode(String jsCode) async {
    if (_jsCompleter != null && !_jsCompleter!.isCompleted) {
      return Future.error("Previous JS execution is still pending.");
    }
    _jsCompleter = Completer<String>();

    // 💡 ဥပမာ - မင်း run ချင်တဲ့ JS ကုဒ်ရဲ့ output ကို variable တစ်ခုထဲထည့်ပြီး external channel ထံ ပို့ခိုင်းလိုက်တာပါ
    // ဥပမာ - runJsCode("document.title") လို့ ခေါ်ရင် အောက်က ကုဒ်က wrapper လုပ်ပေးသွားမှာပါ
    final wrappedJs =
        """
      (function() {
        try {
          var result = ($jsCode);
          window.webkit.messageHandlers.external.postMessage(String(result));
        } catch(e) {
          window.webkit.messageHandlers.external.postMessage("Error: " + e.message);
        }
      })();
    """;

    final c_jsCode = wrappedJs.toNativeUtf8();

    // finish callback မလိုတော့တဲ့အတွက် တိုက်ရိုက် run ခိုင်းလိုက်ရုံပါပဲ (callback နေရာမှာ nullptr ပေးခဲ့ပါ)
    _bindings.webkit_web_view_evaluate_javascript(
      _webView!.cast<WebKitWebView>(),
      c_jsCode.cast<Char>(),
      -1,
      nullptr,
      nullptr,
      nullptr,
      nullptr, // 💡 callback မလိုတော့ပါ
      nullptr,
    );

    calloc.free(c_jsCode);
    return _jsCompleter!.future;
  }

  /// JS ကနေ သတင်းအချက်အလက် ပို့လိုက်ရင် ဒီကို ရောက်လာပါမယ် (Thread Safe ဖြစ်ပြီးသားပါ)
  @override
  void _onScriptMessageReceived(
    Pointer<Void> manager,
    Pointer<Void> jsResult,
    Pointer<Void> userData,
  ) {
    try {
      // 💡 JavaScript Result ထဲကနေ string တန်ဖိုးကို ဆွဲထုတ်ခြင်း
      final jscValue = _bindings.webkit_javascript_result_get_js_value(
        jsResult.cast(),
      );
      if (jscValue != nullptr) {
        final jsStringPtr = _bindings.jsc_value_to_string(jscValue);
        if (jsStringPtr != nullptr) {
          final resultStr = jsStringPtr.cast<Utf8>().toDartString();

          // 💡 ရလာတဲ့ တန်ဖိုးကို Completer ထဲ ထည့်ပေးလိုက်တာပါ
          if (_jsCompleter != null && !_jsCompleter!.isCompleted) {
            _jsCompleter!.complete(resultStr);
          }

          // TODO: bindings ထဲက g_free ပါရင် jsStringPtr ကို free ပေးပါ
        }
      }
    } catch (e) {
      _jsCompleter?.completeError("Error parsing JS message: $e");
    } finally {
      // WebKit Javascript Result ကို memory ရှင်းပေးရပါမယ်
      _bindings.webkit_javascript_result_unref(jsResult.cast());
    }
  }
}
