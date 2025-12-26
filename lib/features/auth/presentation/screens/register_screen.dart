import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/auth/presentation/widgets/pfp_selection_widget.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 30),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Create Account!', style: theme.labelLarge),
                  Text(
                    'Create your account and connect with the community.',
                    style: theme.labelSmall,
                  ),
                ],
              ),
              Center(child: PfpSelectionWidget()),
              // Text Field
              CustomTextField(
                title: 'Full Name',
                hintText: "Enter Name",
                prefixIcon: SvgPicture.asset(
                  AppImages.profile,
                  color: Color(0xFFB2B2B2),
                ),
              ),

              // Text Field
              CustomTextField(
                title: 'Email Address',
                hintText: "Enter Email Address",
                prefixIcon: SvgPicture.asset(
                  AppImages.email,
                  color: Color(0xFFB2B2B2),
                ),
              ),
              CustomTextField(
                title: 'Phone Number',
                hintText: "Enter Phone Number",
                prefixIcon: SvgPicture.asset(
                  AppImages.phone,
                  color: Color(0xFFB2B2B2),
                ),
              ),
              CustomTextField(
                title: 'Password',
                hintText: "Enter Password",
                isPassword: true,
                prefixIcon: SvgPicture.asset(
                  AppImages.lock,
                  color: Color(0xFFB2B2B2),
                ),
              ),

              // Text Field
              CustomTextField(
                title: 'Confirm Password',
                hintText: "Enter Confirm Password",
                isPassword: true,
                prefixIcon: SvgPicture.asset(
                  AppImages.lock,
                  color: Color(0xFFB2B2B2),
                ),
              ),
              // Privacy Policy And Terms
              Row(
                spacing: 10,
                children: [
                  // Check Box
                  Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      // gradient: LinearGradient(colors: AppColors.gradient),
                      border: Border.all(color: Color(0xFFa4a4a4)),
                    ),
                    child: Icon(Icons.check, color: Color(0xFFd1b243)),
                  ),
                  // Text
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.labelSmall,
                        children: [
                          const TextSpan(text: 'I agree to the '),

                          TextSpan(
                            text: 'terms & conditions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              foreground: Paint()
                                ..shader =
                                    const LinearGradient(
                                      colors: AppColors.gradient,
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 20),
                                    ),
                            ),
                          ),

                          const TextSpan(text: ' and '),

                          TextSpan(
                            text: 'privacy policy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              foreground: Paint()
                                ..shader =
                                    const LinearGradient(
                                      colors: AppColors.gradient,
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 20),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Button
              CustomButton(onTap: () {}, text: 'Create Account'),

              Row(
                mainAxisAlignment: .center,
                children: [
                  // FIrst
                  Text('Already have an account? ', style: theme.labelSmall),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => LoginScreen());
                    },
                    child: TextGradient(
                      text: 'Sign in',
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
