import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController with WidgetsBindingObserver {
  /// Reactive variable for dark mode
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Add observer to listen to system theme changes
    WidgetsBinding.instance.addObserver(this);

    // Detect system theme on startup
    final bool systemDark =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    isDark.value = systemDark;

    // Apply the initial theme
    Get.changeThemeMode(systemDark ? ThemeMode.dark : ThemeMode.light);

    print('Initial system dark mode? $systemDark');
  }

  /// Called when system brightness changes (dynamic updates)
  @override
  void didChangePlatformBrightness() {
    final bool systemDark =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

    // Only update if the user hasn't overridden manually
    if (!isDark.value)
      return; // Optional: remove this if you want always follow system
    isDark.value = systemDark;
    Get.changeThemeMode(systemDark ? ThemeMode.dark : ThemeMode.light);

    print('System brightness changed: $systemDark');
  }

  /// Toggle theme manually
  void toggleTheme(bool value) {
    isDark.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void onClose() {
    // Remove observer to avoid memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
