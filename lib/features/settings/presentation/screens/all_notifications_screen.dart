import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/data/models/notification_model.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/notification_controller.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class AllNotificationsScreen extends StatefulWidget {
  const AllNotificationsScreen({super.key});

  @override
  State<AllNotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  final NotificationController controller = Get.put(NotificationController());
  final ScrollController _scrollController = ScrollController();

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
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Notifications',
        // Note: CustomAppBar only takes 'text', I'll wrap it or use a separate row below it if needed.
        // But since I can't easily modify CustomAppBar without affecting other screens,
        // I will use a custom implementation for this screen's app bar area if needed,
        // or just add a button below it.
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(isRefresh: true),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (controller.notifications.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              AppImages.bell2,
                              height: 80,
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.black12,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No notifications yet',
                              style: theme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: <Widget>[
                  if (controller.notifications.any(
                    (NotificationModel n) => !n.isRead,
                  ))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: () => controller.markAllAsRead(),
                            icon: SvgPicture.asset(
                              AppImages.markcomplete,
                              height: 16,
                              color: const Color(0xFFc5a023),
                            ),
                            label: Text(
                              'Mark all as read',
                              style: theme.labelSmall?.copyWith(
                                color: const Color(0xFFc5a023),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSizes.horizontalPadding.copyWith(
                        bottom: 20,
                        top: 10,
                      ),
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                      itemCount:
                          controller.notifications.length +
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
                        return _buildNotificationItem(
                          notification,
                          theme,
                          isDarkMode,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    TextTheme theme,
    bool isDarkMode,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: SvgPicture.asset(
          AppImages.delete,
          color: Colors.redAccent,
          height: 24,
        ),
      ),
      onDismissed: (DismissDirection direction) {
        controller.deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : (isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.deepPurple.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white10
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: _getNotificationIconColor(
                    notification.type,
                  ).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationIconColor(notification.type),
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            notification.title.isNotEmpty
                                ? notification.title
                                : 'Notification',
                            style: theme.labelMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Just now', // Ideally replace with actual time ago logic if available
                          style: theme.labelSmall?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: notification.message,
                            style: theme.labelSmall?.copyWith(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          if (notification.itemName.isNotEmpty)
                            TextSpan(
                              text: ' ${notification.itemName}',
                              style: theme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFc5a023),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'upload':
        return AppImages.uploaded;
      case 'reminder':
        return AppImages.nreminders;
      case 'audit':
        return AppImages.activitylog;
      default:
        return AppImages.bell2;
    }
  }

  Color _getNotificationIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'upload':
        return Colors.blue;
      case 'reminder':
        return Colors.orange;
      case 'audit':
        return Colors.green;
      default:
        return const Color(0xFFc5a023);
    }
  }
}
