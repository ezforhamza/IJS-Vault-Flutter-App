import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/utils/input_validators.dart';
import 'package:ijs_vault/features/auth/presentation/controllers/register_controller.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/auth/presentation/widgets/pfp_selection_widget.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
    final TextTheme theme = Theme.of(context).textTheme;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmpasswordController =
        TextEditingController();
    final GlobalKey<FormState> formkey = GlobalKey<FormState>();

    return Scaffold(
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              spacing: 0,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.paddingOf(context).top + 30),

                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Create Account!', style: theme.labelLarge),
                    Text(
                      'Create your account and connect with the community.',
                      style: theme.labelSmall,
                    ),
                  ],
                ),

                // Profile Picture Selection
                Center(
                  child: PfpSelectionWidget(
                    onImageSelected: (File file) {
                      controller.setProfilePicture(file);
                    },
                  ),
                ),

                // Full Name Field
                CustomTextField(
                  controller: nameController,
                  title: 'Full Name',
                  hintText: "Enter Name",
                  prefixIcon: SvgPicture.asset(
                    AppImages.profile,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Full Name is required";
                    }
                    return null;
                  },
                ),

                // Email Field
                CustomTextField(
                  validator: InputValidators.email,
                  controller: emailController,
                  title: 'Email Address',
                  hintText: "Enter Email Address",
                  prefixIcon: SvgPicture.asset(
                    AppImages.email,
                    color: const Color(0xFFB2B2B2),
                  ),
                ),

                // Phone Field
                CustomTextField(
                  controller: phoneController,
                  title: 'Phone Number',
                  hintText: "Enter Phone Number",
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number is required";
                    }
                    return null;
                  },
                  prefixIcon: SvgPicture.asset(
                    AppImages.phone,
                    color: const Color(0xFFB2B2B2),
                  ),
                ),

                // Password Field
                CustomTextField(
                  validator: InputValidators.createAccountpassword,
                  controller: passwordController,
                  title: 'Password',
                  hintText: "Enter Password",
                  isPassword: true,
                  prefixIcon: SvgPicture.asset(
                    AppImages.lock,
                    color: const Color(0xFFB2B2B2),
                  ),
                ),

                // Confirm Password Field
                CustomTextField(
                  controller: confirmpasswordController,
                  title: 'Confirm Password',
                  hintText: "Enter Confirm Password",
                  isPassword: true,
                  prefixIcon: SvgPicture.asset(
                    AppImages.lock,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                // Terms and Conditions Checkbox
                Obx(
                  () => GestureDetector(
                    onTap: controller.toggleTermsAcceptance,
                    child: Row(
                      spacing: 10,
                      children: <Widget>[
                        // Checkbox
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFa4a4a4)),
                            color: controller.termsAccepted.value
                                ? const Color(0xFFd1b243).withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: controller.termsAccepted.value
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFFd1b243),
                                  size: 18,
                                )
                              : null,
                        ),
                        // Text
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.labelSmall,
                              children: <InlineSpan>[
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
                  ),
                ),

                const SizedBox(height: 10),

                // Create Account Button
                CustomButton(
                  onTap: () {
                    if (formkey.currentState!.validate()) {
                      controller.register(
                        fullname: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    }
                  },
                  text: 'Create Account',
                ),

                const SizedBox(height: 10),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Already have an account? ', style: theme.labelSmall),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const LoginScreen());
                      },
                      child: const TextGradient(
                        text: 'Sign in',
                        fontsize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
