enum FFmpegAudioBitrate {
  /// 96kbps - Low Quality (အသံဖိုင် သက်သက် သို့မဟုတ် ပေါ့ပေါ့ပါးပါး နားထောင်ရန်၊ ဖိုင်ဆိုဒ် အသေးဆုံး)
  low(value: '96k'),

  /// 128kbps - Standard Quality (အင်တာနက်ပေါ်က standard streaming အဆင့်)
  standard(value: '128k'),

  /// 192kbps - Medium Quality (နားကြပ်ကောင်းကောင်းနဲ့ နားထောင်ရင် သိသာတဲ့ အဆင့်)
  medium(value: '192k'),

  /// 256kbps - High Quality (Apple Music သို့မဟုတ် premium အဆင့်)
  high(value: '256k'),

  /// 320kbps - Ultra/Studio Quality (MP3 မှာ အကောင်းဆုံး အဆင့်၊ မူရင်းအသံအတိုင်း အကြည်ဆုံး)
  ultra(value: '320k');

  final String value;
  const FFmpegAudioBitrate({required this.value});
}
