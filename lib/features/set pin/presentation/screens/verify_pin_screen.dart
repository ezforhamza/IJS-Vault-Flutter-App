import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class VerifyPinScreen extends StatefulWidget {
  const VerifyPinScreen({
    super.key,
    required this.itemId,
    required this.onSuccess,
  });

  final String itemId;
  final VoidCallback onSuccess;

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  bool isOtpFIlled = false;
  String enteredPin = '';
  final MyVaultController controller = Get.find<MyVaultController>();

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(text: ''),

      body: Stack(
        children: <Widget>[
          /// MAIN CONTENT
          Padding(
            padding: AppSizes.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: Image.asset(AppImages.pinlock, height: h * 0.08)),
                Text('Verify PIN', style: theme.labelLarge),
                Text(
                  'Enter your 4-digit PIN to access \nthis item.',
                  textAlign: TextAlign.center,
                  style: theme.labelSmall,
                ),
                const SizedBox(height: 40),

                /// PIN INPUT
                OtpInput(
                  length: 4,
                  onOtpChanged: (String value) {
                    setState(() {
                      enteredPin = value;
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
                          final bool success = await controller.verifyItemPin(
                            itemId: widget.itemId,
                            pin: enteredPin,
                          );

                          if (success) {
                            Get.back(); // Close PIN screen
                            widget.onSuccess();
                          }
                        },
                        text: 'Verify',
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
