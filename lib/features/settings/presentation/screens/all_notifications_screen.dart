import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/folder_view_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/all_reminders_screen.dart';
import 'package:ijs_vault/features/settings/data/models/notification_model.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/notification_controller.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';
import 'package:intl/intl.dart';

class AllNotificationsScreen extends StatefulWidget {
  const AllNotificationsScreen({super.key});

  @override
  State<AllNotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  final NotificationController controller = Get.put(NotificationController());
  final ScrollController _scrollController = ScrollController();
  final MyVaultRepo _repo = MyVaultRepo();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(
        text: 'Notifications',
        actions: <Widget>[
          // More options menu
          Obx(() {
            if (controller.notifications.isEmpty) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onSelected: (String value) => _handleMenuAction(value),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (controller.notifications.any((NotificationModel n) => !n.isRead))
                  const PopupMenuItem<String>(
                    value: 'mark_all_read',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: 12),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete all', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const _LoadingShimmer();
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.gradient[0],
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: controller.notifications.length +
                (controller.isFetchingMore.value ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final NotificationModel notification =
                  controller.notifications[index];
              return _NotificationTile(
                notification: notification,
                isDarkMode: isDarkMode,
                onTap: () => _handleNotificationTap(notification),
                onDismiss: () => controller.deleteNotification(notification.id),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: isDarkMode ? Colors.white38 : Colors.black26,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you receive notifications,\nthey will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        controller.markAllAsRead();
        break;
      case 'delete_all':
        _showDeleteAllConfirmation();
        break;
    }
  }

  void _showDeleteAllConfirmation() {
    final bool isDarkMode = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete All Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAllNotifications();
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read if not already
    if (!notification.isRead) {
      controller.markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    _navigateToNotificationTarget(notification);
  }

  Future<void> _navigateToNotificationTarget(NotificationModel notification) async {
    // Check if notification has an item to navigate to
    final String? itemId = notification.itemId ?? notification.data?.itemId;

    if (itemId != null && itemId.isNotEmpty) {
      // Navigate to the vault item
      AppLoader.showLoadingDialog();

      try {
        final ApiResponse response = await _repo.getItemById(itemId: itemId);
        AppLoader.hideLoadingDialog();

        if (response.success) {
          final ItemModel item = ItemModel.fromJson(response.data['item']);

          if (item.type == 'folder') {
            Get.to(() => FolderViewScreen(item: item));
          } else {
            Get.to(() => ItemPreviewScreen(item: item));
          }
        } else {
          AppToasts.showErrorToast(message: 'Item not found or has been deleted');
        }
      } catch (e) {
        AppLoader.hideLoadingDialog();
        debugPrint('Navigation error: $e');
        AppToasts.showErrorToast(message: 'Failed to load item');
      }
    } else if (notification.type == 'reminder') {
      // Navigate to reminders screen
      Get.to(() => const AllRemindersScreen());
    } else if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      // Handle custom action URL if provided
      debugPrint('Action URL: ${notification.actionUrl}');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isDarkMode,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationModel notification;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : (isDarkMode
                    ? AppColors.gradient[0].withValues(alpha: 0.08)
                    : AppColors.gradient[0].withValues(alpha: 0.05)),
            border: Border(
              bottom: BorderSide(
                color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Icon or Avatar
              _buildNotificationIcon(),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title with unread indicator
                    Row(
                      children: <Widget>[
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.gradient,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Body
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Footer - time and type badge
                    Row(
                      children: <Widget>[
                        _buildTypeBadge(),
                        const Spacer(),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    // If notification has fromUser with image, show avatar
    if (notification.fromUser?.image != null &&
        notification.fromUser!.image!.isNotEmpty) {
      return ProfilePictureWidget(
        radius: 22,
        imageUrl: notification.fromUser!.image ?? '',
      );
    }

    // Otherwise show icon based on type
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            _getTypeColor().withValues(alpha: 0.2),
            _getTypeColor().withValues(alpha: 0.1),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(),
        size: 22,
        color: _getTypeColor(),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getTypeLabel(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'share':
        return Icons.share;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete_outline;
      case 'move':
        return Icons.drive_file_move_outline;
      case 'unshare':
        return Icons.person_remove_outlined;
      case 'reminder':
        return Icons.alarm;
      case 'admin_notification':
        return Icons.campaign_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'share':
        return Colors.blue;
      case 'edit':
        return Colors.orange;
      case 'delete':
        return Colors.red;
      case 'move':
        return Colors.purple;
      case 'unshare':
        return Colors.red;
      case 'reminder':
        return Colors.teal;
      case 'admin_notification':
        return AppColors.gradient[0];
      case 'system':
        return Colors.grey;
      default:
        return AppColors.gradient[0];
    }
  }

  String _getTypeLabel() {
    switch (notification.type) {
      case 'share':
        return 'Shared';
      case 'edit':
        return 'Edited';
      case 'delete':
        return 'Deleted';
      case 'move':
        return 'Moved';
      case 'unshare':
        return 'Unshared';
      case 'reminder':
        return 'Reminder';
      case 'admin_notification':
        return 'Announcement';
      case 'system':
        return 'System';
      default:
        return notification.type.capitalizeFirst ?? 'Notification';
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final DateTime now = DateTime.now();
    final Duration difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Avatar shimmer
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 200,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
