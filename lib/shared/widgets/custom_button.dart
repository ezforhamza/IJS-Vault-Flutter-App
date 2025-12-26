import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isDisabled = false,
  });

  final VoidCallback onTap;
  final String text;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          // elevation: 5,
          backgroundColor: Colors.transparent,

          // shadowColor: const Color.fromARGB(255, 0, 0, 0),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? const LinearGradient(
                    colors: [
                      AppColors.disabledbuttoncolor,
                      AppColors.disabledbuttoncolor,
                    ], // gradient background
                  )
                : const LinearGradient(
                    colors: AppColors.gradient, // gradient background
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
