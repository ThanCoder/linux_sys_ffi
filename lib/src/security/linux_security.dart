import 'dart:ffi';

import 'package:linux_sys_ffi/src/security/security_bindings.dart';

class LinuxSecurity {
  late final SecurityBindings _b;
  LinuxSecurity({String libPath = 'libc.so.6'}) {
    _b = SecurityBindings(DynamicLibrary.open(libPath));
  }
  bool get isRoot {
    return _b.geteuid() == 0;
  }
}
