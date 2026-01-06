import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class ProfileWIdget extends StatelessWidget {
  const ProfileWIdget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;
    final ProfileController controller = Get.find<ProfileController>();
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
      child: Obx(
        () => Row(
          spacing: 10,
          children: <Widget>[
            // PFP
            ProfilePictureWidget(
              radius: 30,
              imageUrl: controller.currentUser.value!.image,
            ),
            // Name Email
            Column(
              crossAxisAlignment: .start,
              children: <Widget>[
                // Name
                Text(
                  controller.currentUser.value!.fullName,
                  style: textTheme.labelLarge!.copyWith(fontSize: 14),
                ),
                Text(
                  controller.currentUser.value!.email,
                  style: textTheme.labelSmall!.copyWith(fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
