import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:intl/intl.dart';

class RemindersRepo {
  final ApiService apiService = ApiService();

  // --------------------------------------------------
  // CREATE REMINDER
  // --------------------------------------------------
  Future<ApiResponse> createReminder({
    required String title,
    String? description,
    required DateTime reminderDateTime,
    required String itemId,
  }) async {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    final Map<String, dynamic> payload = <String, dynamic>{
      'title': title,
      'description': description ?? "",
      'date': dateFormatter.format(reminderDateTime),
      'time': timeFormatter.format(reminderDateTime),
      'itemId': itemId,
    };

    return apiService.post(
      AppUrls.createreminders, // e.g. /reminders
      data: payload,
    );
  }

  Future<ApiResponse> getAllReminders() async {
    return await apiService.get(AppUrls.createreminders);
  }

  // --------------------------------------------------
  // UPDATE STATUS
  // --------------------------------------------------
  Future<ApiResponse> updateReminderStatus(String id, String status) async {
    return await apiService.patch(
      '${AppUrls.createreminders}/$id/status',
      data: <String, dynamic>{'status': status},
    );
  }

  // --------------------------------------------------
  // DELETE REMINDER
  // --------------------------------------------------
  Future<ApiResponse> deleteReminder(String id) async {
    return await apiService.delete('${AppUrls.createreminders}/$id');
  }

  // --------------------------------------------------
  // SNOOZE REMINDER
  // --------------------------------------------------
  Future<ApiResponse> snoozeReminder({
    required String id,
    required DateTime date,
  }) async {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    return await apiService.patch(
      '${AppUrls.createreminders}/$id/snooze',
      data: <String, dynamic>{
        'date': dateFormatter.format(date),
        'time': timeFormatter.format(date),
      },
    );
  }
}
