import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:linux_sys_ffi/src/sound/sound_bindings.dart';

class LinuxSound {
  late final SoundBindings _b;
  late final Pointer<Pointer<snd_mixer_t>> _mixerPtr;

  /// ### Used Lib -> `libasound.so.2`
  LinuxSound({String libPath = 'libasound.so.2'}) {
    _b = SoundBindings(DynamicLibrary.open(libPath));
  }

  /// Master Mixer Element ကို ရှာပေးမယ့် internal helper function
  Pointer<snd_mixer_elem_t> _getMasterElement(Pointer<snd_mixer_t> mixer) {
    var elem = _b.snd_mixer_first_elem(mixer);
    while (elem != nullptr) {
      if (_b.snd_mixer_selem_is_active(elem) != 0) {
        final Pointer<Char> namePtr = _b.snd_mixer_selem_get_name(elem);
        final String name = namePtr.cast<Utf8>().toDartString();

        // "Master" card ကို ရှာတာဖြစ်ပါတယ်
        if (name == 'Master') {
          return elem;
        }
      }
      elem = _b.snd_mixer_elem_next(elem);
    }
    return nullptr;
  }

  /// Volume ကို သတ်မှတ်မယ် (0 မှ 100 အထိ)
  bool setVolume(int volume) {
    if (volume < 0 || volume > 100) return false;

    // 1. Mixer handle ကို open လုပ်မယ်
    final mixerPtrAlloc = calloc<Pointer<snd_mixer_t>>();
    if (_b.snd_mixer_open(mixerPtrAlloc, 0) < 0) return false;
    final mixer = mixerPtrAlloc.value;

    // 2. Default sound card ("default") နဲ့ attach လုပ်မယ်
    final defaultCard = 'default'.toNativeUtf8();
    if (_b.snd_mixer_attach(mixer, defaultCard.cast()) < 0) {
      _b.snd_mixer_close(mixer);
      return false;
    }

    // 3. Register and Load mixer
    _b.snd_mixer_selem_register(mixer, nullptr, nullptr);
    _b.snd_mixer_load(mixer);

    // 4. Master Element ကို ရှာမယ်
    final elem = _getMasterElement(mixer);
    if (elem == nullptr) {
      _b.snd_mixer_close(mixer);
      return false;
    }

    // 5. Sound Card ရဲ့ Min/Max Range ကို ဖတ်မယ် (ပုံမှန်အားဖြင့် 0-65536 စသဖြင့်ရှိတတ်လို့)
    final minPtr = calloc<Long>();
    final maxPtr = calloc<Long>();
    _b.snd_mixer_selem_get_playback_volume_range(elem, minPtr, maxPtr);

    final int min = minPtr.value;
    final int max = maxPtr.value;

    // 6. 0-100 value ကို Sound card range အလိုက် တွက်ချက်ပြီး Volume မြှင့်/ချမယ်
    final int targetVolume = (((max - min) * volume) / 100).round() + min;
    _b.snd_mixer_selem_set_playback_volume_all(elem, targetVolume);

    // Memory ပြန်ရှင်းပြီး Mixer ပိတ်မယ်
    calloc.free(mixerPtrAlloc);
    calloc.free(minPtr);
    calloc.free(maxPtr);
    calloc.free(defaultCard);
    _b.snd_mixer_close(mixer);

    return true;
  }

  /// လက်ရှိ Master Volume ကို ရာခိုင်နှုန်း (0 မှ 100) ဖြင့် ပြန်ပေးမည်
  /// set ffigen -> `typedef snd_mixer_selem_channel_id = _snd_mixer_selem_channel_id;`
  ///
  int get volume {
    // 1. Mixer handle ကို open လုပ်မယ်
    final mixerPtrAlloc = calloc<Pointer<snd_mixer_t>>();
    if (_b.snd_mixer_open(mixerPtrAlloc, 0) < 0) return -1;
    final mixer = mixerPtrAlloc.value;

    // 2. Default sound card နဲ့ attach လုပ်မယ်
    final defaultCard = 'default'.toNativeUtf8();
    if (_b.snd_mixer_attach(mixer, defaultCard.cast()) < 0) {
      _b.snd_mixer_close(mixer);
      return -1;
    }

    // 3. Register and Load mixer
    _b.snd_mixer_selem_register(mixer, nullptr, nullptr);
    _b.snd_mixer_load(mixer);

    // 4. Master Element ကို ရှာမယ်
    final elem = _getMasterElement(mixer);
    if (elem == nullptr) {
      _b.snd_mixer_close(mixer);
      return -1;
    }

    // 5. Sound Card ရဲ့ Min/Max Range ကို ဖတ်မယ်
    final minPtr = calloc<Long>();
    final maxPtr = calloc<Long>();
    _b.snd_mixer_selem_get_playback_volume_range(elem, minPtr, maxPtr);

    final int min = minPtr.value;
    final int max = maxPtr.value;

    // 6. Hardware ဆီကနေ လက်ရှိ Volume တန်ဖိုးအစစ်ကို ဖတ်မယ်
    final volumePtr = calloc<Long>();
    // SND_MIXER_SCHN_FRONT_LEFT (0) channel ကနေ အခြေခံပြီး ဖတ်တာပါ
    _b.snd_mixer_selem_get_playback_volume(
      elem,
      snd_mixer_selem_channel_id.SND_MIXER_SCHN_FRONT_LEFT,
      volumePtr,
    );
    final int rawVolume = volumePtr.value;

    // 7. ရလာတဲ့ Raw Value ကို 0-100 percentage ပြန်တွက်မယ်
    int percentage = 0;
    if (max - min > 0) {
      percentage = (((rawVolume - min) * 100) / (max - min)).round();
    }

    // Memory ပြန်ရှင်းမယ်
    calloc.free(mixerPtrAlloc);
    calloc.free(minPtr);
    calloc.free(maxPtr);
    calloc.free(volumePtr);
    calloc.free(defaultCard);
    _b.snd_mixer_close(mixer);

    return percentage;
  }
}
