// ignore_for_file: unused_local_variable, unused_import

import 'dart:ffi';
import 'dart:io';

import 'package:linux_sys_ffi/linux_sys_ffi.dart';
import 'package:linux_sys_ffi/src/file_selector/file_selector.dart';
import 'package:linux_sys_ffi/src/network/linux_wifi.dart';
import 'package:linux_sys_ffi/src/notification/linux_notify.dart';
import 'package:linux_sys_ffi/src/pdf/linux_poppler.dart';
import 'package:linux_sys_ffi/src/screenshot/screenshot.dart';
import 'package:linux_sys_ffi/src/security/linux_security.dart';
import 'package:linux_sys_ffi/src/sound/linux_sound.dart';
import 'package:linux_sys_ffi/src/sys/linux_power.dart';
import 'package:linux_sys_ffi/src/sys/linux_sudo_prompt.dart';

void main() async {
  final sys = LinuxSysFfi.instance;
  final pdfPath = '/home/thancoder/Documents/test1.pdf';

  // Instance ဆောက်မယ် (Default အနေနဲ့ System Poppler Lib ကို သုံးမယ်)
  final pdfTool = sys.pdf.poppler;

  // PDF ဖိုင်ကို ဖွင့်မယ်
  if (pdfTool.open(pdfPath)) {
    print('PDF ဖိုင်ကို အောင်မြင်စွာ ဖွင့်ပြီးပါပြီ။');

    // Page count တွက်မယ်
    int totalPages = pdfTool.getPageCount();
    print('စာမျက်နှာ စုစုပေါင်း: $totalPages');

    // ဥပမာ - ပထမဆုံးစာမျက်နှာ (Page 0) ကို ယူမယ်
    final pageZero = pdfTool.getPage(0);

    if (pageZero != nullptr) {
      print('စာမျက်နှာ 0 ကို Native Pointer အဖြစ် ရရှိပါပြီ။');

      // ဒီနေရာမှာ ကိုယ့်ရဲ့ LRU Cache သို့မဟုတ် Cairo UI Renderer ထဲ ထည့်သုံးနိုင်ပါတယ်

      // သုံးပြီးရင် စာမျက်နှာ pointer ကို ပြန်ဖျက်မယ်
      pdfTool.freePage(pageZero);
    }

    // အလုပ်ပြီးရင် Document ကို ပိတ်မယ်
    pdfTool.close();
  } else {
    print('PDF ဖိုင်ဖွင့်ရတာ အဆင်မပြေပါ။ လမ်းကြောင်း မှန်၊ မမှန် စစ်ဆေးပါ။');
  }
}
