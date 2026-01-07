import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/utils/input_validators.dart';
import 'package:ijs_vault/features/auth/presentation/controllers/google_signin_controller.dart';
import 'package:ijs_vault/features/auth/presentation/controllers/signin_controller.dart';
import 'package:ijs_vault/features/auth/presentation/screens/register_screen.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/forgotpassword_screen.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool forceError = false;
  final SigninController controller = Get.put(SigninController());
  final GoogleSignInController googleController = Get.put(GoogleSignInController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.paddingOf(context).top + 40),

                // ───── Title ─────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Welcome', style: theme.labelLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to access your account and connect.',
                      style: theme.labelSmall,
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 40),

                // ───── Email ─────
                CustomTextField(
                  title: 'Email Address',
                  controller: emailController,
                  hintText: "Enter Email Address",
                  prefixIcon: SvgPicture.asset(
                    AppImages.email,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: InputValidators.email,
                ).animate().fadeIn(delay: 100.ms),

                // const SizedBox(height: 20),

                // ───── Password ─────
                CustomTextField(
                  title: 'Password',
                  controller: passwordController,
                  hintText: "Enter Password",

                  isPassword: true,
                  prefixIcon: SvgPicture.asset(
                    AppImages.lock,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: InputValidators.password,
                ).animate().fadeIn(delay: 200.ms),

                // ───── Forgot ─────
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
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),

                const SizedBox(height: 10),

                // ───── Button ─────
                CustomButton(
                      // onTap: _isLoading ? null : _login,
                      onTap: () {
                        // _login();
                        if (formKey.currentState!.validate()) {
                          controller.login(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                        }
                        // setState(() {});
                      },
                      text: 'Sign in',
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 30),

                // ───── Divider ─────
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: isDarkMode
                            ? const Color(0xFF666666)
                            : const Color(0xFFd9d9d9),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Or sign in with', style: theme.labelSmall),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDarkMode
                            ? const Color(0xFF666666)
                            : const Color(0xFFd9d9d9),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 20),

                // ───── Google ─────
                GestureDetector(
                  onTap: () {
                    googleController.signInWithGoogle();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFFd9d9d9),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(AppImages.google),
                        const SizedBox(width: 15),
                        Text("Continue with Google", style: theme.bodySmall),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 50),

                // ───── Register ─────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),

                SizedBox(height: MediaQuery.paddingOf(context).bottom + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
