import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final h = ScreenHelper.height(context);

    return Scaffold(
      appBar: CustomAppBar(),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          spacing: 20,
          // mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          mainAxisSize: .max,
          children: [
            // SizedBox(height: MediaQuery.paddingOf(context).top + 30),
            Column(
              crossAxisAlignment: .start,
              children: [
                Center(
                  child: Image.asset(AppImages.resetpassword, height: h * 0.2),
                ),
                SizedBox(height: 50),

                Text('Reset Password', style: theme.labelLarge),
                Text(
                  'You can now reset your password.',
                  style: theme.labelSmall,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Text Field
            CustomTextField(
              isPassword: true,
              title: 'New Password',
              hintText: "Enter New Password",
              prefixIcon: SvgPicture.asset(
                AppImages.email,
                color: Color(0xFFB2B2B2),
              ),
            ),
            CustomTextField(
              isPassword: true,

              title: 'Confirm Password',
              hintText: "Enter Confirm Password",
              prefixIcon: SvgPicture.asset(
                AppImages.email,
                color: Color(0xFFB2B2B2),
              ),
            ),

            // Forgot Password

            // Button
            CustomButton(
              onTap: () {
                // Get.to(() => VerifyCodeScreen());
              },
              text: 'Reset',
              isDisabled: true,
            ),
            SizedBox(height: 20),

            SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
          ],
        ),
      ),
    );
  }
}
