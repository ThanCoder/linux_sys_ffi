import 'dart:io';

///sudo apt install gnome-screenshot
class ScrotScreenshot {
  final List<String> _args = [];

  /// Include borders (-b, --border)
  ScrotScreenshot includeBorder() {
    _args.add('-b');
    return this;
  }

  /// Take screenshot after specified delay [in seconds] (-d, --delay SEC)
  ScrotScreenshot delay(int seconds) {
    _args.add('-d');
    _args.add(seconds.toString());
    return this;
  }

  /// Interactively select a window or rectangle with the mouse (-s, --select)
  ScrotScreenshot selectArea() {
    _args.add('-s');
    return this;
  }

  /// Capture the currently focused window (-u, --focused)
  ScrotScreenshot focusedWindow() {
    _args.add('-u');
    return this;
  }

  /// Include the mouse pointer (cursor) in the shot (-p, --pointer)
  ScrotScreenshot includePointer() {
    _args.add('-p');
    return this;
  }

  /// Image quality [1-100] (-q, --quality NUM)
  /// Higher values mean less compression and larger file size.
  ScrotScreenshot quality(int num) {
    _args.add('-q');
    _args.add(num.toString());
    return this;
  }

  /// Generate a thumbnail (-t, --thumb % | WxH)
  /// e.g., '25' for 25% or '300x200' for specific pixels
  ScrotScreenshot thumbnail(String sizeOrPercentage) {
    _args.add('-t');
    _args.add(sizeOrPercentage);
    return this;
  }

  /// Crop a specific geometry (-a, --autocrop X,Y,W,H)
  ScrotScreenshot cropArea(int x, int y, int w, int h) {
    _args.add('-a');
    _args.add('$x,$y,$w,$h');
    return this;
  }

  /// Execute a command on the saved image (-e, --exec CMD)
  /// e.g., 'gimp $f' to open in Gimp immediately
  ScrotScreenshot executeOnSave(String command) {
    _args.add('-e');
    _args.add(command);
    return this;
  }

  /// X Display to use (-D, --display DISPLAY)
  ScrotScreenshot display(String displayTarget) {
    _args.add('-D');
    _args.add(displayTarget);
    return this;
  }

  /// Freeze the screen while choosing an area (-z, --freeze)
  /// Use with [selectArea]
  ScrotScreenshot freeze() {
    _args.add('-z');
    return this;
  }

  /// Print version information and exit
  Future<String> version() async {
    final result = await Process.run('scrot', ['-v']);
    return result.stdout.toString().trim();
  }

  /// Screenshot ရိုက်ပြီး သတ်မှတ်ထားတဲ့ ဖိုင်လမ်းကြောင်းထဲ တိုက်ရိုက်သိမ်းမည်။
  /// [filename] မပေးထားပါက scrot ရဲ့ default format (timestamp-အလိုက်) နဲ့ လက်ရှိ directory ထဲ သိမ်းပါလိမ့်မယ်။
  Future<ProcessResult> save([String? filename]) async {
    if (filename != null && filename.isNotEmpty) {
      _args.add(filename);
    }

    // နောက်ကွယ်ကနေ scrot ကို arguments တွေနဲ့ run ပေးခြင်း
    return await Process.run('scrot', _args);
  }
}
