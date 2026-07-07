# linux_sys_ffi

## Linux Platform

### 
```dart
```
### System Info 
```dart
final info = LinuxSysFfi.instance.sysInfo;
print('getMemoryInfo: ${info.getMemoryInfo()}');

final distro = LinuxSysFfi.instance.distro;
print('distroName: ${distro.name}');
print('osRelease: ${distro.osRelease}');

// Launch
LinuxSysFfi.instance.launcher.open(pathOrUrl);

```
### Powser
```dart
final power = LinuxSysFfi.instance.power;

await power.suspend();
await power.reboot();
await power.shutdown();

//scheduled shutdown
await power.shutdownWithTimer(Duration(minutes: 10));
print('showPendingShutdown: ${await power.showPendingShutdown()}');
await power.shutdownCancel();

```


### Sound
```dart
final sound = LinuxSound();

print('volume: ${sound.volume}');

bool success = sound.setVolume(50);
if (success) {
    print("အသံပမာဏကို 50% သို့ ပြောင်းလဲပြီးပါပြီ။");
}
```

### Brightness
```dart
final bn = LinuxSysFfi.instance.brightness;
print('brightness - exists: ${bn.exists}');
print('getCurrentBrightness: ${bn.getCurrentBrightness()}');
print('getMaxBrightness: ${bn.getMaxBrightness()}');
bn.setBrightness(4000);
bn.setBrightnessWithPrompt(4000);

final command = bn.getBrightnessCommand(4000);
if (command != null) {
    LinuxSudoPrompt.runWithGuiSudo(command);
}
```

### Battery
```dart
final bt = LinuxSysFfi.instance.battery;
print('capacity: ${bt.capacity}');
print('status: ${bt.status}');
print('capacityLevel: ${bt.capacityLevel}');
print('energy_full_design: ${bt.energy_full_design}');
print('energy_full: ${bt.energy_full}');
print('energy_now: ${bt.energy_now}');
print('model_name: ${bt.model_name}');
print('power_now: ${bt.power_now}');
print('uevent: ${bt.uevent}');
```


### Wifi
```dart
// LinuxSysFfi.instance.wifi

final wf = LinuxWifi(); 
print('scanWifi: ${wf.scanWifi()}'); //not working for now!.

print('scanWifiNmCli: ${await wf.scanWifiNmCli()}');
//scanWifiNmCli: [{ssid: Redmi Note 14 5G, signal: 97}, {ssid: , signal: 37}, {ssid: U Win Ko, signal: 20}]

final List<Map<String, dynamic>> availableWifi =
await wf.getWifiListNmCli();

for (var wifi in availableWifi) {
    print("--------------------------------");
    print("SSID: ${wifi['ssid']}");
    print("Signal: ${wifi['signal_strength']}% (${wifi['bars']})");
    print("Security: ${wifi['security_type']}");
}

WiFi list များကို ရှာဖွေနေပါသည်...
--------------------------------
SSID: Redmi Note 14 5G
Signal: 100% (▂▄▆█)
Security: WPA2
--------------------------------
SSID: U Win Ko
Signal: 34% (▂▄__)
Security: WPA2
--------------------------------
SSID: Daw San San Htay
Signal: 20% (▂___)
Security: WPA1 WPA2
```
