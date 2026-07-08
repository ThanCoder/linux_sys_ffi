import 'package:linux_sys_ffi/src/screenshot/gnome_screenshot.dart';
import 'package:linux_sys_ffi/src/screenshot/scrot_screenshot.dart';

class Screenshot {
  final _gnome = GnomeScreenshot();
  final _scrot = ScrotScreenshot();

  ///sudo apt install gnome-screenshot
  GnomeScreenshot get gnome => _gnome;

  ///sudo apt install gnome-screenshot
  ScrotScreenshot get scrot => _scrot;
}
