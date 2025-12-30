import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/features/set%20pin/presentation/widgets/success_dialogue_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class ConfirmPinScreen extends StatefulWidget {
  const ConfirmPinScreen({super.key});

  @override
  State<ConfirmPinScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<ConfirmPinScreen> {
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
                Text('Confirm Your PIN', style: theme.labelLarge),
                Text(
                  'Re-enter your PIN to make\n sure it’s correct.',
                  textAlign: TextAlign.center,
                  style: theme.labelSmall,
                ),
                const SizedBox(height: 40),

                /// PIN INPUT
                OtpInput(
                  length: 4,
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
                        onTap: () async {
                          // Navigator.pop(context);

                          // await Future.delayed(const Duration(seconds: 5));
                          // SHow SUccess DIalogue
                          // Get.dialog(SuccessDialogue(h: h, theme: theme));
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierLabel: 'Success',
                            barrierColor: Colors.black.withOpacity(0.4),
                            transitionDuration: const Duration(
                              milliseconds: 350,
                            ),
                            pageBuilder:
                                (
                                  BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation,
                                ) {
                                  return Center(
                                    child: SuccessDialogue(
                                      h: ScreenHelper.height(context),
                                      theme: Theme.of(context).textTheme,
                                    ),
                                  );
                                },
                            transitionBuilder:
                                (
                                  BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation,
                                  Widget child,
                                ) {
                                  final CurvedAnimation curvedAnimation =
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      );

                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: curvedAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                          );
                        },
                        text: 'Save',
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
