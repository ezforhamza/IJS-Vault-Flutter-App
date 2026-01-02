import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/dropdown_menu_widget.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/custom_switch.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class AddFolderScreen extends StatelessWidget {
  const AddFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(text: 'Add Folder'),
        bottomNavigationBar: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: CustomButton(onTap: () {}, text: 'Save'),
        ),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 10,
              children: <Widget>[
                // Folder Name
                const CustomTextField(
                  title: 'Folder Name',
                  hintText: 'Enter Name',
                ),
                const CustomTextField(
                  title: 'Description (optional)',
                  hintText: 'Write Description...',
                  minLines: 5,
                  maxLines: 5,
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: <Widget>[
                    Text(
                      'Linked Users (optional)',
                      style: theme.labelMedium!.copyWith(fontSize: 14),
                    ),
                    Row(
                      children: <Widget>[
                        // Icoon
                        SvgPicture.asset(AppImages.plusicon),
                        const TextGradient(
                          text: 'Add More',
                          fontsize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 8),
                // Add Linked Users
                const Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[CustomTextFieldWithDropdown()],
                ),
                const SizedBox(height: 8),
                //
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: <Widget>[
                    // Row
                    Row(
                      spacing: 5,
                      children: <Widget>[
                        SvgPicture.asset(AppImages.lock2, height: 25),
                        const TextGradient(
                          text: 'Set Pin (optional)',
                          fontWeight: FontWeight.w500,
                          fontsize: 16,
                        ),
                      ],
                    ),
                    //
                    const CustomSwitch(),
                  ],
                ),
              ],
            ),

            //
          ),
        ),
      ),
    );
  }
}
