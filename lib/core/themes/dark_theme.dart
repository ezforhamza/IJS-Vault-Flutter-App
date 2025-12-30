import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_text_styles.dart';

class AppDarkTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    // colorScheme: ColorScheme.dark(
    //   primary: Colors.deepPurple,
    //   secondary: Colors.purpleAccent,
    // ),
    fontFamily: 'Poppins',

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      labelLarge: AppTextStyles.large20(Colors.white),
      labelMedium: AppTextStyles.medium14(Colors.white),

      labelSmall: AppTextStyles.medium12(const Color(0xFFB2B2B2)),
      bodySmall: AppTextStyles.regular12(Colors.white),
    ),
    // inputDecorationTheme: const InputDecorationTheme(
    //   filled: true,
    //   fillColor: Color(0xFF20222b),
    //   hintStyle: TextStyle(color: Color(0xFFa4a4a4), fontSize: 14),
    // ),
  );
  static const Color textfieldColor = Color(0xFF20222b);
}
