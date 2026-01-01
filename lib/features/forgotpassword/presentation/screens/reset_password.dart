import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/utils/input_validators.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/controllers/reset_password_controller.dart';
import 'package:ijs_vault/shared/helpers/key_board_helper.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isDisabled = true;

  void _checkFormValidity() {
    setState(() {
      isDisabled = !(formKey.currentState?.validate() ?? false);
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);
    final ResetPasswordController controller = Get.put(
      ResetPasswordController(),
    );

    return Scaffold(
      appBar: const CustomAppBar(text: ''),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset(AppImages.resetpassword, height: h * 0.2),
                ),
                const SizedBox(height: 50),

                Text('Reset Password', style: theme.labelLarge),
                Text(
                  'You can now reset your password.',
                  style: theme.labelSmall,
                ),
                const SizedBox(height: 20),

                // New Password
                CustomTextField(
                  controller: newPasswordController,
                  isPassword: true,
                  title: 'New Password',
                  hintText: "Enter New Password",
                  prefixIcon: SvgPicture.asset(
                    AppImages.email,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: InputValidators.password,
                  onChanged: (String value) => _checkFormValidity(),
                ),
                const SizedBox(height: 15),

                // Confirm Password
                CustomTextField(
                  controller: confirmPasswordController,
                  isPassword: true,
                  title: 'Confirm Password',
                  hintText: "Enter Confirm Password",
                  prefixIcon: SvgPicture.asset(
                    AppImages.email,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password is required';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: (String value) => _checkFormValidity(),
                ),
                const SizedBox(height: 30),

                // Reset Button
                CustomButton(
                  text: 'Reset',
                  isDisabled: isDisabled,
                  onTap: () {
                    if (formKey.currentState?.validate() ?? false) {
                      KeyboardHelper.closeKeyboard(context);
                      // Call API or navigate
                      // Get.snackbar('Success', 'Password reset successfully');
                      controller.resePassword();
                    }
                  },
                ),
                const SizedBox(height: 20),

                SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
