import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/data/models/activity_log_model.dart';

class ActivityLogWidget extends StatelessWidget {
  const ActivityLogWidget({
    super.key,
    required this.isDarkMode,
    required this.log,
  });

  final bool isDarkMode;
  final ActivityLogItem log;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Determine Icon and Color based on action
    String iconPath = AppImages.uploaded;
    Color iconBgColor = const Color(0xFF0B6B7B); // Tealish for upload

    final String action = log.action.toLowerCase();

    if (action.contains('delete')) {
      iconPath = AppImages.delete;
      iconBgColor = const Color(0xFFE85D5D); // Red
    } else if (action.contains('create')) {
      if (log.itemType == 'folder') {
        iconPath = AppImages.folder;
      } else {
        iconPath = AppImages.add;
      }
      iconBgColor = const Color(0xFF0B6B7B);
    } else if (action.contains('move')) {
      iconPath = AppImages.move;
      iconBgColor = Colors.orange;
    } else if (action.contains('edit') || action.contains('rename')) {
      iconPath = AppImages.edit;
      iconBgColor = Colors.blue;
    }

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
            backgroundColor: iconBgColor.withOpacity(0.2),
            child: SvgPicture.asset(
              iconPath,
              color: iconBgColor,
              width: 20,
              height: 20,
            ),
          ),

          const SizedBox(width: 10),

          // MAIN CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// Username + action
                Wrap(
                  spacing: 5,
                  runSpacing: 2,
                  children: <Widget>[
                    Text(
                      log.performedBy.name.isNotEmpty
                          ? log.performedBy.name
                          : 'User',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      log.action,
                      style: textTheme.labelSmall!.copyWith(fontSize: 11),
                      softWrap: true,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// Item name
                if (log.itemName.isNotEmpty)
                  Text(
                    log.itemName,
                    style: textTheme.bodySmall,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// Time (Placeholder purely, as backend JSON didn't give date)
          // If we had a date: Text(formatDate(log.createdAt), ...)
          // For now, let's leave it empty or generic if no date.
          if (log.createdAt != null)
            Text(
              log.createdAt!, // Parse and format if needed
              style: textTheme.labelSmall!.copyWith(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
