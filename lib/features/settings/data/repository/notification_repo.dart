import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class NotificationRepo {
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
}
