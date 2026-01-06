import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/linked_users/presentation/screens/shared_vault_scrren.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class LinkedUserWidget extends StatelessWidget {
  const LinkedUserWidget({super.key, required this.user});
  final LinkedUserModel user;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.to(() => const SharedVaultScrren());
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
          border: const GradientBoxBorder(
            gradient: LinearGradient(colors: AppColors.gradient),
            width: 0.6,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Picture
            ProfilePictureWidget(radius: 20, imageUrl: user.image),

            const SizedBox(width: 10),

            // RIGHT SIDE CONTENT (bounded width)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Name
                  Text(
                    user.fullName,
                    style: theme.labelMedium!.copyWith(fontSize: 14),
                  ),

                  // Email
                  Text(
                    user.email,
                    style: theme.labelSmall!.copyWith(fontSize: 10),
                  ),

                  const SizedBox(height: 6),

                  // Folders / Files / Shared Vault
                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Folders: ',
                              style: theme.labelMedium!.copyWith(fontSize: 14),
                            ),
                            TextSpan(
                              text: user.totalSharedCount.toString(),
                              style: theme.labelSmall!.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Files: ',
                              style: theme.labelMedium!.copyWith(fontSize: 14),
                            ),
                            TextSpan(
                              text: '3',
                              style: theme.labelSmall!.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      // Push Shared Vault to the far right
                      const Spacer(),

                      const TextGradient(
                        text: 'Shared Vault',
                        fontWeight: FontWeight.w500,
                      ),
                    ],
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
