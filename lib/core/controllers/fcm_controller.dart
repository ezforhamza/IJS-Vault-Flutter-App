import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class FCMController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  void onInit() async {
    super.onInit();
    await _setupFCM();

    // If user is already logged in, register token
    final String? token = await LocalStorageService.getAccessToken();
    if (token != null) {
      // registerFCMToken();
    }
  }

  Future<void> _setupFCM() async {
    // Request permissions for iOS
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Handle navigation or other logic here
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
      }
    });
  }

  Future<void> registerFCMToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint('FCM Token is null');
        return;
      }

      String deviceType = '';
      String deviceName = '';

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceType = 'android';
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceType = 'ios';
        deviceName = iosInfo.name;
      }

      final Map<String, String> data = <String, String>{
        "token": token,
        "deviceType": deviceType,
        "deviceName": deviceName,
      };

      debugPrint('Registering FCM Token: $data');

      final ApiResponse response = await _apiService.post(
        AppUrls.registerFCM,
        data: data,
      );

      if (response.success) {
        debugPrint('FCM Token registered successfully');
      } else {
        debugPrint('Failed to register FCM Token: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error registering FCM Token: $e');
    }
  }

  void testNotification() async {
    final ApiService apiService = ApiService();

    final Future<ApiResponse> response = apiService.post(
      'fcm/test',
      data: <String, String>{
        'title': "This is Text Notification",
        "body": "THis is body of notification",
      },
    );
  }

  Future<void> unregisterFCMToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint('FCM Token is null, cannot unregister');
        return;
      }

      final Map<String, String> data = <String, String>{"token": token};

      debugPrint('Unregistering FCM Token: $data');

      final ApiResponse response = await _apiService.post(
        AppUrls.unregisterFCM,
        data: data,
      );

      if (response.success) {
        debugPrint('FCM Token unregistered successfully');
      } else {
        debugPrint('Failed to unregister FCM Token: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error unregistering FCM Token: $e');
    }
  }
}
