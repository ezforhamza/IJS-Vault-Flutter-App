import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/presentation/screens/shared_vault_scrren.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class LinkedUserWidget extends StatelessWidget {
  const LinkedUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

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
            const ProfilePictureWidget(
              radius: 20,
              imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
            ),

            const SizedBox(width: 10),

            // RIGHT SIDE CONTENT (bounded width)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Name
                  Text(
                    'User Name',
                    style: theme.labelMedium!.copyWith(fontSize: 14),
                  ),

                  // Email
                  Text(
                    'useremail@gmail.com',
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
                              text: '1',
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
