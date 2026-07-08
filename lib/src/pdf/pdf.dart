import 'package:linux_sys_ffi/src/pdf/linux_poppler.dart';
import 'package:linux_sys_ffi/src/pdf/pdf_info.dart';

class Pdf {
  final _pdfInfo = PdfInfo();
  final _poppler = LinuxPoppler();

  PdfInfo get pdfInfo => _pdfInfo;
  LinuxPoppler get poppler => _poppler;
}
