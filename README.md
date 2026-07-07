# linux_sys_ffi

## Linux Platform

### FFmpeg
```dart
final sys = LinuxSysFfi.instance;
final ffmpeg = sys.ffmpeg;

print('isAvailable: ${await ffmpeg.core.isAvailable()}');
print('getSupportedFormats: ${await ffmpeg.core.getSupportedFormats()}');
print('getSupportedCodecs: ${await ffmpeg.core.getSupportedCodecs()}');
print('isFormatSupported: ${await ffmpeg.core.isFormatSupported('mp3')}');


```

### Processes
```dart
final sys = LinuxSysFfi.instance;
for (var pc in sys.process.getRunningProcesses()) {
print('pid: ${pc.pid}');
print('name: ${pc.name}');
}
sys.process.killProcess(pid);
```
### System Info 
```dart
final info = LinuxSysFfi.instance.sysInfo;
print('getMemoryInfo: ${info.getMemoryInfo()}');

final distro = LinuxSysFfi.instance.distro;
print('distroName: ${distro.name}');
print('osRelease: ${distro.osRelease}');

final sys = LinuxSysFfi.instance;
print('getCpuModel: ${sys.sysInfo.getCpuModel()}');
print('getCpuCores: ${sys.sysInfo.getCpuCores()}');

// Launch
LinuxSysFfi.instance.launcher.open(pathOrUrl);

```
### Power
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
    print("SSID: ${wifi.ssid}");
    print("Signal: ${wifi.signalStrength}% (${wifi.bars})");
    print("Security: ${wifi.securityType}");
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


for (var ip in await sys.wifi.getAllNetworkIps()) {
    print('IP: $ip');
}

IP: NetworkIp(interfaceName: lo, type: IPv4, ip: 127.0.0.1, description: Local Host (Loopback))
IP: NetworkIp(interfaceName: lo, type: IPv6, ip: ::1, description: Local Host (Loopback))
IP: NetworkIp(interfaceName: wlp2s0, type: IPv4, ip: 10.125.103.2, description: Wi-Fi / Hotspot)
IP: NetworkIp(interfaceName: wlp2s0, type: IPv6, ip: fe80::c1e8:c882:b5f3:47a, description: Wi-Fi / Hotspot)


```
