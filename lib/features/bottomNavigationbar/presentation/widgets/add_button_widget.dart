import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/add_folder_screen.dart';

class AddButtonWidget extends StatelessWidget {
  const AddButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MyVaultController controller = Get.find<MyVaultController>();
    final bool isDarkMode = Get.isDarkMode;

    return Obx(() {
      if (!controller.showAddButton.value) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: .min,
        crossAxisAlignment: .end,

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
                    : const Color(0xFFffffff),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                spacing: 10,
                mainAxisAlignment: .center,
                children: <Widget>[
                  // Add File
                  Row(
                    spacing: 5,
                    children: <Widget>[
                      SvgPicture.asset(AppImages.uploadfile, height: 18),
                      Text(
                        'Upload Files',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  //Add Folder
                  GestureDetector(
                    onTap: () {
                      // to aDD fOLDER sCREEN
                      controller.isAddButtonTapped.value = false;
                      Get.to(() => const AddFolderScreen());
                    },
                    child: Row(
                      spacing: 5,
                      children: <Widget>[
                        SvgPicture.asset(AppImages.selected1, height: 20),
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
          const SizedBox(height: 5),

          //Button
          GestureDetector(
            onTap: controller.toggleAddTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
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
