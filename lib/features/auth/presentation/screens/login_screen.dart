import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/auth/presentation/screens/register_screen.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/forgotpassword_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isDarkMode = ScreenHelper.isdarkMode(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          spacing: 20,
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 30),
            Column(
              crossAxisAlignment: .start,
              children: [
                Text('Welcome', style: theme.labelLarge),
                Text(
                  'Sign in to access your account and connect.',
                  style: theme.labelSmall,
                ),
              ],
            ),
            SizedBox(height: 30),

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
              title: 'Password',
              hintText: "Enter Password",
              isPassword: true,
              prefixIcon: SvgPicture.asset(
                AppImages.lock,
                color: Color(0xFFB2B2B2),
              ),
            ),
            // Forgot Password
            Row(
              mainAxisAlignment: .end,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => ForgotpasswordScreen());
                  },
                  child: TextGradient(text: 'Forgot Password?'),
                ),
              ],
            ),
            // Button
            CustomButton(onTap: () {}, text: 'Sign in'),
            SizedBox(height: 5),

            //Divider OR Sign IN With
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Divider(
                    color: isDarkMode ? Color(0xFF666666) : Color(0xFFd9d9d9),
                  ),
                ),
                Text('Or sign in with', style: theme.labelSmall),
                Expanded(
                  child: Divider(
                    color: isDarkMode ? Color(0xFF666666) : Color(0xFFd9d9d9),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            // Google Option
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10000),
                border: Border.all(
                  color: isDarkMode ? Colors.white : Color(0xFFd9d9d9),
                ),
              ),
              child: Row(
                spacing: 20,
                mainAxisAlignment: .center,
                children: [
                  // Google Image
                  SvgPicture.asset(AppImages.google),
                  // TExt
                  Text("Continue with Google", style: theme.bodySmall),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: .center,
              children: [
                // FIrst
                Text('Don’t have an account? ', style: theme.labelSmall),
                GestureDetector(
                  onTap: () {
                    Get.to(() => RegisterScreen());
                  },
                  child: TextGradient(
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
    );
  }
}
