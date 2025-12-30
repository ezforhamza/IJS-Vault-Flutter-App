import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_text_styles.dart';

class AppLightTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: Colors.deepPurple,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    textTheme: TextTheme(
      labelLarge: AppTextStyles.large20(Colors.black),
      labelMedium: AppTextStyles.medium14(Colors.black),

      labelSmall: AppTextStyles.medium12(const Color(0xFFB2B2B2)),
      bodySmall: AppTextStyles.regular12(Colors.black),
      // bodyLarge:
    ),
    // inputDecorationTheme: const InputDecorationTheme(
    //   filled: true,
    //   fillColor: Color(0xFFfdfbf5),
    //   hintStyle: TextStyle(color: Color(0xFFa4a4a4), fontSize: 14),
    // ),
  );
  static const Color textfieldColor = Color(0xFFfdfbf5);
}
