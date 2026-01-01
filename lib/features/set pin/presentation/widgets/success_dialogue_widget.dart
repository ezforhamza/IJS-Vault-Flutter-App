import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/screens/bottom_nav_bar_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class SuccessDialogue extends StatelessWidget {
  const SuccessDialogue({super.key, required this.h, required this.theme});

  final double h;
  final TextTheme theme;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

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
                Image.asset(AppImages.successicon, height: h * 0.13)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack)
                    .fadeIn(),

                const SizedBox(height: 12),

                Text(
                  'PIN Set Successfully!',
                  style: theme.labelLarge!.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 6),

                Text(
                  'Your security PIN has been created. Use it to access this Vault safely.',
                  textAlign: TextAlign.center,
                  style: theme.labelSmall,
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                CustomButton(
                  onTap: () {
                    Get.offAll(() => const HomeWithBottomNavScreen());
                  },
                  text: 'Continue',
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
