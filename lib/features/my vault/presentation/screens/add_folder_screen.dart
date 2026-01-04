import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
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
    final MyVaultController controller = Get.find<MyVaultController>();
    final TextEditingController nameCOntroller = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(text: 'Add Folder'),
        bottomNavigationBar: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: CustomButton(
            onTap: () async {
              if (formKey.currentState!.validate()) {
                await controller.addNewFolder(
                  name: nameCOntroller.text,
                  description: descriptionController.text,
                  parentId: null,
                );
                Get.back();
              }
            },
            text: 'Save',
          ),
        ),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 10,
              children: <Widget>[
                // Folder Name
                Form(
                  key: formKey,
                  child: CustomTextField(
                    controller: nameCOntroller,
                    title: 'Folder Name',
                    hintText: 'Enter Name',
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Folder name is required";
                      }
                      return null;
                    },
                  ),
                ),
                CustomTextField(
                  controller: descriptionController,
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
