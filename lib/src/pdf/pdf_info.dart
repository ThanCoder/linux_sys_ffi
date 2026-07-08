import 'dart:convert';
import 'dart:io';

class PdfInfo {
  // pdfinfo binary ရဲ့ path (System environment ထဲမှာ ရှိပြီးသားဆိုရင် 'pdfinfo' လို့ပဲ ထားနိုင်ပါတယ်)
  final String exePath;

  PdfInfo({this.exePath = 'pdfinfo'});

  /// PDF ရဲ့ အခြေခံအချက်အလက်များကို ရယူရန်
  Future<PdfMetadata> getInfo(
    String pdfPath, {
    String? userPassword,
    String? ownerPassword,
  }) async {
    final arguments = <String>[];

    if (userPassword != null) arguments.addAll(['-upw', userPassword]);
    if (ownerPassword != null) arguments.addAll(['-opw', ownerPassword]);

    arguments.add(pdfPath);

    final result = await Process.run(exePath, arguments);

    if (result.exitCode != 0) {
      throw ProcessException(
        exePath,
        arguments,
        result.stderr.toString(),
        result.exitCode,
      );
    }

    return PdfMetadata.fromStdout(result.stdout.toString());
  }
}

/// PDF Metadata များကို သိမ်းဆည်းမယ့် Data Class
class PdfMetadata {
  final String? title;
  final String? author;
  final String? creator;
  final String? producer;
  final int? pages;
  final String? pageSize;
  final String? fileSize;
  final bool encrypted;
  final String? pdfVersion;

  // raw output ကိုပါ သိမ်းထားချင်ရင်
  final Map<String, String> rawFields;

  PdfMetadata({
    this.title,
    this.author,
    this.creator,
    this.producer,
    this.pages,
    this.pageSize,
    this.fileSize,
    this.encrypted = false,
    this.pdfVersion,
    required this.rawFields,
  });

  /// Terminal ကထွက်လာတဲ့ Output text ကို Parse လုပ်ပြီး Object ဆောက်ပေးမယ့် Factory Constructor
  factory PdfMetadata.fromStdout(String stdout) {
    final lines = LineSplitter.split(stdout);
    final Map<String, String> fields = {};

    for (var line in lines) {
      if (line.contains(':')) {
        final index = line.indexOf(':');
        final key = line.substring(0, index).trim();
        final value = line.substring(index + 1).trim();
        fields[key] = value;
      }
    }

    return PdfMetadata(
      title: fields['Title'],
      author: fields['Author'],
      creator: fields['Creator'],
      producer: fields['Producer'],
      pages: int.tryParse(fields['Pages'] ?? ''),
      pageSize: fields['Page size'],
      fileSize: fields['File size'],
      encrypted: fields['Encrypted']?.toLowerCase().startsWith('yes') ?? false,
      pdfVersion: fields['PDF version'],
      rawFields: fields,
    );
  }

  @override
  String toString() {
    return 'PdfMetadata(Title: $title, Pages: $pages, Version: $pdfVersion, Encrypted: $encrypted)';
  }
}
