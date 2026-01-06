import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/theme_controller.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/custom_switch.dart';

class SettingOptionWidget extends StatelessWidget {
  const SettingOptionWidget({
    super.key,
    required this.text,
    required this.icon,
    this.isSwitch = false,
  });
  final bool isSwitch;
  final String text;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;
    final ThemeController themeController = Get.find();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: const GradientBoxBorder(
          gradient: LinearGradient(colors: AppColors.gradient),
          width: 0.6,
        ),
      ),
      child: Row(
        spacing: 10,
        children: <Widget>[
          SvgPicture.asset(icon),
          Text(
            text,
            style: textTheme.labelLarge!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          isSwitch
              ?
                // Switch
                Obx(
                  () => CustomSwitch(
                    value: themeController.isDark.value,
                    onChanged: (bool value) {
                      themeController.toggleTheme(value);
                    },
                  ),
                )
              : const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
