import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/confirm_pin_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<SetPinScreen> {
  bool isOtpFIlled = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // 🔥 KEY FIX
      body: Stack(
        children: <Widget>[
          /// MAIN CONTENT (Never moves)
          Padding(
            padding: AppSizes.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: Image.asset(AppImages.pinlock, height: h * 0.08)),
                Text('Set PIN', style: theme.labelLarge),
                Text(
                  'Create a 4-digit PIN to protect \nyour vault.',
                  textAlign: TextAlign.center,
                  style: theme.labelSmall,
                ),
                const SizedBox(height: 40),

                /// PIN INPUT
                OtpInput(
                  length: 4,
                  isOtpWrong: false,
                  onOtpChanged: (String value) {
                    setState(() {
                      isOtpFIlled = value.length == 4;
                    });
                  },
                ),
              ],
            ),
          ),

          /// FIXED BOTTOM BUTTON
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Padding(
              padding: AppSizes.horizontalPadding,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isOtpFIlled
                    ? CustomButton(
                        key: const ValueKey('verify_button'),
                        onTap: () {
                          Get.to(() => const ConfirmPinScreen());
                        },
                        text: 'Next',
                        isDisabled: false,
                      )
                    : const SizedBox(key: ValueKey('empty_space')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
