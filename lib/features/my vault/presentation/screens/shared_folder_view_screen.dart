import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:shimmer/shimmer.dart';

class SharedFolderViewScreen extends StatefulWidget {
  const SharedFolderViewScreen({super.key, required this.item});
  final ItemModel item;

  @override
  State<SharedFolderViewScreen> createState() => _SharedFolderViewScreenState();
}

class _SharedFolderViewScreenState extends State<SharedFolderViewScreen> {
  final MyVaultRepo _repo = MyVaultRepo();
  final RxBool isLoading = true.obs;
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final Rxn<String> errorMessage = Rxn<String>();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final ApiResponse response = await _repo.getSharedFolderItems(
        folderId: widget.item.id,
      );

      if (response.success) {
        final List<dynamic> itemsJson = response.data['items'] ?? <dynamic>[];
        items.value = itemsJson
            .map(
              (dynamic item) =>
                  ItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      debugPrint('Get shared folder items error: $e');
      errorMessage.value = 'Failed to load folder contents';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(text: widget.item.name),
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
          child: isLoading.value
              ? const _GridShimmer(keyy: 'SharedFolderShimmer')
              : errorMessage.value != null
              ? _buildErrorState(textTheme)
              : _buildGrid(textTheme),
        ),
      ),
    );
  }

  Widget _buildGrid(TextTheme textTheme) {
    if (items.isEmpty) {
      return _buildEmptyState(textTheme);
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double itemWidth = (width - 40) / 3;
          final double itemHeight = itemWidth * 1.25;
          final double ratio = itemWidth / itemHeight;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: ratio < 0.7 ? 0.7 : ratio,
            ),
            itemBuilder: (_, int index) {
              final ItemModel item = items[index];
              return _SharedFolderItem(
                item: item,
                onTap: () => _handleItemTap(item),
              );
            },
          );
        },
      ),
    );
  }

  void _handleItemTap(ItemModel item) {
    debugPrint(
      '📂 SharedFolderView: Tapped item: ${item.name}, type: ${item.type}, isLocked: ${item.isLocked}',
    );

    if (item.type == 'folder') {
      if (item.isLocked) {
        debugPrint(
          '📂 SharedFolderView: Opening locked folder with PIN verification',
        );
        Get.to(
          () => VerifyPinScreen(
            itemId: item.id,
            onSuccess: () {
              Get.off(() => SharedFolderViewScreen(item: item));
            },
          ),
          preventDuplicates: false,
        );
      } else {
        debugPrint(
          '📂 SharedFolderView: Opening unlocked folder - calling Get.to()',
        );
        Get.to(
          () => SharedFolderViewScreen(item: item),
          preventDuplicates: false,
        );
        debugPrint('📂 SharedFolderView: Get.to() called successfully');
      }
    } else {
      if (item.isLocked) {
        debugPrint(
          '📂 SharedFolderView: Opening locked file with PIN verification',
        );
        Get.to(
          () => VerifyPinScreen(
            itemId: item.id,
            onSuccess: () {
              Get.off(() => ItemPreviewScreen(item: item));
            },
          ),
          preventDuplicates: false,
        );
      } else {
        debugPrint('📂 SharedFolderView: Opening unlocked file');
        Get.to(() => ItemPreviewScreen(item: item), preventDuplicates: false);
      }
    }
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Get.isDarkMode ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'This folder is empty',
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
            errorMessage.value ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadItems,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SharedFolderItem extends StatelessWidget {
  const _SharedFolderItem({required this.item, required this.onTap});
  final ItemModel item;
  final VoidCallback onTap;

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
      onTap: onTap,
      onMove: null,
      onDelete: null,
      onEdit: null,
    );
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
