import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

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
    Get.offAll(() => const OnboardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        children: <Widget>[
          // Gif
          Transform.rotate(
            angle: -10 * 3.1416 / 180, // radians
            child: Image.asset(AppImages.splash, height: 140),
          ),
          // Text
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
