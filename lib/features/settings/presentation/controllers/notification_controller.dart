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

  // Notification preferences
  final RxBool reminders = false.obs;
  final RxBool linkedUsersActivity = false.obs;
  final RxBool inviteNotifications = false.obs;

  // Notifications list
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  Rxn<NotificationPaginationModel> pagination = Rxn<NotificationPaginationModel>();

  // Unread count
  RxInt unreadCount = 0.obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentPrefs();
    fetchNotifications(isRefresh: true);
    fetchUnreadCount();
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

  /// Fetch notifications with pagination
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isLoading.value || isFetchingMore.value) return;

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
        final NotificationsData data = NotificationsData.fromJson(response.data);

        if (isRefresh) {
          notifications.value = data.notifications;
        } else {
          notifications.addAll(data.notifications);
        }
        pagination.value = data.pagination;
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

  /// Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    try {
      final ApiResponse response = await _repository.getUnreadCount();
      if (response.success) {
        unreadCount.value = response.data['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Fetch unread count error: $e');
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final ApiResponse response = await _repository.markAsRead(
        notificationId: notificationId,
      );

      if (response.success) {
        // Update local state
        final int index = notifications.indexWhere((NotificationModel n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
        }
        // Decrement unread count
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final ApiResponse response = await _repository.markAllAsRead();

      if (response.success) {
        // Update local state - mark all as read
        notifications.value = notifications
            .map((NotificationModel n) => n.copyWith(isRead: true))
            .toList();
        unreadCount.value = 0;
        AppToasts.showSuccessToast(message: 'All notifications marked as read');
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Mark all as read error: $e');
      AppToasts.showErrorToast(message: 'Failed to mark all as read');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final ApiResponse response = await _repository.deleteNotification(
        notificationId: notificationId,
      );

      if (response.success) {
        // Check if it was unread before removing
        final NotificationModel? notification = notifications.firstWhereOrNull(
          (NotificationModel n) => n.id == notificationId,
        );
        if (notification != null && !notification.isRead && unreadCount.value > 0) {
          unreadCount.value--;
        }

        // Remove from local state
        notifications.removeWhere((NotificationModel n) => n.id == notificationId);
        AppToasts.showSuccessToast(message: 'Notification deleted');
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Delete notification error: $e');
      AppToasts.showErrorToast(message: 'Failed to delete notification');
    }
  }

  /// Add notification from FCM (called when FCM message is received)
  void addNotificationFromFCM(Map<String, dynamic> data) {
    try {
      final NotificationModel notification = NotificationModel.fromFCM(data);

      // Check if notification already exists
      final bool exists = notifications.any((NotificationModel n) => n.id == notification.id);
      if (!exists && notification.id.isNotEmpty) {
        // Add to the beginning of the list
        notifications.insert(0, notification);
        // Increment unread count
        unreadCount.value++;
      }
    } catch (e) {
      debugPrint('Add FCM notification error: $e');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      AppLoader.showLoadingDialog();
      final ApiResponse response = await _repository.deleteAllNotifications();
      AppLoader.hideLoadingDialog();

      if (response.success) {
        notifications.clear();
        unreadCount.value = 0;
        AppToasts.showSuccessToast(message: 'All notifications deleted');
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Delete all notifications error: $e');
      AppToasts.showErrorToast(message: 'Failed to delete notifications');
    }
  }

  /// Refresh notifications (for pull-to-refresh)
  Future<void> refresh() async {
    await fetchNotifications(isRefresh: true);
    await fetchUnreadCount();
  }
}
