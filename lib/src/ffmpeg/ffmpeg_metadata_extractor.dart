import 'dart:convert';
import 'dart:io';
import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_core.dart';

class FFmpegMetadataExtractor {
  final FFmpegCore _core;
  FFmpegMetadataExtractor(this._core);

  /// ၁။ Audio/Video ဖိုင်ထဲမှ Metadata (Tags) များကို Map အနေဖြင့် ဆွဲထုတ်မည်
  Future<Map<String, String>> getTags(String inputPath) async {
    if (!await _core.isAvailable()) return {};

    // ffprobe သုံးပြီး tag တွေကို JSON format နဲ့ ထုတ်ခိုင်းတာပါ
    final result = await Process.run('ffprobe', [
      '-v',
      'error',
      '-show_entries',
      'format_tags',
      '-of',
      'json',
      inputPath,
    ]);

    if (result.exitCode != 0) return {};

    try {
      final Map<String, dynamic> data = jsonDecode(result.stdout.toString());
      if (data.containsKey('format') && data['format'].containsKey('tags')) {
        final Map<String, dynamic> rawTags = data['format']['tags'];

        // အပြင်က သုံးရလွယ်အောင် ကီးတွေကို စာလုံးအသေး (lowercase) ပြောင်းပြီး Map<String, String> နဲ့ ပြန်ပေးမယ်
        return rawTags.map(
          (key, value) => MapEntry(key.toLowerCase(), value.toString()),
        );
      }
    } catch (e) {
      print("Metadata Parsing Error: $e");
    }

    return {};
  }

  /// ၂။ Audio/Video ထဲတွင် မြှုပ်နှံထားသော Album Art / Cover Image (Thumbnail) ကို ဆွဲထုတ်မည်
  /// [inputPath] - မူရင်း မီဒီယာဖိုင်လမ်းကြောင်း
  /// [outputPath] - ထွက်လာမည့် ပုံဖိုင်လမ်းကြောင်း (e.g., '/tmp/cover.jpg')
  Future<bool> extractAudioThumbnail({
    required String inputPath,
    required String outputPath,
  }) async {
    // -an က audio ကိုကျော်မယ်၊ -vcodec copy က re-encode မလုပ်ဘဲ မူရင်းပုံ format အတိုင်း (များသောအားဖြင့် mjpeg) အမြန်ဆွဲထုတ်တာပါ
    // [0:v] က ပထမဆုံး ဗီဒီယို သို့မဟုတ် ပုံ track ကို ရွေးတာဖြစ်ပါတယ်
    final List<String> args = [
      '-i', inputPath,
      '-map', '0:v',
      '-map', '-0:a', // အော်ဒီယို track ပါလာရင် ဖယ်ထုတ်ရန်
      '-c:v', 'copy',
      '-f', 'image2',
      outputPath,
    ];

    return await _core.execute(args);
  }

  /// ၃။ ဗီဒီယိုဖိုင်မှ သတ်မှတ်ထားသော အချိန်နေရာရှိ Frame အား Thumbnail ပုံအဖြစ် ဆွဲထုတ်မည်
  /// [inputPath] - မူရင်း ဗီဒီယိုလမ်းကြောင်း
  /// [outputPath] - ထွက်လာမည့် ပုံလမ်းကြောင်း (e.g., '/home/user/Pictures/thumb.jpg')
  /// [time] - ဘယ်အချိန်က frame ကို ယူမလဲ (e.g., `Duration(seconds: 5)` ဆိုလျှင် ၅ စက္ကန့်မြောက်နေရာ)
  Future<bool> extractVideoThumbnail({
    required String inputPath,
    required String outputPath,
    Duration time = const Duration(seconds: 1),
    int? width,
    int? height,
  }) async {
    // Duration အား HH:MM:SS ပုံစံပြောင်းလဲခြင်း
    final String timeString = _formatDuration(time);

    final List<String> args = ['-ss', timeString, '-i', inputPath];

    // Width နှင့် Height သတ်မှတ်ချက် ရှိ/မရှိ စစ်ဆေးပြီး video filter (scale) ထည့်သွင်းခြင်း
    if (width != null && height != null) {
      args.addAll(['-vf', 'scale=$width:$height']);
    } else if (width != null) {
      // width ပဲပေးပြီး height မပေးရင် aspect ratio မပျက်အောင် -1 ထည့်ပေးရပါတယ်
      args.addAll(['-vf', 'scale=$width:-1']);
    } else if (height != null) {
      // height ပဲပေးပြီး width မပေးရင် aspect ratio မပျက်အောင် -1 ထည့်ပေးရပါတယ်
      args.addAll(['-vf', 'scale=-1:$height']);
    }

    // ၁ ပုံပဲ ထုတ်ယူမည့်အပြင် အရည်အသွေး ကောင်းမွန်စေရန် သတ်မှတ်ခြင်း
    args.addAll(['-vframes', '1', '-q:v', '2', outputPath]);

    return await _core.execute(args);
  }

  /// Duration အား FFmpeg အတွက် string ပြောင်းပေးမည့် helper
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(d.inHours);
    final String minutes = twoDigits(d.inMinutes.remainder(60));
    final String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
