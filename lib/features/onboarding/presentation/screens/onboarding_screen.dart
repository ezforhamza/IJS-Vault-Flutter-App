import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_strings.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/onboarding/presentation/widgets/active_dot.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = <OnboardingData>[
    OnboardingData(
      image: AppImages.onboarding1,
      title: AppStrings.onboarding1title,
      subtitle: AppStrings.onboarding1subtitle,
    ),
    OnboardingData(
      image: AppImages.onboarding2,
      title: AppStrings.onboarding2title,
      subtitle: AppStrings.onboarding2subtitle,
    ),
    OnboardingData(
      image: AppImages.onboarding3,
      title: AppStrings.onboarding3title,
      subtitle: AppStrings.onboarding3subtitle,
    ),
  ];

  void _nextPage() async {
    if (_currentPage < _onboardingPages.length - 1) {
      setState(() => _currentPage++);
    } else {
      await LocalStorageService.setFirstTime(false);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _skipOnboarding() async {
    await LocalStorageService.setFirstTime(false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);
    final double w = ScreenHelper.width(context);
    final bool isLastPage = _currentPage == _onboardingPages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ───────── Skip ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _skipOnboarding,
                  child:
                      Text(
                            isLastPage ? '' : AppStrings.skip,
                            style: theme.bodyMedium,
                          )
                          .animate(key: ValueKey('skip_$_currentPage'))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.2),
                ),
              ),
            ),

            SizedBox(height: h * 0.08),

            // ───────── Image ─────────
            Expanded(
              flex: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            return Image.asset(
                                  _onboardingPages[_currentPage].image,
                                  key: ValueKey<int>(_currentPage),
                                  height: constraints.maxHeight * 0.9,
                                  fit: BoxFit.contain,
                                )
                                .animate(
                                  key: ValueKey('image_anim_$_currentPage'),
                                )
                                .fadeIn(duration: 300.ms)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                  curve: Curves.easeOut,
                                );
                          },
                    ),
                  ),
                ),
              ),
            ),

            // ───────── Bottom Card ─────────
            SizedBox(
              height: 280,
              child: _OnboardingBottom(
                h: h,
                w: w,
                currentPage: _currentPage,
                pages: _onboardingPages,
                onNextPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBottom extends StatelessWidget {
  const _OnboardingBottom({
    required this.h,
    required this.w,
    required this.currentPage,
    required this.pages,
    required this.onNextPressed,
  });

  final double h;
  final double w;
  final int currentPage;
  final List<OnboardingData> pages;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isLastPage = currentPage == pages.length - 1;

    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.gradient),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.scaffoldBackgroundColor
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 25),

                // ───────── Dots ─────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (int index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: index == currentPage
                          ? ActiveDot(
                              key: ValueKey('dot_$currentPage'),
                              size: 17,
                            )
                          : CircleAvatar(
                              radius: 5,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF827c5d)
                                  : const Color(0xFFfaf3cf),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ───────── Text ─────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: 350.ms,
                    child:
                        Column(
                              key: ValueKey('text_$currentPage'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  pages[currentPage].title,
                                  style: theme.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  pages[currentPage].subtitle,
                                  style: theme.labelSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                            .animate(key: ValueKey('text_anim_$currentPage'))
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: 0.2)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              curve: Curves.easeOut,
                            ),
                  ),
                ),

                // ───────── Button ─────────
                CustomButton(
                  // key: ValueKey('btn_$currentPage'),
                  onTap: onNextPressed,
                  text: isLastPage ? 'Get Started' : 'Next',
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}
