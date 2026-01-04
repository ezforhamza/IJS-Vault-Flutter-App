import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/folder_view_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/add_button.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

/// =======================================================
/// Add Button Widget (Folder Specific)
/// =======================================================

/// =======================================================
/// Folder View Screen
/// =======================================================

class FolderViewScreen extends StatelessWidget {
  const FolderViewScreen({super.key, required this.folderName});
  final String folderName;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    // Inject controller
    final FolderViewController controller = Get.put(FolderViewController());

    return Scaffold(
      appBar: CustomAppBar(text: folderName),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: AppSizes.horizontalPadding,
            child: Column(
              children: <Widget>[CustomSearchField(isDarkMode: isDarkMode)],
            ),
          ),

          // Buil Folder Items

          /// ---------------- Blur Sheet ----------------
          // Obx(() {
          //   final FolderViewController controller =
          //       Get.find<FolderViewController>();

          //   return controller.isAddButtonTapped.value
          //       ? Positioned.fill(
          //           child: GestureDetector(
          //             onTap: controller.closeMenu,
          //             child: BackdropFilter(
          //               filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          //               child: Container(
          //                 color: const Color(0xFF494b52).withOpacity(0.35),
          //               ),
          //             ),
          //           ),
          //         )
          //       : const SizedBox.shrink();
          // }),

          /// ---------------- Add Button ----------------
          Positioned(
            bottom: 40 + MediaQuery.of(context).padding.bottom,
            right: 20,
            child: const FolderAddButtonWidget(),
          ),
        ],
      ),
    );
  }
}
