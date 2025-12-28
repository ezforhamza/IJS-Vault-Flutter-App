import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class GradientBorderContainer extends StatelessWidget {
  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
  });
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: GradientBoxBorder(
          gradient: const LinearGradient(colors: AppColors.gradient),
          width: borderWidth,
        ),
      ),
      child: Center(child: child),
    );
  }
}
