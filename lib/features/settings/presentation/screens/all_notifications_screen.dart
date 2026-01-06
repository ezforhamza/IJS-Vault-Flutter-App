import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      appBar: const CustomAppBar(text: 'Notifications'),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Text('No notifications yet', style: theme.labelSmall),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(isRefresh: true),
          child: ListView.separated(
            controller: _scrollController,
            padding: AppSizes.horizontalPadding.copyWith(top: 20, bottom: 20),
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 20);
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
              return Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Icon based on type
                  Expanded(
                    child: Text(notification.title, style: theme.labelSmall),
                  ),
                  Text('5m ago', style: theme.labelSmall),

                  // Text
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
