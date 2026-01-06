import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, String>> getDeviceInfo() async {
    String deviceType = '';
    String deviceName = '';
    String deviceModel = '';

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      deviceType = 'ANDROID';
      deviceName = androidInfo.brand;
      deviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      deviceType = 'IOS';
      deviceName = iosInfo.name;
      deviceModel = iosInfo.utsname.machine;
    } else {
      deviceType = 'UNKNOWN';
      deviceName = 'Unknown Device';
      deviceModel = 'Unknown Model';
    }

    return <String, String>{
      'deviceType': deviceType,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
    };
  }
}
