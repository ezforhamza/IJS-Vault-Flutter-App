import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/folder_view_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/edit_item_screen.dart';

class FolderAddButtonWidget extends StatelessWidget {
  const FolderAddButtonWidget({super.key, required this.parentId});
  final String parentId;

  @override
  Widget build(BuildContext context) {
    final FolderViewController controller = Get.find<FolderViewController>(
      tag: parentId,
    );
    final bool isDarkMode = Get.isDarkMode;

    return Obx(() {
      if (!controller.showAddButton.value) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          // Menu
          if (controller.isAddButtonTapped.value)
            Container(
              height: 80,
              width: 160,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.scaffoldBackgroundColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const <BoxShadow>[
                  BoxShadow(blurRadius: 8, color: Colors.black26),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Upload Files
                  GestureDetector(
                    onTap: () {
                      controller.closeMenu();
                      // Use the modern upload flow with UploadManager
                      controller.pickAndConfirmUpload(context, parentId);
                    },
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(AppImages.uploadfile, height: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Upload Files',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add Sub Folder
                  GestureDetector(
                    onTap: () {
                      controller.closeMenu();
                      Get.to(() => EditItemScreen(parentId: parentId, isFolder: true));
                    },
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(AppImages.selected1, height: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Add Folder',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Floating Button
          GestureDetector(
            onTap: controller.toggleAddTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: SvgPicture.asset(
                controller.isAddButtonTapped.value
                    ? AppImages.cancel
                    : AppImages.add,
                key: ValueKey(controller.isAddButtonTapped.value),
              ),
            ),
          ),
        ],
      );
    });
  }
}
