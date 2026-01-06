import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/forgotpassword/domain/forgot_password_repo.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/gradient_border_container.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

/// Registration Email Verification Screen
/// Used after user creates a new account
/// Navigates to Login screen after successful verification
class RegistrationEmailVerificationScreen extends StatefulWidget {
  const RegistrationEmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<RegistrationEmailVerificationScreen> createState() =>
      _RegistrationEmailVerificationScreenState();
}

class _RegistrationEmailVerificationScreenState
    extends State<RegistrationEmailVerificationScreen> {
  static const int _initialSeconds = 45;
  bool isDisabled = true;
  int _secondsRemaining = _initialSeconds;
  Timer? _timer;
  String otp = '';

  final ForgotPasswordRepo _repo = ForgotPasswordRepo();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = _initialSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse res = await _repo.resendVerificationCode(
        email: widget.email,
      );

      AppLoader.hideLoadingDialog();

      if (res.success) {
        AppToasts.showSuccessToast(message: res.message);
        _startTimer();
      } else {
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      AppToasts.showErrorToast(message: 'Failed to resend code');
    }
  }

  Future<void> _verifyEmail() async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse res = await _repo.verifyOtp(
        email: widget.email,
        otp: otp,
        verificationType: 'emailVerification',
      );

      AppLoader.hideLoadingDialog();

      if (res.success) {
        AppToasts.showSuccessToast(
          message: 'Email verified successfully! Please login.',
        );
        // Navigate to Login screen (registration flow)
        Get.offAll(() => const LoginScreen());
      } else {
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Email verification error: $e');
      AppToasts.showErrorToast(message: 'Verification failed');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(text: ''),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30),

              Center(child: Image.asset(AppImages.verifycode, height: h * 0.2)),
              const SizedBox(height: 30),

              Text('Verify Your Email', style: theme.labelLarge),
              RichText(
                text: TextSpan(
                  style: theme.labelSmall,
                  children: <InlineSpan>[
                    const TextSpan(
                      text: 'We have sent a verification code to ',
                    ),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: AppColors.gradient,
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 20)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Enter Code',
                style: theme.labelMedium!.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              OtpInput(
                isOtpWrong: false,
                onOtpChanged: (String value) {
                  otp = value;
                  setState(() {
                    isDisabled = value.length != 6;
                  });
                },
              ),

              const SizedBox(height: 20),

              CustomButton(
                onTap: () {
                  if (!isDisabled) {
                    FocusScope.of(context).unfocus();
                    _verifyEmail();
                  }
                },
                text: 'Verify Email',
                isDisabled: isDisabled,
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Did not receive code?',
                  style: theme.labelLarge!.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Send again in $_secondsRemaining seconds',
                        style: theme.labelSmall,
                      )
                    : GestureDetector(
                        onTap: _resendOTP,
                        child: const GradientBorderContainer(
                          borderWidth: 1,
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          borderRadius: 10000,
                          child: TextGradient(
                            text: 'Resend Code',
                            fontsize: 15,
                          ),
                        ),
                      ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }
}
