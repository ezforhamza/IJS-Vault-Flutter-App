import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/folder_view_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/dropdown_menu_widget.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/set_pin_screen.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/custom_switch.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class AddFolderScreen extends StatefulWidget {
  const AddFolderScreen({super.key, this.parentId});
  final String? parentId;

  @override
  State<AddFolderScreen> createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // List to hold user dropdown widgets (max 5)
  final List<GlobalKey> userFieldKeys = <GlobalKey<State<StatefulWidget>>>[];
  int userFieldCount = 1;
  static const int maxUserFields = 5;
  bool isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize with one user field
    userFieldKeys.add(GlobalKey());
  }

  void _addUserField() {
    if (userFieldCount < maxUserFields) {
      setState(() {
        userFieldKeys.add(GlobalKey());
        userFieldCount++;
      });
    }
  }

  void _removeUserField(int index) {
    if (userFieldCount > 1) {
      setState(() {
        userFieldKeys.removeAt(index);
        userFieldCount--;
      });
    }
  }

  List<Map<String, String>> _getSelectedUsers() {
    final List<Map<String, String>> users = <Map<String, String>>[];
    for (final GlobalKey<State<StatefulWidget>> key in userFieldKeys) {
      final dynamic state = key.currentState;
      if (state != null) {
        try {
          final String? userId = state.selectedUserId as String?;
          final String access = state.selectedAccess as String;
          if (userId != null && access != 'Select Access') {
            users.add(<String, String>{
              'userId': userId,
              'role': access.toLowerCase(),
            });
          }
        } catch (e) {
          // Skip if state doesn't have the expected properties
        }
      }
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final MyVaultController controller = Get.find<MyVaultController>();

    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(text: 'Add Folder'),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: CustomButton(
            onTap: () async {
              if (formKey.currentState!.validate()) {
                final List<Map<String, String>> linkedUsers =
                    _getSelectedUsers();

                ItemModel? newItem;

                if (widget.parentId != null) {
                  final FolderViewController folderController =
                      Get.find<FolderViewController>(tag: widget.parentId);
                  newItem = await folderController.addNewFolder(
                    name: nameController.text,
                    description: descriptionController.text,
                  );
                } else {
                  newItem = await controller.addNewFolder(
                    name: nameController.text,
                    description: descriptionController.text,
                    parentId: widget.parentId,
                    linkedUsers: linkedUsers,
                  );
                }

                if (newItem != null) {
                  if (isPinEnabled) {
                    Get.off(() => SetPinScreen(itemId: newItem!.id));
                  } else {
                    Get.back();
                  }
                }
              }
            },
            text: 'Save',
          ),
        ),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: <Widget>[
                // Folder Name
                Form(
                  key: formKey,
                  child: CustomTextField(
                    controller: nameController,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Linked Users (optional)',
                      style: theme.labelMedium!.copyWith(fontSize: 14),
                    ),
                    if (userFieldCount < maxUserFields)
                      GestureDetector(
                        onTap: _addUserField,
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset(AppImages.plusicon),
                            const TextGradient(
                              text: 'Add More',
                              fontsize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // Add Linked Users
                Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    userFieldCount,
                    (int index) => Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomTextFieldWithDropdown(
                            key: userFieldKeys[index],
                          ),
                        ),
                        if (userFieldCount > 1)
                          // IconButton(
                          //   onPressed: () => _removeUserField(index),
                          //   icon: const Icon(
                          //     Icons.delete_outline,
                          //     color: Colors.red,
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: () {
                              _removeUserField(index);
                            },
                            child: SvgPicture.asset(
                              AppImages.delete,
                              height: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    CustomSwitch(
                      value: isPinEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          isPinEnabled = value;
                        });
                      },
                    ),
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
