// device_info.dart
class DeviceInfo {
  final String deviceId;
  final String model;
  final String osVersion;
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final dynamic? manufacture;
  final dynamic? Brand;
  final dynamic? SerialNo;

  DeviceInfo({
    required this.deviceId,
    required this.model,
    required this.osVersion,
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.manufacture,
    required this.Brand,
    required this.SerialNo,
  });

  Map<String, String> toMap() {
    return {
      'deviceId': deviceId,
      'model': model,
      'osVersion': osVersion,
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'manufacture': manufacture,
      'Brand': Brand,
      'SerialNo': SerialNo,
    };
  }
}
