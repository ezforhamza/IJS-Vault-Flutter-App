import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/settings/data/repository/notification_repo.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class NotificationController extends GetxController {
  final NotificationRepo _repository = NotificationRepo();
  final ProfileController _profileController = Get.find<ProfileController>();

  final RxBool reminders = false.obs;
  final RxBool linkedUsersActivity = false.obs;
  final RxBool inviteNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentPrefs();
  }

  void _loadCurrentPrefs() {
    final NotificationPreferencesModel? prefs =
        _profileController.currentUser.value?.notificationPreferences;
    if (prefs != null) {
      reminders.value = prefs.reminders;
      linkedUsersActivity.value = prefs.linkedUsersActivity;
      inviteNotifications.value = prefs.inviteNotifications;
    }
  }

  Future<void> updatePreferences() async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await _repository.updateNotificationPrefs(
        reminders: reminders.value,
        linkedUsersActivity: linkedUsersActivity.value,
        inviteNotifications: inviteNotifications.value,
      );

      if (response.success && response.data != null) {
        final NotificationPreferencesModel updatedPrefs =
            NotificationPreferencesModel.fromJson(response.data['preferences']);

        final UserModel? currentUser = _profileController.currentUser.value;
        if (currentUser != null) {
          final UserModel updatedUser = currentUser.copyWith(
            notificationPreferences: updatedPrefs,
          );
          await _profileController.updateUser(updatedUser);
        }

        AppToasts.showSuccessToast(message: 'Notification preferences updated');
      } else {
        AppToasts.showErrorToast(message: response.message);
        // Revert UI to local state if failed
        _loadCurrentPrefs();
      }
    } catch (e) {
      debugPrint('Update notification prefs error: $e');
      AppToasts.showErrorToast(message: 'Failed to update preferences');
      _loadCurrentPrefs();
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  void toggleReminders(bool value) {
    reminders.value = value;
    updatePreferences();
  }

  void toggleLinkedUsersActivity(bool value) {
    linkedUsersActivity.value = value;
    updatePreferences();
  }

  void toggleInviteNotifications(bool value) {
    inviteNotifications.value = value;
    updatePreferences();
  }
}
