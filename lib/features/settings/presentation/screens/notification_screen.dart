import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/notification_controller.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/custom_switch.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final bool isDarkMode = Get.isDarkMode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppBar(text: 'Notifications'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
                border: Border.all(color: const Color(0xFF433e2f)),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Column(
                spacing: 10,
                children: <Widget>[
                  Obx(
                    () => OptionWidget(
                      textTheme: textTheme,
                      text: 'Reminders',
                      icon: AppImages.nreminders,
                      value: controller.reminders.value,
                      onChanged: controller.toggleReminders,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => OptionWidget(
                      textTheme: textTheme,
                      text: 'Linked User Activity',
                      icon: AppImages.nreminders,
                      value: controller.linkedUsersActivity.value,
                      onChanged: controller.toggleLinkedUsersActivity,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => OptionWidget(
                      textTheme: textTheme,
                      text: 'Invite Notification',
                      icon: AppImages.nreminders,
                      value: controller.inviteNotifications.value,
                      onChanged: controller.toggleInviteNotifications,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget({
    super.key,
    required this.textTheme,
    required this.text,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final String icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: <Widget>[
        SvgPicture.asset(icon),
        Text(text, style: textTheme.bodySmall),
        const Spacer(),
        CustomSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
