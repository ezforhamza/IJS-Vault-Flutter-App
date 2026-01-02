import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class ProfileWIdget extends StatelessWidget {
  const ProfileWIdget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;
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
          // PFP
          const ProfilePictureWidget(
            radius: 30,
            imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
          ),
          // Name Email
          Column(
            crossAxisAlignment: .start,
            children: <Widget>[
              // Name
              Text(
                'User Name',
                style: textTheme.labelLarge!.copyWith(fontSize: 14),
              ),
              Text(
                'jeromebell@gmail.com',
                style: textTheme.labelSmall!.copyWith(fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
