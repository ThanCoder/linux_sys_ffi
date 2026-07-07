import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_audio_extractor.dart';
import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_core.dart';
import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_metadata_extractor.dart';
import 'package:linux_sys_ffi/src/ffmpeg/ffmpeg_video_trimmer.dart';

class LinuxFFmpeg {
  late final FFmpegCore _core;
  late final FFmpegAudioExtractor _extractor;
  late final FFmpegVideoTrimmer _trimmer;
  late final FFmpegMetadataExtractor _metadataExtractor;

  LinuxFFmpeg() {
    _core = FFmpegCore();
    _extractor = FFmpegAudioExtractor(_core);
    _trimmer = FFmpegVideoTrimmer(_core);
    _metadataExtractor = FFmpegMetadataExtractor(_core);
  }

  // sub-classes များကို getter အနေဖြင့် ထုတ်ပေးထားမည်
  FFmpegAudioExtractor get audioExtractor => _extractor;
  FFmpegVideoTrimmer get videoTrimmer => _trimmer;
  FFmpegCore get core => _core;
  FFmpegMetadataExtractor get metadataExtractor => _metadataExtractor;
}
