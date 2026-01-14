import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/notification_controller.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class FCMController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() async {
    super.onInit();
    await _initLocalNotifications();
    await _setupFCM();

    // If user is already logged in, register token
    final String? token = await LocalStorageService.getAccessToken();
    if (token != null) {
      registerFCMToken();
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to appropriate screen
    _handleNotificationNavigation(response.payload);
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

    // Handle background messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _handleNotificationNavigation(message.data['actionUrl']);
      _syncNotificationToController(message);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      // Show local notification when app is in foreground
      _showLocalNotification(message);

      // Sync to notification controller
      _syncNotificationToController(message);
    });

    // Check if app was opened from a terminated state via notification
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationNavigation(initialMessage.data['actionUrl']);
    }
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ijs_vault_channel',
      'IJS Vault Notifications',
      channelDescription: 'Notifications from IJS Vault',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data['actionUrl'],
    );
  }

  /// Sync FCM notification to NotificationController
  void _syncNotificationToController(RemoteMessage message) {
    try {
      // Check if NotificationController is registered
      if (Get.isRegistered<NotificationController>()) {
        final NotificationController controller = Get.find<NotificationController>();

        // Build notification data from FCM message
        final Map<String, dynamic> notificationData = <String, dynamic>{
          ...message.data,
          'title': message.notification?.title ?? message.data['title'] ?? '',
          'body': message.notification?.body ?? message.data['body'] ?? '',
        };

        controller.addNotificationFromFCM(notificationData);
      }
    } catch (e) {
      debugPrint('Error syncing FCM notification: $e');
    }
  }

  /// Handle navigation based on notification action URL
  void _handleNotificationNavigation(String? actionUrl) {
    if (actionUrl == null || actionUrl.isEmpty) return;

    debugPrint('Navigating to: $actionUrl');
    // Parse actionUrl and navigate accordingly
    // Example: /vault/item/item-id -> Navigate to item preview
    // This can be expanded based on your routing needs
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
