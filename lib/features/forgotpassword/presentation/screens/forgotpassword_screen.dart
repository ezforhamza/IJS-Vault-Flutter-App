import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/verify_code_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class ForgotpasswordScreen extends StatelessWidget {
  const ForgotpasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);

    return Scaffold(
      appBar: const CustomAppBar(text: ''),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          spacing: 20,
          // mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          mainAxisSize: .max,
          children: <Widget>[
            // SizedBox(height: MediaQuery.paddingOf(context).top + 30),
            Column(
              crossAxisAlignment: .start,
              children: <Widget>[
                Center(
                  child: Image.asset(AppImages.forgotpassword, height: h * 0.2),
                ),
                const SizedBox(height: 50),

                Text('Forgot Password', style: theme.labelLarge),
                Text(
                  'We will send a code to your registered email address.',
                  style: theme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Text Field
            CustomTextField(
              title: 'Email Address',
              hintText: "Enter Email Address",
              prefixIcon: SvgPicture.asset(
                AppImages.email,
                color: const Color(0xFFB2B2B2),
              ),
            ),

            // Forgot Password

            // Button
            CustomButton(
              onTap: () {
                Get.to(() => const VerifyCodeScreen());
              },
              text: 'Send',
              isDisabled: true,
            ),
            const SizedBox(height: 20),

            SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
          ],
        ),
      ),
    );
  }
}
