import 'dart:io';

///sudo apt install gnome-screenshot
class GnomeScreenshot {
  // Arguments တွေကို သိမ်းထားမယ့် list
  final List<String> _args = [];

  /// Send the grab directly to the clipboard
  GnomeScreenshot clipboard() {
    _args.add('-c');
    return this;
  }

  /// Grab a window instead of the entire screen
  GnomeScreenshot window() {
    _args.add('-w');
    return this;
  }

  /// Grab an area of the screen instead of the entire screen
  GnomeScreenshot area() {
    _args.add('-a');
    return this;
  }

  /// Include the pointer (mouse cursor) with the screenshot
  GnomeScreenshot includePointer() {
    _args.add('-p');
    return this;
  }

  /// Take screenshot after specified delay [in seconds]
  GnomeScreenshot delay(int seconds) {
    _args.add('-d');
    _args.add(seconds.toString());
    return this;
  }

  /// Interactively set options
  GnomeScreenshot interactive() {
    _args.add('-i');
    return this;
  }

  /// X display to use
  GnomeScreenshot display(String displayTarget) {
    _args.add('--display=$displayTarget');
    return this;
  }

  /// Print version information and exit
  Future<String> version() async {
    final result = await Process.run('gnome-screenshot', ['--version']);
    return result.stdout.toString().trim();
  }

  /// Screenshot ရိုက်ပြီး သတ်မှတ်ထားတဲ့ ဖိုင်လမ်းကြောင်းထဲ တိုက်ရိုက်သိမ်းမည်။
  /// [filename] သည် သိမ်းဆည်းမည့် absolute կամ relative path ဖြစ်ရပါမည်။
  Future<ProcessResult> save(String filename) async {
    _args.add('-f');
    _args.add(filename);

    // နောက်ကွယ်ကနေ gnome-screenshot ကို arguments တွေနဲ့ run ပေးခြင်း
    return await Process.run('gnome-screenshot', _args);
  }

  /// ဖိုင်အဖြစ်မသိမ်းဘဲ Clipboard ထဲပဲ တိုက်ရိုက်ထည့်ချင်ရင် save() အစား ဒီကောင်ကို သုံးနိုင်ပါတယ်။
  Future<ProcessResult> captureToClipboard() async {
    if (!_args.contains('-c')) {
      _args.add('-c');
    }
    return await Process.run('gnome-screenshot', _args);
  }
}
