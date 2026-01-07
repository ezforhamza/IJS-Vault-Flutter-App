import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/shared_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/shared_folder_view_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';
import 'package:shimmer/shimmer.dart';

class SharedWithMe extends StatefulWidget {
  const SharedWithMe({super.key});

  @override
  State<SharedWithMe> createState() => _SharedWithMeState();
}

class _SharedWithMeState extends State<SharedWithMe> {
  late SharedVaultController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SharedVaultController());
  }

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
          child: controller.isLoading.value
              ? const _GridShimmer(keyy: 'SharedShimmer')
              : controller.errorMessage.value != null
              ? _buildErrorState(textTheme)
              : _buildGrid(textTheme, const ValueKey<String>('sharedGrid')),
        ),
      ),
    );
  }

  Widget _buildGrid(TextTheme textTheme, ValueKey<String> key) {
    if (controller.sharedItems.isEmpty) {
      return _buildEmptyState(textTheme);
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double itemWidth = (width - 40) / 3;
          final double itemHeight = itemWidth * 1.25;
          final double ratio = itemWidth / itemHeight;

          return GridView.builder(
            key: key,
            padding: const EdgeInsets.all(10),
            itemCount: controller.sharedItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: ratio < 0.7 ? 0.7 : ratio,
            ),
            itemBuilder: (_, int index) {
              final ItemModel item = controller.sharedItems[index];
              return _SharedVaultItem(item: item);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.folder_shared_outlined,
            size: 64,
            color: Get.isDarkMode ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No Shared Items Yet\n'
            'Items shared with you will\n'
            'appear here.',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SharedVaultItem extends StatelessWidget {
  const _SharedVaultItem({required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return VaultItem(
      type: item.type == 'folder'
          ? VaultItemType.folder
          : item.fileType == 'media'
          ? VaultItemType.media
          : VaultItemType.document,
      item: item,
      isSharedItem: true,
      onTap: () => _handleTap(),
      onMove: null,
      onDelete: null,
      onEdit: null,
    );
  }

  void _handleTap() {
    if (item.type == 'folder') {
      if (item.isLocked) {
        Get.to(
          () => VerifyPinScreen(
            itemId: item.id,
            onSuccess: () {
              Get.off(() => SharedFolderViewScreen(item: item));
            },
          ),
        );
      } else {
        Get.to(() => SharedFolderViewScreen(item: item));
      }
    } else {
      if (item.isLocked) {
        Get.to(
          () => VerifyPinScreen(
            itemId: item.id,
            onSuccess: () {
              Get.off(() => ItemPreviewScreen(item: item));
            },
          ),
        );
      } else {
        Get.to(() => ItemPreviewScreen(item: item));
      }
    }
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer({required this.keyy});
  final String keyy;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Shimmer.fromColors(
      key: ValueKey<String>(keyy),
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
