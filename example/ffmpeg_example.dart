import 'package:linux_sys_ffi/linux_sys_ffi.dart';

void main() async {
  final sys = LinuxSysFfi.instance;
  final ffmpeg = sys.ffmpeg;

  print('isAvailable: ${await ffmpeg.core.isAvailable()}');
  print('getSupportedFormats: ${await ffmpeg.core.getSupportedFormats()}');
  print('getSupportedCodecs: ${await ffmpeg.core.getSupportedCodecs()}');
  print('isFormatSupported: ${await ffmpeg.core.isFormatSupported('mp3')}');

  // 1. Token တစ်ခု ဆောက်မယ်
  final cancelToken = FFmpegCancelToken();

  // 2. ၅ စက္ကန့်ပြည့်ရင် လမ်းဝက်ကနေ လှမ်းဖျက်ခိုင်းမယ့် စမ်းသပ်ချက်
  Future.delayed(const Duration(seconds: 5), () {
    print("🛑 User က Cancel ခလုတ်ကို နှိပ်လိုက်ပါပြီ။");
    cancelToken.cancel();
  });

  await ffmpeg.audioExtractor.extractWithProgress(
    videoPath: '/home/thancoder/Videos/A  Were wolf Boy (2026).mp4',
    outputDirectory: '/home/thancoder/Videos',
    fileName: 'A  Were wolf Boy (2026)',
    format: .m4a,
    cancelToken: cancelToken,
    endTime: Duration(minutes: 1, seconds: 30),
    onProgress: (progress) {
      print('progress: $progress');
    },
  );

  final songPath =
      '/home/thancoder/Music/Alan Walker Style - Again ( New Song 2024 ).opus';

  // ၁။ Metadata Tags များ ဆွဲထုတ်ခြင်း
  print("Metadata ဖတ်နေသည်...");
  final tags = await sys.ffmpeg.metadataExtractor.getTags(songPath);

  print("Title: ${tags['title'] ?? 'Unknown'}");
  print("Artist: ${tags['artist'] ?? 'Unknown'}");
  print("Album: ${tags['album'] ?? 'Unknown'}");
  print("Year: ${tags['date'] ?? 'Unknown'}");

  // ၂။ Album Art / Thumbnail ပုံ ဆွဲထုတ်ခြင်း
  print("Thumbnail ပုံထုတ်နေသည်...");
  final bool hasThumbnail = await sys.ffmpeg.metadataExtractor
      .extractAudioThumbnail(
        inputPath: songPath,
        outputPath: '/home/user/Music/song_cover.jpg',
      );

  if (hasThumbnail) {
    print(
      "Thumbnail ထုတ်ယူမှု အောင်မြင်ပါသည်။ (/home/user/Music/song_cover.jpg)",
    );
  } else {
    print("ဤဖိုင်တွင် Embedded Album Art (သို့မဟုတ်) Video Frame မပါဝင်ပါ။");
  }
  // Video Thumbnail
  final vpath = '/home/thancoder/Videos/Supernatural S1/20.mp4';
  final dur = await ffmpeg.core.getDuration(vpath);
  print('dur: $dur');
  await ffmpeg.metadataExtractor.extractVideoThumbnail(
    inputPath: vpath,
    outputPath: 'v_thumb.jpg',
    time: Duration(seconds: 30),
  );
}
