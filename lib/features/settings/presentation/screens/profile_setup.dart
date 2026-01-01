import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/auth/presentation/widgets/pfp_selection_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'Profile Setup'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            //
            const Center(child: PfpSelectionWidget()),
            const SizedBox(height: 30),

            CustomTextField(
              title: 'Full Name',
              hintText: 'Enter Full Name',
              prefixIcon: SvgPicture.asset(
                AppImages.profile,
                color: const Color(0xFFB2B2B2),
              ),
            ),
            CustomTextField(
              title: 'Email Address',
              hintText: 'Enter Email Address',
              prefixIcon: SvgPicture.asset(
                AppImages.email,
                color: const Color(0xFFB2B2B2),
              ),
            ),
            CustomTextField(
              title: 'Phone Number',
              hintText: 'Enter Phone Nmber',
              prefixIcon: SvgPicture.asset(
                AppImages.phone,

                color: const Color(0xFFB2B2B2),
              ),
            ),
            const Spacer(),
            CustomButton(onTap: () {}, text: 'Update'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
