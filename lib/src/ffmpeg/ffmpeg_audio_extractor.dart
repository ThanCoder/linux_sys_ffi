import 'package:linux_sys_ffi/linux_sys_ffi.dart';
import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_core.dart';

class FFmpegAudioExtractor {
  final FFmpegCore _core;
  FFmpegAudioExtractor(this._core);

  /// Video မှ Audio Format မျိုးစုံသို့ ခွဲထုတ်ပေးမည်
  Future<bool> extract({
    required String videoPath,
    required String outputPath,
    FFmpegAudioBitrate bitrate = .ultra,
    FFmpegAudioFormat format = .m4a,
  }) async {
    // အခြေခံ FFmpeg options များ
    List<String> args = ['-i', videoPath, '-vn', '-acodec', format.codec];

    // Format အလိုက် သီးသန့်ပေးရမည့် Arguments များကို စစ်ထုတ်ခြင်း
    if (format == FFmpegAudioFormat.mp3 || format == FFmpegAudioFormat.m4a) {
      args.addAll(['-b:a', bitrate.value]);
    } else if (format == FFmpegAudioFormat.ogg) {
      args.addAll(['-q:a', '6']); // OGG code အတွက် standard quality filter
    }

    args.add(outputPath);
    return await _core.execute(args);
  }

  /// Video မှ Audio Format မျိုးစုံသို့ ခွဲထုတ်ပေးမည် (Progress ပြန်ပေးမည်)
  /// Video မှ Audio Format မျိုးစုံသို့ ခွဲထုတ်ပေးမည် (Enum Options ပါဝင်သည်)
  /// [outputDirectory] - အော်ဒီယိုသိမ်းမည့် folder လမ်းကြောင်း (e.g., '/home/user/Music')
  /// [fileName] - ဖိုင်အမည် (နောက်ပိတ်ဆုံး extension ထည့်ရန်မလိုပါ၊ e.g., 'my_song')
  /// [format] - ပြောင်းလဲချင်သော အော်ဒီယိုအမျိုးအစား (e.g., `FFmpegAudioFormat.mp3`)
  Future<bool> extractWithProgress({
    required String videoPath,
    required String outputDirectory,
    required String fileName,
    FFmpegAudioFormat format = .m4a,
    required void Function(double progress) onProgress,
    FFmpegAudioBitrate bitrate = .ultra,
    FFmpegCancelToken? cancelToken,
    // အသစ်ထပ်တိုးလိုက်သော အဆင့်မြင့် options များ
    bool overwrite = true,
    bool keepMetadata = true,
    Duration? startTime,
    Duration? endTime,
  }) async {
    final String fullOutputPath =
        "$outputDirectory/$fileName.${format.extension}";
    List<String> args = [];

    // ၁။ Start Time သတ်မှတ်ချက်ရှိလျှင် ထည့်မည် (-ss)
    // -ss ကို -i ရဲ့ ရှေ့မှာ ထားခြင်းက FFmpeg ကို ပိုမိုမြန်ဆန်စွာ seek လုပ်စေနိုင်ပါတယ်
    if (startTime != null) {
      args.addAll(['-ss', _formatDuration(startTime)]);
    }

    // ၂။ Input File သတ်မှတ်ခြင်း
    args.addAll(['-i', videoPath]);

    // ၃။ End Time သို့မဟုတ် Duration သတ်မှတ်ချက်ရှိလျှင် ထည့်မည် (-to)
    if (endTime != null) {
      args.addAll(['-to', _formatDuration(endTime)]);
    }

    // ၄။ Video ကို ဖယ်ထုတ်ပြီး အော်ဒီယို Codec သတ်မှတ်ခြင်း
    args.addAll(['-vn', '-acodec', format.codec]);

    // ၅။ Metadata သယ်ဆောင်မည့် သတ်မှတ်ချက်
    if (!keepMetadata) {
      args.addAll([
        '-map_metadata',
        '-1',
      ]); // -1 ဆိုရင် metadata တွေအကုန် ဖျက်ချပစ်တာပါ
    }

    // ၆။ Format အလိုက် Bitrate ချိန်ညှိခြင်း
    if (format == FFmpegAudioFormat.mp3 || format == FFmpegAudioFormat.m4a) {
      args.addAll(['-b:a', bitrate.value]);
    } else if (format == FFmpegAudioFormat.ogg) {
      args.addAll(['-q:a', '6']);
    }

    // ၇။ Overwrite Flag (Core ထဲက -y ကို ဖြုတ်ပြီး ဒီဘက်ကနေ overwrite option အလိုက် ထိန်းချုပ်တာ ပိုကောင်းပါတယ်)
    if (overwrite) {
      args.insert(0, '-y');
    } else {
      args.insert(
        0,
        '-n',
      ); // -n ဆိုရင် အဟောင်းရှိပါက skip လုပ်ပြီး exit code ပြန်ပါလိမ့်မယ်
    }

    args.add(fullOutputPath);

    return await _core.executeWithProgress(
      args,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// Duration object အား FFmpeg သဘောပေါက်သည့် "HH:MM:SS.mmm" format ပြောင်းပေးမည့် helper
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(d.inHours);
    final String minutes = twoDigits(d.inMinutes.remainder(60));
    final String seconds = twoDigits(d.inSeconds.remainder(60));
    final String ms = d.inMilliseconds
        .remainder(1000)
        .toString()
        .padLeft(3, '0');
    return "$hours:$minutes:$seconds.$ms";
  }
}
