import 'dart:convert';
import 'dart:io';

import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_cancel_token.dart';

/// FFmpeg စက်ထဲတွင် မရှိပါက ပေါ်လာမည့် Custom Exception
class FFmpegNotInstalledException implements Exception {
  final String message;
  final String installationCommand;

  FFmpegNotInstalledException([
    this.message =
        "စက်ထဲတွင် FFmpeg ကို ရှာမတွေ့ပါ။ အောက်ပါ Command ဖြင့် အပြည့်အစုံ Install လုပ်ပေးပါ။",
    this.installationCommand =
        "sudo apt update && sudo apt install -y ffmpeg libavcodec-extra",
  ]);

  @override
  String toString() =>
      "FFmpegNotInstalledException: $message\n👉 Run this command: $installationCommand";
}

class FFmpegCore {
  /// FFmpeg စက်ထဲမှာ ရှိ/မရှိ စစ်ဆေးသည်
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Command arguments များကို လက်ခံ၍ FFmpeg အား Run ပေးသည်
  Future<bool> execute(List<String> arguments) async {
    if (!await isAvailable()) {
      // ဒီနေရာမှာ standard error အစား ကိုယ်တိုင်ဆောက်ထားတဲ့ install လမ်းညွှန်ပါတဲ့ Exception ကို ပစ်လိုက်တာပါ
      throw FFmpegNotInstalledException();
    }
    try {
      // အမြဲတမ်း overwrite လုပ်ရန် -y ကို ရှေ့ဆုံးက ထည့်ပေးထားမည်
      final finalArgs = ['-y', ...arguments];
      final result = await Process.run('ffmpeg', finalArgs);
      return result.exitCode == 0;
    } catch (e) {
      print("FFmpeg Execution Error: $e");
      return false;
    }
  }

  /// ဗီဒီယိုတစ်ခုချင်းစီရဲ့ ကြာချိန်စုစုပေါင်းကို စက္ကန့်အဖြစ် ပြန်ပေးမည့် Helper
  Future<double> getDuration(String inputPath) async {
    if (!await isAvailable()) throw FFmpegNotInstalledException();

    // ffprobe သည် ffmpeg နဲ့အတူ တစ်ခါတည်းပါပြီးသား metadata ဖတ်တဲ့ tool ဖြစ်ပါတယ်
    final result = await Process.run('ffprobe', [
      '-v',
      'error',
      '-show_entries',
      'format=duration',
      '-of',
      'default=noprint_wrappers=1:nokey=1',
      inputPath,
    ]);

    if (result.exitCode == 0) {
      return double.tryParse(result.stdout.toString().trim()) ?? 0.0;
    }
    return 0.0;
  }

  /// Real-time progress callback ပါဝင်သော execute method
  Future<bool> executeWithProgress(
    List<String> arguments, {
    FFmpegCancelToken? cancelToken,
    required void Function(double percentage) onProgress,
  }) async {
    if (!await isAvailable()) throw FFmpegNotInstalledException();

    final finalArgs = ['-y', ...arguments];

    // input path ကို argument ထဲကနေ ပြန်ရှာပြီး total duration ယူတာပါ
    // (ပုံမှန်အားဖြင့် -i ရဲ့ နောက်ကကောင်သည် input path ဖြစ်ပါတယ်)
    final int iIdx = finalArgs.indexOf('-i');
    final double totalDuration = iIdx != -1 && iIdx + 1 < finalArgs.length
        ? await getDuration(finalArgs[iIdx + 1])
        : 0.0;

    try {
      // Process ကို Background မှာ စတင်မောင်းနှင်မယ်
      final process = await Process.start('ffmpeg', finalArgs);

      // Cancel Token ရှိရင် ဒီ process ကို လှမ်းချိတ်ပေးထားလိုက်မယ်
      if (cancelToken != null) {
        cancelToken.attach(process);
        if (cancelToken.isCanceled) return false;
      }

      // FFmpeg က progress output တွေကို standard error (stderr) ထဲမှာပဲ ထုတ်ပေးလေ့ရှိပါတယ်
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String line) {
            // Output ထဲက "time=00:02:15.20" စတဲ့ စာသားကို ရှာပြီး parse လုပ်မယ်
            if (line.contains('time=') && totalDuration > 0) {
              final match = RegExp(
                r'time=(\d+):(\d+):(\d+\.\d+)',
              ).firstMatch(line);
              if (match != null) {
                final int hours = int.parse(match.group(1)!);
                final int minutes = int.parse(match.group(2)!);
                final double seconds = double.parse(match.group(3)!);

                // စုစုပေါင်း လက်ရှိစက္ကန့်ကို တွက်ချက်ခြင်း
                final double currentSeconds =
                    (hours * 3600) + (minutes * 60) + seconds;

                // Percentage တွက်ချက်ပြီး Callback မှတဆင့် UI ဆီ လှမ်းပို့ပေးမယ်
                double percentage = (currentSeconds / totalDuration) * 100;
                if (percentage > 100) percentage = 100;
                // Cancel ဖြစ်သွားခဲ့ရင် progress ထပ်မပို့တော့ဘူး
                if (cancelToken?.isCanceled == true) return;
                onProgress(
                  double.parse(percentage.toStringAsFixed(1)),
                ); // ဒဿမ ၁ နေရာပဲယူမယ်
              }
            }
          });

      final exitCode = await process.exitCode;
      // Cancel ကြောင့် သေသွားတာဆိုရင် false ပြန်မယ်
      if (cancelToken?.isCanceled == true) return false;

      if (exitCode == 0) onProgress(100.0); // ပြီးသွားရင် ၁၀၀ ပေးလိုက်မယ်
      return exitCode == 0;
    } catch (e) {
      print("FFmpeg Stream Error: $e");
      return false;
    }
  }

  /// ၁။ FFmpeg က Support လုပ်သမျှ Formats (Muxers/Demuxers) အကုန်ယူမည်
  /// ကွန်ပျူတာထဲက format က ဖတ်ရုံပဲရလား (Demuxing)၊ ရေးလို့ရောရလား (Muxing) ပါ စစ်ပေးနိုင်ပါတယ်
  Future<List<Map<String, dynamic>>> getSupportedFormats() async {
    final List<Map<String, dynamic>> formats = [];
    if (!await isAvailable()) return formats;

    final result = await Process.run('ffmpeg', ['-formats']);
    if (result.exitCode != 0) return formats;

    final lines = (result.stdout as String).split('\n');
    bool startParsing = false;

    for (var line in lines) {
      if (line.startsWith(' --')) {
        startParsing = true; // Header separation line ကိုကျော်ပြီးမှ ဖတ်မယ်
        continue;
      }
      if (!startParsing || line.trim().isEmpty) continue;

      // FFmpeg standard output format က " D E mp3             MP3 (MPEG audio layer 3)" လိုမျိုးလာတာပါ
      if (line.length > 4) {
        final String indicator = line.substring(0, 4);
        final bool canDemux = indicator.contains('D');
        final bool canMux = indicator.contains('E');

        final String rest = line.substring(4).trim();
        final List<String> parts = rest.split(RegExp(r'\s+'));

        if (parts.isNotEmpty) {
          final String formatName = parts[0];
          final String description = parts.sublist(1).join(' ');

          formats.add({
            'name': formatName,
            'description': description,
            'can_encode_mux': canMux,
            'can_decode_demux': canDemux,
          });
        }
      }
    }
    return formats;
  }

  /// ၂။ FFmpeg က Support လုပ်သမျှ Audio/Video Codecs များစာရင်းကို ယူမည်
  Future<List<Map<String, dynamic>>> getSupportedCodecs() async {
    final List<Map<String, dynamic>> codecs = [];
    if (!await isAvailable()) return codecs;

    final result = await Process.run('ffmpeg', ['-codecs']);
    if (result.exitCode != 0) return codecs;

    final lines = (result.stdout as String).split('\n');
    bool startParsing = false;

    for (var line in lines) {
      if (line.startsWith(' -------')) {
        startParsing = true;
        continue;
      }
      if (!startParsing || line.trim().isEmpty) continue;

      if (line.length > 7) {
        final String flags = line.substring(0, 7);
        // Codec Types: V = Video, A = Audio, S = Subtitle
        String type = 'Unknown';
        if (flags.contains('V')) type = 'Video';
        if (flags.contains('A')) type = 'Audio';
        if (flags.contains('S')) type = 'Subtitle';

        final bool canDecode = flags[1] == 'D';
        final bool canEncode = flags[2] == 'E';

        final String rest = line.substring(7).trim();
        final List<String> parts = rest.split(RegExp(r'\s+'));

        if (parts.isNotEmpty) {
          final String codecName = parts[0];
          final String description = parts.sublist(1).join(' ');

          codecs.add({
            'name': codecName,
            'type': type,
            'description': description,
            'can_encode': canEncode,
            'can_decode': canDecode,
          });
        }
      }
    }
    return codecs;
  }

  /// ၃။ Specific Format တစ်ခု (e.g., 'mp3', 'mp4') ကို လက်ရှိစက်က support ဖြစ်မဖြစ် စစ်ဆေးရန် helper
  Future<bool> isFormatSupported(
    String formatName, {
    bool requireEncoding = false,
  }) async {
    final formats = await getSupportedFormats();
    for (var f in formats) {
      if (f['name'].toString().toLowerCase() == formatName.toLowerCase()) {
        return requireEncoding ? f['can_encode_mux'] as bool : true;
      }
    }
    return false;
  }
}
