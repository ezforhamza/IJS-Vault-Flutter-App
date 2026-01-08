import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/edit_item_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/move_item_dialog.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/dialoge.dart';
import 'package:ijs_vault/shared/helpers/dialog_helper.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:shimmer/shimmer.dart';

class MyVault extends StatefulWidget {
  const MyVault({super.key});

  @override
  State<MyVault> createState() => _MyVaultState();
}

class _MyVaultState extends State<MyVault> {
  final MyVaultController controller = Get.find<MyVaultController>();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: controller.isGettingVault.value
              ? const GridShimmer(keyy: 'Shimmer')
              : _buildGrid(textTheme, const ValueKey('grid'), controller),
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                   GRID                                     */
  /* -------------------------------------------------------------------------- */

  Widget _buildGrid(
    TextTheme textTheme,
    ValueKey key,
    MyVaultController controller,
  ) {
    if (controller.items.isEmpty) {
      return _buildEmptyText(textTheme);
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          // Calculate childAspectRatio to keep items professional
          final double itemWidth =
              (width - 40) / 3; // 10 padding * 2 + 10 spacing * 2
          final double itemHeight = itemWidth * 1.25; // Base height ratio
          final double ratio = itemWidth / itemHeight;

          return GridView.builder(
            key: key,
            padding: const EdgeInsets.all(10),
            itemCount: controller.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: ratio < 0.7 ? 0.7 : ratio,
            ),
            itemBuilder: (_, int index) {
              final ItemModel item = controller.items[index];
              return VaultItem(
                type: item.type == 'folder'
                    ? VaultItemType.folder
                    : (item.fileType == 'media'
                          ? VaultItemType.media
                          : VaultItemType.document),
                item: item,
                onEdit: () {
                  Get.to(
                    () => EditItemScreen(
                      item: item,
                      isFolder: item.type == 'folder',
                    ),
                  );
                },
                onMove: () {
                  DialogHelper.showAnimatedDialog(
                    context: context,
                    child: MoveItemDialog(
                      itemToMove: item,
                      initialParentId: null, // Root
                      onMove: (String? newParentId) {
                        controller.moveItem(item.id, newParentId ?? '', index);
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
                          await controller.deleteItem(item.id, index);
                          Get.back();
                        },
                        h: ScreenHelper.height(context),
                        theme: Theme.of(context).textTheme,
                        title: 'Delte Item?',
                        subtitle: 'Do you really want to delete ${item.name}',
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
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                               EMPTY STATE                                  */
  /* -------------------------------------------------------------------------- */

  Widget _buildEmptyText(TextTheme textTheme) {
    return Center(
      child: Text(
        'No Folder & File Yet\n'
        'Start by creating your first folder to\n'
        'organize your vault.',
        textAlign: TextAlign.center,
        style: textTheme.labelSmall,
      ),
    );
  }
}

class GridShimmer extends StatelessWidget {
  const GridShimmer({super.key, required this.keyy});

  final String keyy;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return GridView.builder(
      key: ValueKey(keyy),
      padding: const EdgeInsets.all(10),
      itemCount: 9, // shimmer placeholders
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDarkMode
              ? Colors.grey.shade700
              : Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
