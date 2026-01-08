import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';

/// =======================================================
/// Add Button Widget (Folder Specific)
/// =======================================================

/// =======================================================
/// Folder View Screen
/// =======================================================

import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/folder_view_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/edit_item_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/add_button.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/move_item_dialog.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/my_vault_widget.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/dialoge.dart';
import 'package:ijs_vault/shared/helpers/dialog_helper.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class FolderViewScreen extends StatelessWidget {
  const FolderViewScreen({super.key, required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    // Inject controller
    final FolderViewController controller = Get.put(
      FolderViewController(),
      tag: item.id,
    );
    if (controller.parentId != item.id) {
      controller.init(item.id);
    }

    return Scaffold(
      appBar: CustomAppBar(text: item.name),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: AppSizes.horizontalPadding,
            child: Column(
              spacing: 10,
              children: <Widget>[
                CustomSearchField(isDarkMode: isDarkMode),
                // Build Folder Items
                Expanded(
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.98,
                                  end: 1,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: controller.isLoading.value
                          ? const GridShimmer(keyy: 'shimmer')
                          : controller.items.isEmpty
                          ? Center(
                              key: const ValueKey('empty'),
                              child: Text(
                                textAlign: TextAlign.center,
                                'No sub-categories yet\nStart organizing your vault by adding sub-categories.',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: controller.refresh,
                              child: LayoutBuilder(
                                builder: (BuildContext context, BoxConstraints constraints) {
                                  final double width = constraints.maxWidth;
                                  final double itemWidth =
                                      (width - 20) / 3; // 10 spacing * 2
                                  final double itemHeight = itemWidth * 1.25;
                                  final double ratio = itemWidth / itemHeight;

                                  return GridView.builder(
                                    // key: const ValueKey('grid'),
                                    padding: const EdgeInsets.only(bottom: 80),
                                    itemCount: controller.items.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: ratio < 0.7
                                              ? 0.7
                                              : ratio,
                                        ),
                                    itemBuilder: (_, int index) {
                                      final ItemModel subItem =
                                          controller.items[index];
                                      return VaultItem(
                                        type: subItem.type == 'folder'
                                            ? VaultItemType.folder
                                            : (subItem.fileType == 'media' ? VaultItemType.media : VaultItemType.document),
                                        item: subItem,
                                        onEdit: () {
                                          Get.to(() => EditItemScreen(
                                            item: subItem,
                                            isFolder: subItem.type == 'folder',
                                          ));
                                        },
                                        onMove: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => MoveItemDialog(
                                              itemToMove: subItem,
                                              initialParentId: null, // Root
                                              onMove: (String? newParentId) {
                                                controller.moveItem(
                                                  subItem.id,
                                                  newParentId ?? '',
                                                  index,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        onDelete: () {
                                          DialogHelper.showAnimatedDialog(
                                            context: context,
                                            child: Center(
                                              child: ConfirmationDialogue(
                                                onTap: () async {
                                                  await controller.deleteItem(
                                                    subItem.id,
                                                    index,
                                                  );
                                                  Get.back();
                                                },
                                                h: ScreenHelper.height(context),
                                                theme: Theme.of(
                                                  context,
                                                ).textTheme,
                                                title: 'Delete Item?',
                                                subtitle:
                                                    'Do you really want to delete ${subItem.name}',
                                                image: AppImages.delete,
                                                buttonText: 'Delete',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ---------------- Add Button ----------------
          Positioned(
            bottom: 40 + MediaQuery.of(context).padding.bottom,
            right: 20,
            child: FolderAddButtonWidget(parentId: item.id),
          ),
        ],
      ),
    );
  }
}
