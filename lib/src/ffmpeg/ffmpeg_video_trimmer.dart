import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_core.dart';

class FFmpegVideoTrimmer {
  final FFmpegCore _core;
  FFmpegVideoTrimmer(this._core);

  /// ဗီဒီယိုအား သတ်မှတ်ထားသော စက္ကန့်အလိုက် ဖြတ်တောက်မည်
  /// [start] - စတင်မည့်အချိန် (e.g., "00:01:20" သို့မဟုတ် စက္ကန့် "80")
  /// [duration] - ကြာမြင့်ချိန် စက္ကန့်
  Future<bool> trim({
    required String inputPath,
    required String outputPath,
    required String start,
    required Duration duration,
  }) async {
    // -ss က စမည့်အချိန်၊ -t က ကြာချိန်၊ -c copy က re-encode မလုပ်ဘဲ အမြန်ဖြတ်တာပါ
    final List<String> args = [
      '-ss',
      start,
      '-i',
      inputPath,
      '-t',
      '${duration.inSeconds}',
      '-c',
      'copy',
      outputPath,
    ];
    return await _core.execute(args);
  }
}
