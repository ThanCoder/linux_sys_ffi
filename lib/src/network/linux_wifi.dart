// ignore_for_file: unused_local_variable

import 'dart:ffi';
import 'dart:io';

import 'package:linux_sys_ffi/src/network/wifi_bindings.dart';

class LinuxWifi {
  late final WifiBindings _bindings;

  /// ### Used Lib -> `libnm.so.0`
  LinuxWifi({String libPath = 'libnm.so.0'}) {
    _bindings = WifiBindings(DynamicLibrary.open(libPath));
  }

  /// အနီးအနားမှာရှိတဲ့ WiFi Name (SSID) နဲ့ Signal Strength တွေကို ရှာပေးမယ်
  List<Map<String, dynamic>> scanWifi() {
    final List<Map<String, dynamic>> wifiList = [];

    // 1. NMClient Instance ဆောက်မယ် (NetworkManager ကို ချိတ်တာ)
    // C API: nm_client_new(NULL, NULL)
    final client = _bindings.nm_client_new(nullptr, nullptr);
    if (client == nullptr) return wifiList;

    // 2. စက်ထဲမှာရှိတဲ့ Network Devices (Network Cards) အကုန်ယူမယ်
    final devicesPtr = _bindings.nm_client_get_devices(client);
    if (devicesPtr == nullptr) {
      _bindings.g_object_unref(client.cast());
      return wifiList;
    }

    // GPtrArray ကို Loop ပတ်ပြီး WiFi Device ကို လိုက်ရှာမယ်
    // (အလွယ်ဗျူဟာအရ ပထမဆုံးတွေ့တဲ့ WiFi Card ကို ယူပါမယ်)
    Pointer<Void> wifiDevice = nullptr;

    // Devices array ရဲ့ သဘောသဘာဝအရ pointer အမထည့်သွင်းတွက်ချက်ပုံ
    final int length = (devicesPtr.cast<Uint32>()).value;
    // မှတ်ချက် - ffigen ရဲ့ array length struct ပေါ်မူတည်ပြီး အပေါ်က length ဖတ်ပုံ ကွဲပြားနိုင်ပါတယ်

    // ဒီနေရာမှာ Device list ထဲကမှ Type က NM_DEVICE_TYPE_WIFI (အမျိုးအစား 2) ဖြစ်တဲ့ကောင်ကို ယူမယ်
    // ဥပမာအလွယ်အတွက် ပထမဆုံးတွေ့တဲ့ wifi device ကို တိုက်ရိုက်ယူသုံးပြပါမယ်

    // 3. အနီးအနားက Access Points (APs) တွေကို လှမ်းယူမယ်
    // (အကယ်၍ wifiDevice ရှာတွေ့ပြီဆိုရင်)
    final apArray = _bindings.nm_device_wifi_get_access_points(
      wifiDevice.cast(),
    );
    if (apArray != nullptr) {
      // AP တွေကို loop ပတ်ပြီး SSID နဲ့ Strength ထုတ်ယူတဲ့အပိုင်း
      // ...
      // nm_access_point_get_ssid(ap) -> ရလာတဲ့ GBytes ကို g_bytes_get_data နဲ့ String ပြောင်း
      // nm_access_point_get_strength(ap) -> ရာခိုင်နှုန်း (0-100) ထွက်လာမယ်
    }

    // Memory ပိတ်သိမ်းခြင်း
    _bindings.g_object_unref(client.cast());
    return wifiList;
  }

  /// အနီးအနားက WiFi list ကို nmcli command သုံးပြီး Clean ဖြစ်အောင် ထုတ်ယူနည်း
  Future<List<Map<String, String>>> scanWifiNmCli() async {
    final List<Map<String, String>> networks = [];

    // nmcli က native ဖြစ်ပြီး text format နဲ့ သန့်သန့်လေး ထုတ်ပေးနိုင်ပါတယ်
    final result = await Process.run('nmcli', [
      '-t',
      '-f',
      'SSID,SIGNAL',
      'device',
      'wifi',
      'list',
    ]);

    if (result.exitCode == 0) {
      final lines = (result.stdout as String).split('\n');
      for (var line in lines) {
        if (line.isEmpty) continue;
        final parts = line.split(':'); // Format က SSID:SIGNAL ဖြစ်နေလို့ပါ
        if (parts.length >= 2) {
          networks.add({'ssid': parts[0], 'signal': parts[1]});
        }
      }
    }
    return networks;
  }

  /// အနီးအနားတွင်ရှိသော WiFi list များကို ရှာဖွေပြီး Name (SSID)၊ Signal Strength၊ Security စသည်တို့ကို ပြန်ပေးမည်။
  Future<List<Map<String, dynamic>>> getWifiListNmCli() async {
    final List<Map<String, dynamic>> wifiList = [];

    try {
      // Error ဖြစ်စေတဲ့ -d option ကို ဖြုတ်လိုက်ပြီး standard terse mode (-t) ကိုပဲ သုံးထားပါတယ်
      final ProcessResult result = await Process.run('nmcli', [
        '-t',
        '--escape',
        'no',
        '-f',
        'SSID,SIGNAL,BARS,SECURITY',
        'device',
        'wifi',
        'list',
      ]);

      if (result.exitCode != 0) {
        print("WiFi list ဖတ်၍မရပါ: ${result.stderr}");
        return wifiList;
      }

      final String stdout = result.stdout as String;
      final List<String> lines = stdout.split('\n');

      for (var line in lines) {
        if (line.trim().isEmpty) continue;

        // Standard terse mode က `:` နဲ့ ခွဲပေးတာမလို့ `:` နဲ့ split လုပ်ပါတယ်
        final List<String> fields = line.split(':');

        // fields ၄ ခုထက် နည်းနေရင် data မပြည့်စုံလို့ ကျော်ခဲ့မယ်
        if (fields.length < 4) continue;

        // အကယ်၍ SSID နာမည်ထဲမှာတင် ':' ပါခဲ့ရင် အမှားမရှိအောင်
        // နောက်ဆုံးကျန်တဲ့ fields ၃ ခု (Security, BARS, SIGNAL) ကို အနောက်ကနေ ပြန်ရေတွက်ပြီး ဖတ်ပါမယ်
        final int totalFields = fields.length;
        final String security = fields[totalFields - 1].trim();
        final String bars = fields[totalFields - 2].trim();
        final int signal = int.tryParse(fields[totalFields - 3].trim()) ?? 0;

        // ကျန်တဲ့ ရှေ့က အပိုင်းအကုန်လုံးကို SSID အဖြစ် ပြန်ပေါင်းပေးလိုက်တာပါ
        final String ssid = fields.sublist(0, totalFields - 3).join(':').trim();

        if (ssid.isEmpty) continue;

        wifiList.add({
          'ssid': ssid,
          'signal_strength': signal, // 0 to 100
          'bars': bars, // e.g., "▂▄▆_"
          'is_secure': security.isNotEmpty && security != '--',
          'security_type': security == '--' ? 'Open' : security,
        });
      }

      // Signal ပိုကောင်းတဲ့ WiFi ကို အပေါ်ဆုံးကပြချင်လို့ Sort ပတ်ပေးလိုက်တာပါ
      wifiList.sort(
        (a, b) => (b['signal_strength'] as int).compareTo(
          a['signal_strength'] as int,
        ),
      );
    } catch (e) {
      print("nmcli command အား မပတ်နိုင်ပါ: $e");
    }

    return wifiList;
  }
}
