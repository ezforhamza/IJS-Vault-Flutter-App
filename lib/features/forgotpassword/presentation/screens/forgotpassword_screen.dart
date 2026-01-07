import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/utils/input_validators.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/controllers/forgot_password_controller.dart';
import 'package:ijs_vault/shared/helpers/key_board_helper.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  bool isButtonDisabled = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController.new();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final double h = ScreenHelper.height(context);
    final ForgotPasswordController controller = Get.put(
      ForgotPasswordController(),
    );

    return Scaffold(
      appBar: const CustomAppBar(text: ''),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            // mainAxisAlignment: .start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // SizedBox(height: MediaQuery.paddingOf(context).top + 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      AppImages.forgotpassword,
                      height: h * 0.2,
                    ),
                  ),
                  const SizedBox(height: 50),

                  Text('Forgot Password', style: theme.labelLarge),
                  Text(
                    'We will send a code to your registered email address.',
                    style: theme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Text Field
              Form(
                key: formKey,
                child: CustomTextField(
                  controller: emailController,
                  onChanged: (String value) {
                    setState(() {
                      isButtonDisabled =
                          !(formKey.currentState?.validate() ?? false);
                    });
                  },
                  title: 'Email Address',
                  hintText: "Enter Email Address",
                  validator: InputValidators.email,
                  prefixIcon: SvgPicture.asset(
                    AppImages.email,
                    color: const Color.fromARGB(255, 178, 178, 178),
                  ),
                ),
              ),

              // Forgot Password

              // Button
              CustomButton(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    KeyboardHelper.closeKeyboard(context);
                    controller.sendOTP(email: emailController.text.trim());
                  }
                },
                text: 'Send',
                isDisabled: isButtonDisabled,
              ),
              const SizedBox(height: 20),

              SizedBox(height: MediaQuery.paddingOf(context).bottom + 5),
            ],
          ),
        ),
      ),
    );
  }
}
