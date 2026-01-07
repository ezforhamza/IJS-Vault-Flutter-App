import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service to show upload progress in system notifications
/// This helps keep uploads running when app is in background
class UploadNotificationService {
  static final UploadNotificationService _instance = UploadNotificationService._internal();
  factory UploadNotificationService() => _instance;
  UploadNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _uploadNotificationId = 1001;
  static const String _channelId = 'upload_progress';
  static const String _channelName = 'Upload Progress';
  static const String _channelDescription = 'Shows file upload progress';

  /// Initialize the notification service and request permissions
  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Request notification permission on Android 13+
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      // Request permission (required for Android 13+)
      await androidPlugin?.requestNotificationsPermission();
      
      // Create notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high, // High importance to ensure visibility
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );

      await androidPlugin?.createNotificationChannel(channel);
    }

    _initialized = true;
    debugPrint('UploadNotificationService initialized');
  }

  /// Show or update upload progress notification
  Future<void> showUploadProgress({
    required String filename,
    required int progress,
    required String progressText,
    required int activeUploads,
  }) async {
    if (!_initialized) await initialize();

    final String title = activeUploads > 1 
        ? 'Uploading $activeUploads files' 
        : 'Uploading $filename';
    
    final String body = activeUploads > 1
        ? '$progressText • $progress%'
        : '$progressText • $progress%';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Makes it persistent (can't be swiped away)
      autoCancel: false,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      playSound: false,
      enableVibration: false,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.progress,
      visibility: NotificationVisibility.public,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _uploadNotificationId,
      title,
      body,
      details,
    );
  }

  /// Show upload complete notification
  Future<void> showUploadComplete({
    required int totalFiles,
  }) async {
    if (!_initialized) await initialize();

    final String title = totalFiles > 1 
        ? '$totalFiles files uploaded' 
        : 'Upload complete';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
      playSound: false,
      enableVibration: false,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _uploadNotificationId,
      title,
      'All files have been uploaded successfully',
      details,
    );

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      cancelUploadNotification();
    });
  }

  /// Cancel the upload notification
  Future<void> cancelUploadNotification() async {
    await _notifications.cancel(_uploadNotificationId);
  }
}
