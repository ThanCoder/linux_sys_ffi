import 'dart:io';

class FFmpegCancelToken {
  Process? _process;
  bool _isCanceled = false;

  bool get isCanceled => _isCanceled;

  /// Internal handle ကို core ဘက်ကနေ ချိတ်ပေးဖို့အတွက်သုံးသည်
  void attach(Process process) {
    _process = process;
    if (_isCanceled) {
      _process?.kill();
      // အကယ်၍ process မတက်ခင်ကတည်းက cancel နှိပ်ထားမိရင် ချက်ချင်းသတ်မယ်
    }
  }

  /// Process အား လမ်းဝက်တွင် ရပ်တန့်ပစ်မည်
  void cancel() {
    if (_isCanceled) return;
    _isCanceled = true;
    _process?.kill(); // Active ဖြစ်နေတဲ့ FFmpeg Process ကို သတ်ပစ်ခြင်း
    _process = null;
  }
}
