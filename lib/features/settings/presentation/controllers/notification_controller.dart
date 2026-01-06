import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/settings/data/models/notification_model.dart';
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
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  Rxn<PaginationModel> pagination = Rxn<PaginationModel>();
  RxBool isLoading = false.obs;
  RxBool isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentPrefs();
    fetchNotifications(isRefresh: true);
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

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    // Avoid simultaneous duplicate calls
    if (isLoading.value || isFetchingMore.value) return;

    // Guard: Don't fetch more if no next page
    if (!isRefresh &&
        pagination.value != null &&
        !pagination.value!.hasNextPage) {
      return;
    }

    if (isRefresh || notifications.isEmpty) {
      isLoading.value = true;
    } else {
      isFetchingMore.value = true;
    }

    try {
      final ApiResponse response = await _repository.getNotifications(
        page: isRefresh ? 1 : (pagination.value?.page ?? 0) + 1,
      );

      if (response.success) {
        // final NotificationResponseModel data =
        // NotificationResponseModel.fromJson(response.data);
        // final List<NotificationModel> noti =
        //     (response.data['notifications'] as List)
        //         .map((e) => NotificationModel.fromJson(e))
        //         .toList();
        final NotificationsData data = NotificationsData.fromJson(
          response.data,
        );

        if (isRefresh) {
          notifications.value = data.notifications;
        } else {
          notifications.addAll(data.notifications);
        }
        // pagination.value = noti.pagination;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }
}
