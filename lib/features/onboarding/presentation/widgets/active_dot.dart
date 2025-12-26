import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class ActiveDot extends StatelessWidget {
  final double size; // diameter of the dot

  const ActiveDot({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final double borderWidth = size * 0.15; // 25% of the dot size
    final double innerPadding = size * 0.14; // optional inner padding

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: AppColors.gradient),
      ),
      child: Padding(
        padding: EdgeInsets.all(innerPadding),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.scaffoldBackgroundColor
                : Colors.white,
            border: Border.all(
              width: borderWidth,
              color: Colors.transparent, // border used for spacing effect
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppColors.gradient),
            ),
          ),
        ),
      ),
    );
  }
}
