import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class ReminderWidget extends StatelessWidget {
  const ReminderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Container(
      padding: const EdgeInsets.all(10),
      // margin: const EdgeInsets.symmetric(vertical: 10),
      // color: Colors.red,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        border: Border.all(
          color: isDarkMode ? const Color(0xFF47443b) : const Color(0xFFf7f2e0),
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: .start,
          spacing: 5,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Letter for job',
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium,
                ),
                const Spacer(),
                const Icon(Icons.more_vert),
              ],
            ),

            // File Type Detai
            Row(
              spacing: 5,
              children: <Widget>[
                // Image
                SvgPicture.asset(AppImages.pdf),
                // COlumn
                Column(
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    //Name
                    Text('Cover Letter', style: textTheme.labelMedium),
                    Text('867 KB', style: textTheme.labelSmall),

                    // Size
                  ],
                ),
              ],
            ),
            // Description
            Text(
              'Scanned copy of my Cover Letter.',
              style: textTheme.labelSmall!.copyWith(fontSize: 14),
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Reminder Date & Time: ',
                    style: textTheme.labelMedium,
                  ),
                  TextSpan(
                    text: '20 Oct, 2025 - 8:00',
                    style: textTheme.labelSmall!.copyWith(fontSize: 14),
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
