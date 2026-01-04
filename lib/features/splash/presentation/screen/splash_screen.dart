import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/screens/bottom_nav_bar_screen.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 4));

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    /// Example keys (use whatever you saved)
    // final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? userToken = prefs.getString('user');

    if (userToken != null && userToken.isNotEmpty) {
      /// User exists → Home
      Get.offAll(() => const HomeWithBottomNavScreen());
    } else {
      /// No user → Onboarding / Login
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /// Gif / Image
          Transform.rotate(
            angle: -10 * 3.1416 / 180,
            child: Image.asset(AppImages.splash, height: 140),
          ),

          const SizedBox(height: 12),

          /// App Name
          const TextGradient(
            text: 'IJS VAULT',
            fontsize: 35,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}
