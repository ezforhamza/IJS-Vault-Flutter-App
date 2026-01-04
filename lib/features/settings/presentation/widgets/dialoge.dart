import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class ConfirmationDialogue extends StatelessWidget {
  const ConfirmationDialogue({
    super.key,
    required this.h,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonText,
    required this.onTap,
  });

  final double h;
  final TextTheme theme;
  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final VoidCallback onTap; // ✅ callback

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          backgroundColor: isDarkMode
              ? AppColors.scaffoldBackgroundColor
              : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SvgPicture.asset(image, height: h * 0.13)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack)
                    .fadeIn(),

                const SizedBox(height: 12),

                Text(
                  title,
                  style: theme.labelLarge!.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.labelSmall,
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                CustomButton(
                  onTap: onTap,
                  text: buttonText,
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        )
        // 🔥 Dialog popup animation
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }
}
