import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/custom_switch.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const CustomAppBar(text: 'Notifications'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            //
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
                  // ROw
                  OptionWIdget(textTheme: textTheme, text: 'Reminders'),
                  const Divider(),
                  OptionWIdget(
                    textTheme: textTheme,
                    text: 'Linked User Activity',
                  ),
                  const Divider(),

                  OptionWIdget(
                    textTheme: textTheme,
                    text: 'Invite Notification',
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

class OptionWIdget extends StatelessWidget {
  const OptionWIdget({super.key, required this.textTheme, required this.text});
  final String text;

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: <Widget>[
        SvgPicture.asset(AppImages.nreminders),
        Text(text, style: textTheme.bodySmall),
        const Spacer(),
        const CustomSwitch(),
      ],
    );
  }
}
