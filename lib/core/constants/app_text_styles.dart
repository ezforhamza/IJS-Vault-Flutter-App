import 'package:flutter/material.dart';

class AppTextStyles {
  // 🔹 Medium 12px – Line height 100%
  static TextStyle medium12(Color color) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.0, // 100%
    letterSpacing: 0,
    color: color,
  );
  static TextStyle large20(Color color) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 22 / 14, // exact line-height
    letterSpacing: 0,
    color: color,
  );
  // 🔹 Medium 14px – Line height 22px
  static TextStyle medium14(Color color) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 14, // exact line-height
    letterSpacing: 0,
    color: color,
  );

  // 🔹 Regular 12px – Line height 150%
  static TextStyle regular12(Color color) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5, // 150%
    letterSpacing: 0,
    color: color,
  );
}
