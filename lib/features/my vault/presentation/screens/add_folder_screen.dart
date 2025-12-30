import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/dropdown_menu_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class AddFolderScreen extends StatelessWidget {
  const AddFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);
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
                Text(
                  'Linked Users (optional)',
                  style: theme.labelMedium!.copyWith(fontSize: 14),
                ),
                // const SizedBox(height: 8),
                // Add Linked Users
                const Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTextFieldWithDropdown(),
                    CustomTextFieldWithDropdown(),

                    CustomTextFieldWithDropdown(),
                    CustomTextFieldWithDropdown(),
                    CustomTextFieldWithDropdown(),

                    CustomTextFieldWithDropdown(),
                    CustomTextFieldWithDropdown(),
                    CustomTextFieldWithDropdown(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
