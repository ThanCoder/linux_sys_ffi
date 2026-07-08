import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:linux_sys_ffi/src/pdf/poppler_bindings.dart';

class LinuxPoppler {
  late final PopplerBindings _bindings;
  Pointer<PopplerDocument>? _document;

  /// Poppler Document Pointer
  Pointer<PopplerDocument>? get documentPointer => _document;

  /// Constructor - Dynamic Library ကို Load လုပ်ပြီး bindings ကို initialize လုပ်မယ်
  LinuxPoppler({String libPath = 'libpoppler-glib.so.8'}) {
    _bindings = PopplerBindings(DynamicLibrary.open(libPath));
  }

  /// PDF ဖိုင်လမ်းကြောင်းကို ပေးပြီး Document ကို ဖွင့်လှစ်ခြင်း
  /// [pdfPath] သည် absolute သို့မဟုတ် relative path ဖြစ်ရပါမည်။
  bool open(String pdfPath) {
    // လက်ရှိ document ဖွင့်ထားရင် အရင်ပိတ်မယ်
    close();

    final uriPath = 'file://${File(pdfPath).absolute.path}';
    final Pointer<Char> cUri = uriPath.toNativeUtf8().cast<Char>();
    final Pointer<Pointer<GError>> error = nullptr.cast();

    // poppler_document_new_from_file ကို ခေါ်ယူခြင်း
    _document = _bindings.poppler_document_new_from_file(cUri, nullptr, error);

    malloc.free(cUri);

    return _document != nullptr;
  }

  /// PDF ရဲ့ စာမျက်နှာ စုစုပေါင်း အရေအတွက်ကို ရယူခြင်း
  /// စာမျက်နှာ ၃၀,၀၀၀ ကျော်ရှိလည်း Native ဘက်ကနေ တန်းတွက်လို့ အရမ်းမြန်ပါတယ်
  int getPageCount() {
    if (_document == null || _document == nullptr) return 0;
    return _bindings.poppler_document_get_n_pages(_document!);
  }

  /// စာမျက်နှာတစ်ခုချင်းစီရဲ့ Native Pointer ကို လှမ်းယူခြင်း (Zero-indexed ဖြစ်လို့ page 0 က အစဆုံးစာမျက်နှာပါ)
  /// ဒါကိုသုံးပြီး စာမျက်နှာအလိုက် LRU Cache စနစ် ဆောက်လို့ရပါတယ်
  Pointer<PopplerPage> getPage(int pageIndex) {
    if (_document == null || _document == nullptr) return nullptr;
    return _bindings.poppler_document_get_page(_document!, pageIndex);
  }

  /// တိကျတဲ့ စာမျက်နှာတစ်ခုကို Cairo Surface ပေါ်မှာ Render လုပ်ပြီး ပုံအဖြစ် ပြောင်းရန်
  /// (UI Viewer ဆောက်တဲ့အခါ ဒီကောင်ကို အဓိက သုံးရမှာပါ)
  void renderPageToCairo(Pointer<PopplerPage> page, Pointer<cairo_t> cr) {
    if (page == nullptr || cr == nullptr) return;
    _bindings.poppler_page_render(page, cr);
  }

  /// ပွင့်နေတဲ့ စာမျက်နှာ Pointer ကို Memory ပေါ်ကနေ ပြန်ဖျက်ခြင်း
  void freePage(Pointer<PopplerPage> page) {
    if (page != nullptr) {
      _bindings.g_object_unref(page.cast<Void>());
    }
  }

  /// Memory Leak မဖြစ်အောင်ဖွင့်ထားတဲ့ Document ကို ပြန်ပိတ်ပြီး Resource တွေ ပြန်လွှတ်ပေးခြင်း
  void close() {
    if (_document != null && _document != nullptr) {
      _bindings.g_object_unref(_document!.cast<Void>());
      _document = nullptr;
    }
  }
}
