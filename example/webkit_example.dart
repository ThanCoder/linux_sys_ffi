import 'dart:async';
import 'dart:isolate';
import 'package:linux_sys_ffi/src/webview/linux_webkit.dart';

void main() async {
  // ၁ စက္ကန့် တစ်ခါ စာလှမ်းရိုက်မယ့် Timer ဆောက်ခြင်း
  final loop = Timer.periodic(Duration(seconds: 1), (timer) {
    print("Dart Event Loop အလုပ်လုပ်နေတုန်းပဲ... Second: ${timer.tick}");
  });
  await openGtkWindow();
  loop.cancel();
}

// Flutter UI ထဲက ခလုတ်တစ်ခုခု နှိပ်လိုက်ချိန်မှာ ဒီလိုလှမ်းခေါ်ရပါမယ်
Future<void> openGtkWindow() async {
  // Background thread (Isolate) အသစ်တစ်ခု ဆောက်ပြီး အလုပ်ခိုင်းလိုက်တာပါ
  final receive = ReceivePort();
  await Isolate.spawn(runGtkBackground, receive.sendPort);
  await receive.first;
}

// ဒီ function က Background ထဲမှာ သီးသန့်အလုပ်လုပ်မှာဖြစ်လို့ Flutter UI ကို မထိခိုက်တော့ပါ
void runGtkBackground(SendPort sendPort) async {
  final receive = ReceivePort();

  final w = LinuxWebkit();
  w.createWindow(width: 400, height: 400);
  w.loadUrl("https://pub.dev/");

  print("GTK Loop running in background...");
  // final res = await w.runJs('window.title');
  // print(res);

  w.startLoop(); // ဒီမှာ Block ဖြစ်လည်း background မှာပဲဖြစ်လို့ ကိစ္စမရှိပါ
  w.close();

  sendPort.send(receive.sendPort);
}
