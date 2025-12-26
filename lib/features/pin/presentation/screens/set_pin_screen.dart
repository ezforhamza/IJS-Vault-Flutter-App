import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/widgets/otp_field.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<SetPinScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final h = ScreenHelper.height(context);

    return Scaffold(
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: .center,
          children: [
            /// HEADER
            Center(child: Image.asset(AppImages.pinlock, height: h * 0.08)),
            Text('Set PIN', style: theme.labelLarge),
            Text(
              textAlign: TextAlign.center,
              'Create a 4-digit PIN to protect \nyour vault.',
              style: theme.labelSmall,
            ),
            SizedBox(height: 5),

            /// PIN INPUT
            const OtpInput(length: 4),

            /// VERIFY BUTTON
            // CustomButton(
            //   onTap: () {
            //     Get.to(() => const ResetPasswordScreen());
            //   },
            //   text: 'Verify',
            //   isDisabled: true,
            // ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
          ],
        ),
      ),
    );
  }
}
