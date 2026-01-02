import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';

class ActivityLogWidget extends StatelessWidget {
  const ActivityLogWidget({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
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
          // Icon
          CircleAvatar(
            backgroundColor: const Color(0xFF0B6B7B),
            child: SvgPicture.asset(AppImages.uploaded),
          ),

          const SizedBox(width: 10),

          // MAIN CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// Username + action (wraps correctly)
                Wrap(
                  spacing: 5,
                  runSpacing: 2,
                  children: <Widget>[
                    Text('John Doe', style: textTheme.bodySmall),
                    Text(
                      'uploaded',
                      style: textTheme.labelSmall!.copyWith(fontSize: 11),
                      softWrap: true,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// File name
                Text('Resume.pdf', style: textTheme.bodySmall, softWrap: true),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// Time
          Text(
            '15 Dec 2025',
            style: textTheme.labelSmall!.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
