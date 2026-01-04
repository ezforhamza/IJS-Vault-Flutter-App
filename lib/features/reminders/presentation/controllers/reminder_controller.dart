import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/data/repository/reminders_repo.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ReminderController extends GetxController {
  final RemindersRepo remindersRepo = RemindersRepo();

  // --------------------------------------------------
  // STATE
  // --------------------------------------------------
  final RxBool isFetchingReminders = false.obs;
  final RxList<ReminderItemModel> reminders = <ReminderItemModel>[].obs;

  // --------------------------------------------------
  // CREATE REMINDER
  // --------------------------------------------------
  Future<void> createReminder({
    required String title,
    String? description,
    required DateTime reminderDateTime,
    required String itemId,
  }) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await remindersRepo.createReminder(
        title: title,
        reminderDateTime: reminderDateTime,
        itemId: itemId,
        description: description,
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);

        /// Refresh list after creation
        await getAllReminders();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Create Reminder Error: $e');
      AppToasts.showErrorToast(message: 'Something went wrong');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // --------------------------------------------------
  // GET ALL REMINDERS
  // --------------------------------------------------
  Future<void> getAllReminders() async {
    isFetchingReminders.value = true;

    try {
      final ApiResponse response = await remindersRepo.getAllReminders();

      if (response.success) {
        final Map<String, dynamic> data = response.data ?? <String, dynamic>{};

        final List<dynamic> remindersJson = data['reminders'] ?? <dynamic>[];

        reminders.assignAll(
          remindersJson
              .map((e) => ReminderItemModel.fromJson(e ?? <String, dynamic>{}))
              .toList(),
        );
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Get Reminders Error: $e');
      AppToasts.showErrorToast(message: 'Failed to load reminders');
    } finally {
      isFetchingReminders.value = false;
    }
  }

  // --------------------------------------------------
  // HELPER: GET REMINDERS BY DATE
  // --------------------------------------------------
  List<ReminderItemModel> getRemindersByDate(DateTime date) {
    return reminders.where((ReminderItemModel r) {
      // Check if reminder date matches the selected date
      try {
        // Assuming date format is yyyy-MM-dd
        // Or we can parse r.date
        if (r.date.isEmpty) return false;
        final DateTime rDate = DateTime.parse(r.date);
        return rDate.year == date.year &&
            rDate.month == date.month &&
            rDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // --------------------------------------------------
  // MARK AS COMPLETE
  // --------------------------------------------------
  Future<void> markAsComplete(String id) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await remindersRepo.updateReminderStatus(
        id,
        'completed',
      );
      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        await getAllReminders();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Mark complete error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // --------------------------------------------------
  // MARK AS PENDING
  // --------------------------------------------------
  Future<void> markAsPending(String id) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await remindersRepo.updateReminderStatus(
        id,
        'pending',
      );
      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        await getAllReminders();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Mark pending error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // --------------------------------------------------
  // SNOOZE REMINDER
  // --------------------------------------------------
  Future<void> snoozeReminder(String id, DateTime newDate) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await remindersRepo.snoozeReminder(
        id: id,
        date: newDate,
      );
      if (response.success) {
        AppToasts.showSuccessToast(message: 'Reminder snoozed');
        await getAllReminders();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Snooze error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // --------------------------------------------------
  // DELETE REMINDER
  // --------------------------------------------------
  Future<void> deleteReminder(String id) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await remindersRepo.deleteReminder(id);
      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        await getAllReminders();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Delete reminder error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }
}
