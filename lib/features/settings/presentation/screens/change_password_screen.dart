import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/forgotpassword_screen.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'Change Password'),

      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            const CustomTextField(
              title: 'Old Password',
              hintText: 'Enter Old Password',
              isPassword: true,
            ),
            Row(
              mainAxisAlignment: .end,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const ForgotpasswordScreen());
                    },
                    child: const TextGradient(text: 'Forgot Password?'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            //
            const CustomTextField(
              title: 'New Password',
              hintText: 'Enter New Password',
              isPassword: true,
            ),
            //
            const CustomTextField(
              title: 'Confirm Password',
              hintText: 'Enter Confirm Password',
              isPassword: true,
            ),
            const Spacer(),
            CustomButton(onTap: () {}, text: 'Update'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
