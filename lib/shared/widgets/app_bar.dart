import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.text, this.actions});
  final String text;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SvgPicture.asset(
            AppImages.back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      title: Text(text, style: textTheme.labelLarge?.copyWith(fontSize: 16)),
      actions: actions,
    );
  }

  // Implement PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
