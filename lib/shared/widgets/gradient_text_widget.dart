import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class TextGradient extends StatelessWidget {
  final String text;
  final double? fontsize;
  final FontWeight? fontWeight;
  const TextGradient({
    super.key,
    required this.text,
    this.fontsize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.centerRight,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: AppColors.gradient,
          ).createShader(bounds);
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontsize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
