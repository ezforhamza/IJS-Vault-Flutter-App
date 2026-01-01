import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/controllers/verify_otp_controller.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/shared/helpers/key_board_helper.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/gradient_border_container.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const int _initialSeconds = 45;
  bool isDisabled = true;
  int _secondsRemaining = _initialSeconds;
  Timer? _timer;

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
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);
    final VerifyOtpController controller = Get.put(VerifyOtpController());

    return Scaffold(
      appBar: const CustomAppBar(text: ''),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// HEADER
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(AppImages.verifycode, height: h * 0.2),
                  ),
                  const SizedBox(height: 50),
                  Text('Verify Code', style: theme.labelLarge),
                  RichText(
                    text: TextSpan(
                      style: theme.labelSmall,
                      children: <InlineSpan>[
                        const TextSpan(text: 'We have sent a code to '),
                        TextSpan(
                          text: widget.email,
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
                ],
              ),

              const SizedBox(height: 10),

              /// OTP INPUT
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Enter Code',
                    style: theme.labelMedium!.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  OtpInput(
                    isOtpWrong: false,
                    onOtpChanged: (String value) {
                      if (value.length == 6) {
                        isDisabled = false;
                      } else {
                        isDisabled = true;
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),

              /// VERIFY BUTTON
              CustomButton(
                onTap: () {
                  if (!isDisabled) {
                    KeyboardHelper.closeKeyboard(context);
                    controller.verifycode();
                  }
                },
                text: 'Verify',
                isDisabled: isDisabled,
              ),

              // const SizedBox(height: 10),

              /// RESEND TEXT
              Center(
                child: Text(
                  'Did not receive code?',
                  style: theme.labelLarge!.copyWith(fontSize: 14),
                ),
              ),

              /// TIMER / RESEND BUTTON
              if (_secondsRemaining > 0)
                Center(
                  child: Text(
                    'Send again in $_secondsRemaining seconds',
                    style: theme.labelSmall,
                  ),
                )
              else
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _startTimer();
                      // TODO: Call resend OTP API here
                    },
                    child: const GradientBorderContainer(
                      borderWidth: 1,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      borderRadius: 10000,
                      child: TextGradient(text: 'Resend Code', fontsize: 15),
                    ),
                  ),
                ),

              SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
            ],
          ),
        ),
      ),
    );
  }
}
