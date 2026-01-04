import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/themes/app_theme.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/features/settings/presentation/controller/theme_controller.dart';
import 'package:ijs_vault/features/splash/presentation/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent, // make status bar transparent
  //     statusBarIconBrightness: Brightness.dark, // dark icons for light theme
  //     statusBarBrightness: Brightness.light, // iOS status bar brightness
  //   ),
  // );

  Get.put(MyVaultController());
  Get.put(ReminderController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());

    return GetMaterialApp(
      // defaultTransition: Transition.rightToLeft,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
