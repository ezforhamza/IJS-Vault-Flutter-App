import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/themes/dark_theme.dart';
import 'package:ijs_vault/core/themes/light_theme.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.isDarkMode,
    this.onChanged,
    this.controller,
  });

  final bool isDarkMode;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        filled: true,
        fillColor: isDarkMode
            ? AppDarkTheme.textfieldColor
            : AppLightTheme.textfieldColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(AppImages.search, width: 18, height: 18),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),
        border: _whiteBorder(),
        enabledBorder: _whiteBorder(),
        focusedBorder: _whiteBorder(),
        disabledBorder: _whiteBorder(),
        errorBorder: _whiteBorder(),
        focusedErrorBorder: _whiteBorder(),
      ),
    );
  }

  OutlineInputBorder _whiteBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white : const Color(0xFFb2b2b2),
        width: 1.2,
      ),
    );
  }
}
