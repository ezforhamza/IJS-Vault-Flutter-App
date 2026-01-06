import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/change_password_controller.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/gradient_border_container.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class ChangePasswordOtpScreen extends StatefulWidget {
  const ChangePasswordOtpScreen({super.key, required this.oldPassword});
  final String oldPassword;

  @override
  State<ChangePasswordOtpScreen> createState() =>
      _ChangePasswordOtpScreenState();
}

class _ChangePasswordOtpScreenState extends State<ChangePasswordOtpScreen> {
  static const int _initialSeconds = 45;
  bool isDisabled = true;
  int _secondsRemaining = _initialSeconds;
  Timer? _timer;
  String otp = '';

  final ChangePasswordController controller =
      Get.find<ChangePasswordController>();

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

  void resendOTP() async {
    AppLoader.showLoadingDialog();
    final AuthRepository repository = AuthRepository();
    final ApiResponse response = await repository.sendPasswordChangeOtp(
      currentPassword: widget.oldPassword,
    );
    AppLoader.hideLoadingDialog();

    if (response.success) {
      AppToasts.showSuccessToast(message: response.message);
    }

    // For resend, we would need the old password again
    // For now, just restart the timer
    _startTimer();
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

              /// HEADER IMAGE
              Center(child: Image.asset(AppImages.verifycode, height: h * 0.2)),
              const SizedBox(height: 30),

              Text('Verify Code', style: theme.labelLarge),
              Text(
                'We have sent a code to your email',
                style: theme.labelSmall,
              ),

              const SizedBox(height: 20),

              /// OTP Input
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

              /// VERIFY BUTTON
              CustomButton(
                onTap: () {
                  if (!isDisabled) {
                    FocusScope.of(context).unfocus();
                    controller.verifyAndChangePassword(otp: otp);
                  }
                },
                text: 'Verify',
                isDisabled: isDisabled,
              ),

              const SizedBox(height: 20),

              /// RESEND TEXT / TIMER
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
                        onTap: resendOTP,
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
