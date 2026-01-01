import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class ActiveDot extends StatelessWidget {
  const ActiveDot({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    final double borderWidth = size * 0.15;
    final double innerPadding = size * 0.14;

    return Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: AppColors.gradient),
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
                  color: Colors.transparent,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: AppColors.gradient),
                ),
              ),
            ),
          ),
        )
        // 🎯 POP + FADE animation
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 350.ms,
        )
        .fadeIn(duration: 250.ms);
  }
}
