enum FFmpegAudioFormat {
  mp3(extension: 'mp3', codec: 'libmp3lame'),
  m4a(extension: 'm4a', codec: 'aac'),
  wav(extension: 'wav', codec: 'pcm_s16le'),
  flac(extension: 'flac', codec: 'flac'),
  ogg(extension: 'ogg', codec: 'libvorbis');

  final String extension;
  final String codec;

  const FFmpegAudioFormat({
    required this.extension,
    required this.codec,
  });
}