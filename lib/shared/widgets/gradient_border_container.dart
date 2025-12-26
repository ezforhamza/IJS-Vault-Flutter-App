import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: GradientBoxBorder(
          gradient: LinearGradient(colors: AppColors.gradient),
          width: borderWidth,
        ),
      ),
      child: Center(child: child),
    );
  }
}
