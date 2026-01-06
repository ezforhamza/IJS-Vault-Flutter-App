import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/utils/input_validators.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/forgotpassword_screen.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/change_password_controller.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController controller = Get.put(
      ChangePasswordController(),
    );

    return Scaffold(
      appBar: const CustomAppBar(text: 'Change Password'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _oldPasswordController,
                  title: 'Old Password',
                  hintText: 'Enter Old Password',
                  isPassword: true,
                  validator: InputValidators.password,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                CustomTextField(
                  controller: _newPasswordController,
                  title: 'New Password',
                  hintText: 'Enter New Password',
                  isPassword: true,
                  validator: InputValidators.password,
                ),
                CustomTextField(
                  controller: _confirmPasswordController,
                  title: 'Confirm Password',
                  hintText: 'Enter Confirm Password',
                  isPassword: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                // const Spacer(),
                CustomButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      controller.changePasswordRequest(
                        oldPassword: _oldPasswordController.text,
                        newPassword: _newPasswordController.text,
                      );
                    }
                  },
                  text: 'Update',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
