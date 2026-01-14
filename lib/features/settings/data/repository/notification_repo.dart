import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class NotificationRepo {
  final ApiService _apiService = ApiService();

  /// Update notification preferences
  Future<ApiResponse> updateNotificationPrefs({
    required bool reminders,
    required bool linkedUsersActivity,
    required bool inviteNotifications,
  }) async {
    return await _apiService.put(
      AppUrls.updateNotificationPrefs,
      data: <String, dynamic>{
        "reminders": reminders,
        "linkedUsersActivity": linkedUsersActivity,
        "inviteNotifications": inviteNotifications,
      },
    );
  }

  /// Get all notifications with pagination
  /// [isRead] - Filter by read status: true, false, or null for all
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20, max: 100)
  Future<ApiResponse> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiService.get(
      'notifications',
      queryParams: <String, dynamic>{
        if (isRead != null) 'isRead': isRead,
        'page': page,
        'limit': limit,
      },
    );
  }

  /// Get a single notification by ID
  Future<ApiResponse> getNotificationById({required String notificationId}) async {
    return await _apiService.get('notifications/$notificationId');
  }

  /// Get unread notification count
  Future<ApiResponse> getUnreadCount() async {
    return await _apiService.get('notifications/unread-count');
  }

  /// Mark a single notification as read
  Future<ApiResponse> markAsRead({required String notificationId}) async {
    return await _apiService.put('notifications/$notificationId/read');
  }

  /// Mark all notifications as read
  Future<ApiResponse> markAllAsRead() async {
    return await _apiService.put('notifications/read-all');
  }

  /// Delete a notification
  Future<ApiResponse> deleteNotification({required String notificationId}) async {
    return await _apiService.delete('notifications/$notificationId');
  }

  /// Delete all notifications
  Future<ApiResponse> deleteAllNotifications() async {
    return await _apiService.delete('notifications');
  }
}
