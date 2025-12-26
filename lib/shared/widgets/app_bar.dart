import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ScreenHelper.isdarkMode(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: kToolbarHeight + topPadding,
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              AppImages.back,
              color: isDarkMode ? Colors.white : Colors.black,
              width: 22,
              height: 22,
            ),
            // text
          ),
        ],
      ),
    );
  }
}
