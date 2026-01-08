import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class NotificationRepo {
  // get ALl Notificatiob
  final ApiService _apiService = ApiService();

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

  // Get All Notifications
  Future<ApiResponse> getNotifications({int page = 1}) async {
    return await _apiService.get(
      AppUrls.getAllNotifications,
      queryParams: <String, dynamic>{'page': page},
    );
  }

  // Mark As Read
  Future<ApiResponse> markAsRead(String id) async {
    return await _apiService.put('${AppUrls.markNotificationAsRead}/$id/read');
  }

  // Mark All As Read
  Future<ApiResponse> markAllAsRead() async {
    return await _apiService.put(AppUrls.markAllNotificationsAsRead);
  }

  // Delete Notification
  Future<ApiResponse> deleteNotification(String id) async {
    return await _apiService.delete('${AppUrls.deleteNotification}/$id');
  }
}
