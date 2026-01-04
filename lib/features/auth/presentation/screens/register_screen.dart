import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
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
    final TextEditingController nameController = .new();
    final TextEditingController emailController = .new();

    final TextEditingController phoneController = .new();

    final TextEditingController passwordController = .new();
    final TextEditingController confirmpasswordController = .new();
    final GlobalKey<FormState> formkey = GlobalKey<FormState>();

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Form(
            key: formkey,

            child: Column(
              spacing: 0,
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: <Widget>[
                SizedBox(height: MediaQuery.paddingOf(context).top + 30),
                Column(
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    Text('Create Account!', style: theme.labelLarge),
                    Text(
                      'Create your account and connect with the community.',
                      style: theme.labelSmall,
                    ),
                  ],
                ),
                const Center(child: PfpSelectionWidget()),
                // Text Field
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

                // Text Field
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
                CustomTextField(
                  validator: InputValidators.password,
                  controller: passwordController,
                  title: 'Password',
                  hintText: "Enter Password",
                  isPassword: true,
                  prefixIcon: SvgPicture.asset(
                    AppImages.lock,
                    color: const Color(0xFFB2B2B2),
                  ),
                ),

                // Text Field
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
                // Privacy Policy And Terms
                Row(
                  spacing: 10,
                  children: <Widget>[
                    // Check Box
                    Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        // gradient: LinearGradient(colors: AppColors.gradient),
                        border: Border.all(color: const Color(0xFFa4a4a4)),
                      ),
                      child: const Icon(Icons.check, color: Color(0xFFd1b243)),
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
                const SizedBox(height: 10),
                // Button
                CustomButton(
                  onTap: () {
                    // Get.to(() => const SetPinScreen());
                    if (formkey.currentState!.validate()) {
                      controller.register(
                        fullname: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    } else {}
                  },
                  text: 'Create Account',
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: .center,
                  children: <Widget>[
                    // FIrst
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
                    ), // Register
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
