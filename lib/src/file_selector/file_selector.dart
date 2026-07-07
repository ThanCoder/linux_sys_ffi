import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:linux_sys_ffi/src/file_selector/gtk_bindings.dart';

class FileChooser {
  late GtkBindings _gtk;

  /// ### Use Lib -> `libgtk-3.so.0`
  FileChooser({String libPath = 'libgtk-3.so.0'}) {
    final lib = DynamicLibrary.open(libPath);
    _gtk = GtkBindings(lib);
    _gtk.gtk_init(nullptr, nullptr);
  }

  String? openFile() {
    final titlePtr = 'Select a File'.toNativeUtf8();
    final acceptLabelPtr = 'Open'.toNativeUtf8();
    final cancelLabelPtr = 'Cancel'.toNativeUtf8();

    // ၃။ Native File Chooser Dialog Instance တစ်ခု ဆောက်ခိုင်းမယ်
    // GTK_FILE_CHOOSER_ACTION_OPEN = 0 (File အဖွင့်အတွက်သုံးသော Enum Value)
    final dialogPtr = _gtk.gtk_file_chooser_native_new(
      titlePtr.cast(),
      nullptr, // Parent Window (မလိုလျှင် nullptr ထားနိုင်)
      GtkFileChooserAction.GTK_FILE_CHOOSER_ACTION_OPEN, // Action Type
      acceptLabelPtr.cast(),
      cancelLabelPtr.cast(),
    );

    String? selectedPath;

    // ၄။ Dialog ကြီးကို Screen ပေါ် တွန်းတင်ပြီး Run လိုက်မယ်
    // GTK_RESPONSE_ACCEPT = -3 (အကယ်၍ User က File တစ်ခုခုကို ရွေးပြီး Open နှိပ်ခဲ့ရင်)
    final response = _gtk.gtk_native_dialog_run(dialogPtr.cast());

    if (response == -3) {
      // User ရွေးချယ်လိုက်တဲ့ File ရဲ့ Native C-String Memory Pointer ကို လှမ်းယူမယ်
      final pathPtr = _gtk.gtk_file_chooser_get_filename(dialogPtr.cast());

      if (pathPtr != nullptr) {
        selectedPath = pathPtr.cast<Utf8>().toDartString();
      }
    }

    // Memory Pointer များကို စနစ်တကျ ပြန်ဖျက်ခြင်း
    calloc.free(titlePtr);
    calloc.free(acceptLabelPtr);
    calloc.free(cancelLabelPtr);

    return selectedPath;
  }
}
