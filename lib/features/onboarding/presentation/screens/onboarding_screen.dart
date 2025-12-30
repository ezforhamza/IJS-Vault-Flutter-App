import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_strings.dart';
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

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
      );
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
    );
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
            // Skip Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _skipOnboarding,
                  child: Text(
                    isLastPage ? "" : AppStrings.skip,
                    style: theme.bodyMedium,
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.1),

            // Image Section - Flexible to adapt to screen size
            Expanded(
              // flex: 5,
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
                              // height: constraints.maxHeight * 0.9,
                              fit: BoxFit.contain,
                            );
                          },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Onboarding Content - Flexible bottom section
            SizedBox(
              height: 280,
              child: OnboardingWidget(
                h: h,
                w: w,
                currentPage: _currentPage,
                onboardingPages: _onboardingPages,
                onNextPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({
    super.key,
    required this.h,
    required this.w,
    required this.currentPage,
    required this.onboardingPages,
    required this.onNextPressed,
  });

  final double h;
  final double w;
  final int currentPage;
  final List<OnboardingData> onboardingPages;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isLastPage = currentPage == onboardingPages.length - 1;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            Container(
              height: constraints.maxHeight,
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
            Container(
              height: constraints.maxHeight,
              width: w,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: AppColors.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.scaffoldBackgroundColor
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(height: constraints.maxHeight * 0.06),

                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingPages.length,
                          (int index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: index == currentPage
                                ? const ActiveDot(size: 17)
                                : CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF827c5d)
                                        : const Color(0xFFfaf3cf),
                                    radius: 5,
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.05),

                      // Title and Subtitle - Takes available space
                      Expanded(
                        child: SingleChildScrollView(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            child: Column(
                              key: ValueKey<int>(currentPage),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // Title
                                Text(
                                  onboardingPages[currentPage].title,
                                  style: theme.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: constraints.maxHeight * 0.02),

                                // Subtitle
                                Text(
                                  onboardingPages[currentPage].subtitle,
                                  style: theme.labelSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Button
                      CustomButton(
                        onTap: onNextPressed,
                        text: isLastPage ? 'Get Started' : 'Next',
                      ),

                      SizedBox(height: constraints.maxHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
