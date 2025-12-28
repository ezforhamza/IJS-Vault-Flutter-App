import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/auth/presentation/screens/register_screen.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/screens/bottom_nav_bar_screen.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/forgotpassword_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);
    return Scaffold(
      // resizeToAvoidBottomInset: tu,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: <Widget>[
              SizedBox(height: MediaQuery.paddingOf(context).top + 30),
              Column(
                crossAxisAlignment: .start,
                children: <Widget>[
                  Text('Welcome', style: theme.labelLarge),
                  Text(
                    'Sign in to access your account and connect.',
                    style: theme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Text Field
              CustomTextField(
                title: 'Email Address',
                hintText: "Enter Email Address",
                prefixIcon: SvgPicture.asset(
                  AppImages.email,
                  color: const Color(0xFFB2B2B2),
                ),
              ),
              CustomTextField(
                title: 'Password',
                hintText: "Enter Password",
                isPassword: true,
                prefixIcon: SvgPicture.asset(
                  AppImages.lock,
                  color: const Color(0xFFB2B2B2),
                ),
              ),
              // Forgot Password
              Row(
                mainAxisAlignment: .end,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const ForgotpasswordScreen());
                    },
                    child: const TextGradient(text: 'Forgot Password?'),
                  ),
                ],
              ),
              // Button
              CustomButton(
                onTap: () {
                  Get.to(() => const HomeWithBottomNavScreen());
                },
                text: 'Sign in',
              ),
              const SizedBox(height: 5),

              //Divider OR Sign IN With
              Row(
                spacing: 8,
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: isDarkMode
                          ? const Color(0xFF666666)
                          : const Color(0xFFd9d9d9),
                    ),
                  ),
                  Text('Or sign in with', style: theme.labelSmall),
                  Expanded(
                    child: Divider(
                      color: isDarkMode
                          ? const Color(0xFF666666)
                          : const Color(0xFFd9d9d9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Google Option
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10000),
                  border: Border.all(
                    color: isDarkMode ? Colors.white : const Color(0xFFd9d9d9),
                  ),
                ),
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: .center,
                  children: <Widget>[
                    // Google Image
                    SvgPicture.asset(AppImages.google),
                    // TExt
                    Text("Continue with Google", style: theme.bodySmall),
                  ],
                ),
              ),
              // Spacer(),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: .center,
                children: <Widget>[
                  // FIrst
                  Text('Don’t have an account? ', style: theme.labelSmall),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const RegisterScreen());
                    },
                    child: const TextGradient(
                      text: 'Register Now',
                      fontsize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ), // Register
                ],
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
            ],
          ),
        ),
      ),
    );
  }
}
