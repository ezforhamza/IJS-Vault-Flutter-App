import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/data/models/linkable_user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/folder_view_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/set_pin_screen.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/custom_switch.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({
    super.key,
    this.item,
    this.parentId,
    this.isFolder = true,
  });

  final ItemModel? item;
  final String? parentId;
  final bool isFolder;

  bool get isEditMode => item != null;

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode searchFocusNode = FocusNode();

  final MyVaultController controller = Get.find<MyVaultController>();

  // Linked users list
  List<LinkedUserModel> linkedUsers = <LinkedUserModel>[];
  
  // PIN state
  bool isPinEnabled = false;
  bool hadPinBefore = false;
  
  // Search state
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.isEditMode && widget.item != null) {
      nameController.text = widget.item!.name;
      descriptionController.text = widget.item!.description;
      isPinEnabled = widget.item!.isLocked;
      hadPinBefore = widget.item!.isLocked;
      
      // Parse existing linked users
      for (final dynamic user in widget.item!.linkedUsers) {
        if (user is Map<String, dynamic>) {
          linkedUsers.add(LinkedUserModel.fromJson(user));
        }
      }
    }
  }

  String get _title {
    if (widget.isEditMode) {
      return widget.isFolder ? 'Edit Folder' : 'Edit File';
    }
    return 'Add Folder';
  }

  String get _nameLabel {
    return widget.isFolder ? 'Folder Name' : 'File Name';
  }

  void _onSearchChanged(String value) {
    if (value.trim().length >= 2) {
      controller.searchUsersForLinking(value);
      setState(() => isSearching = true);
    } else {
      controller.linkableUsers.clear();
      setState(() => isSearching = false);
    }
  }

  void _addUser(LinkableUser user) {
    // Check if user already added
    if (linkedUsers.any((LinkedUserModel u) => u.userId == user.id)) {
      AppToasts.showErrorToast(message: 'User already added');
      return;
    }

    setState(() {
      linkedUsers.add(LinkedUserModel(
        userId: user.id,
        fullName: user.fullName,
        email: user.email,
        image: user.image,
        role: 'view', // Default role
      ));
    });

    searchController.clear();
    controller.linkableUsers.clear();
    setState(() => isSearching = false);
  }

  void _removeUser(int index) {
    setState(() {
      linkedUsers.removeAt(index);
    });
  }

  void _updateUserRole(int index, String role) {
    setState(() {
      linkedUsers[index] = LinkedUserModel(
        userId: linkedUsers[index].userId,
        fullName: linkedUsers[index].fullName,
        email: linkedUsers[index].email,
        image: linkedUsers[index].image,
        role: role.toLowerCase(),
      );
    });
  }

  List<Map<String, String>> _getLinkedUsersPayload() {
    return linkedUsers
        .map((LinkedUserModel user) => <String, String>{
              'userId': user.userId,
              'role': user.role,
            })
        .toList();
  }

  /// Refresh the appropriate vault controller based on item's parentId
  void _refreshVaultData() {
    final String? parentId = widget.item?.parentId?.toString();
    
    if (parentId != null && parentId.isNotEmpty && parentId != 'null') {
      // Item is inside a subfolder - refresh the FolderViewController
      try {
        final FolderViewController folderController = Get.find<FolderViewController>(tag: parentId);
        folderController.getVaultItems(refresh: true);
      } catch (e) {
        // FolderViewController not found, refresh main vault
        controller.getVaultItems(refresh: true);
      }
    } else {
      // Item is at root level - refresh main vault
      controller.getVaultItems(refresh: true);
    }
  }

  Future<void> _saveItem() async {
    if (!formKey.currentState!.validate()) return;

    AppLoader.showLoadingDialog();
    try {
      if (widget.isEditMode) {
        // Update existing item
        final response = await controller.repo.updateItem(
          id: widget.item!.id,
          name: nameController.text,
          description: descriptionController.text,
          linkedUsers: _getLinkedUsersPayload(),
        );

        AppLoader.hideLoadingDialog();

        if (response.success) {
          // Handle PIN changes
          if (isPinEnabled && !hadPinBefore) {
            Get.off(() => SetPinScreen(itemId: widget.item!.id));
            return;
          } else if (!isPinEnabled && hadPinBefore) {
            // Remove PIN
            await controller.repo.removePin(itemId: widget.item!.id);
          }

          AppToasts.showSuccessToast(message: response.message);
          // Refresh the appropriate controller based on parentId
          _refreshVaultData();
          Get.back(result: true);
        } else {
          AppToasts.showErrorToast(message: response.message);
        }
      } else {
        // Create new folder
        final newItem = await controller.addNewFolder(
          name: nameController.text,
          description: descriptionController.text,
          parentId: widget.parentId,
          linkedUsers: _getLinkedUsersPayload(),
        );

        AppLoader.hideLoadingDialog();

        if (newItem != null) {
          if (isPinEnabled) {
            Get.off(() => SetPinScreen(itemId: newItem.id));
          } else {
            Get.back();
          }
        }
        return;
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      AppToasts.showErrorToast(message: 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(text: _title),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: CustomButton(
            onTap: _saveItem,
            text: widget.isEditMode ? 'Update' : 'Save',
          ),
        ),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                // Name Field
                Form(
                  key: formKey,
                  child: CustomTextField(
                    controller: nameController,
                    title: _nameLabel,
                    hintText: 'Enter Name',
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "$_nameLabel is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Description Field
                CustomTextField(
                  controller: descriptionController,
                  title: 'Description (optional)',
                  hintText: 'Write Description...',
                  minLines: 4,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                // Linked Users Section Header
                Text(
                  'Linked Users (optional)',
                  style: theme.labelMedium!.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Search User Field - Full Width Modern Design
                _buildUserSearchField(isDarkMode),
                const SizedBox(height: 12),

                // Search Results
                if (isSearching)
                  Obx(() {
                    if (controller.linkableUsers.isNotEmpty) {
                      return _buildSearchResults(isDarkMode);
                    }
                    if (controller.isSearchingUsers.value) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF20222b)
                              : const Color(0xFFfdfbf5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                // Added Users List with Role Selection
                if (linkedUsers.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      Text(
                        'Added Users',
                        style: theme.labelMedium!.copyWith(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        linkedUsers.length,
                        (int index) => _buildLinkedUserTile(
                          linkedUsers[index],
                          index,
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
                // PIN Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          SvgPicture.asset(AppImages.lock2, height: 25),
                          const SizedBox(width: 8),
                          Flexible(
                            child: TextGradient(
                              text: widget.isEditMode
                                  ? (hadPinBefore ? 'PIN Protected' : 'Set Pin (optional)')
                                  : 'Set Pin (optional)',
                              fontWeight: FontWeight.w500,
                              fontsize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                if (widget.isEditMode && hadPinBefore && !isPinEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'PIN will be removed when you save',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSearchField(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : const Color(0xFFfdfbf5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: _onSearchChanged,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search users by name or email...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : const Color(0xFFa4a4a4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white54 : Colors.grey,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                  onPressed: () {
                    searchController.clear();
                    controller.linkableUsers.clear();
                    setState(() => isSearching = false);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDarkMode) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.linkableUsers.length,
        itemBuilder: (BuildContext context, int index) {
          final LinkableUser user = controller.linkableUsers[index];
          final bool alreadyAdded =
              linkedUsers.any((LinkedUserModel u) => u.userId == user.id);

          return InkWell(
            onTap: alreadyAdded ? null : () => _addUser(user),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: index < controller.linkableUsers.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        user.image != null ? NetworkImage(user.image!) : null,
                    backgroundColor: AppColors.gradient[0].withValues(alpha: 0.2),
                    child: user.image == null
                        ? Text(
                            user.fullName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.gradient[0],
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.fullName,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alreadyAdded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Added',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.gradient[0],
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkedUserTile(
    LinkedUserModel user,
    int index,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : const Color(0xFFfdfbf5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundImage:
                user.image != null ? NetworkImage(user.image!) : null,
            backgroundColor: AppColors.gradient[0].withValues(alpha: 0.2),
            child: user.image == null
                ? Text(
                    user.fullName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.gradient[0],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.fullName,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Role Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black26 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: user.role.toLowerCase() == 'edit' ? 'Edit' : 'View',
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
                dropdownColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                items: <String>['View', 'Edit'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _updateUserRole(index, newValue);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Remove Button
          GestureDetector(
            onTap: () => _removeUser(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}

// Model for linked users with role
class LinkedUserModel {
  final String userId;
  final String fullName;
  final String email;
  final String? image;
  final String role;

  LinkedUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.image,
    required this.role,
  });

  factory LinkedUserModel.fromJson(Map<String, dynamic> json) {
    // Handle different formats of userId
    String id = '';
    String name = '';
    String email = '';
    String? image;
    String role = 'view';

    if (json['userId'] is Map) {
      final userMap = json['userId'] as Map<String, dynamic>;
      id = userMap['id'] ?? '';
      name = userMap['fullName'] ?? userMap['name'] ?? '';
      email = userMap['email'] ?? '';
      image = userMap['image'];
    } else {
      id = json['userId']?.toString() ?? '';
      name = json['fullName'] ?? json['name'] ?? '';
      email = json['email'] ?? '';
      image = json['image'];
    }

    role = json['role']?.toString().toLowerCase() ?? 'view';

    return LinkedUserModel(
      userId: id,
      fullName: name,
      email: email,
      image: image,
      role: role,
    );
  }
}
