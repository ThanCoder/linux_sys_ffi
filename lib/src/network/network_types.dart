// ignore_for_file: public_member_api_docs, sort_constructors_first
class NetworkIp {
  final String interfaceName;
  final String type;
  final String ip;
  final String description;
  const NetworkIp({
    required this.interfaceName,
    required this.type,
    required this.ip,
    required this.description,
  });

  @override
  String toString() {
    return 'NetworkIp(interfaceName: $interfaceName, type: $type, ip: $ip, description: $description)';
  }
}

class WifiNmcliItem {
  final String ssid;
  final int signalStrength;
  final String bars;
  final bool isSecure;
  final String securityType;
  const WifiNmcliItem({
    required this.ssid,
    required this.signalStrength,
    required this.bars,
    required this.isSecure,
    required this.securityType,
  });

  @override
  String toString() {
    return 'WifiNmcliItem(ssid: $ssid, signalStrength: $signalStrength, bars: $bars, isSecure: $isSecure, securityType: $securityType)';
  }
}
