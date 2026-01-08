import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/shared_folder_view_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';

class SharedWithLinkedUserGrid extends StatelessWidget {
  const SharedWithLinkedUserGrid({super.key, required this.user});
  final LinkedUserModel user;

  @override
  Widget build(BuildContext context) {
    final List<ItemModel> allItems = _mapToItemModels();

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_shared_outlined,
              size: 64,
              color: Get.isDarkMode ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No items shared by ${user.fullName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double itemWidth = (width - 40) / 3;
        final double itemHeight = itemWidth * 1.25;
        final double ratio = itemWidth / itemHeight;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: allItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: ratio < 0.7 ? 0.7 : ratio,
          ),
          itemBuilder: (BuildContext context, int index) {
            final ItemModel item = allItems[index];
            return VaultItem(
              item: item,
              type: item.type == 'folder'
                  ? VaultItemType.folder
                  : (item.fileType == 'media'
                        ? VaultItemType.media
                        : (item.fileType == 'note'
                              ? VaultItemType.secureNote
                              : VaultItemType.document)),
              isSharedItem: true,
              onTap: () => _handleItemTap(item),
            );
          },
        );
      },
    );
  }

  List<ItemModel> _mapToItemModels() {
    final List<ItemModel> items = <ItemModel>[];

    // Add Folders
    for (final SharedFolderModel folder in user.sharedItems.folders) {
      items.add(
        ItemModel(
          id: folder.id,
          name: folder.name,
          description: '',
          type: 'folder',
          parentId: folder.parentId,
          isLocked: false, // Defaulting to false as it's not in the JSON
          owner: OwnerModel(
            id: user.id,
            fullName: user.fullName,
            email: user.email,
          ),
          linkedUsers: <dynamic>[],
          createdAt: folder.sharedAt?.toIso8601String() ?? '',
          updatedAt: folder.sharedAt?.toIso8601String() ?? '',
          breadcrumb: BreadcrumbModel(
            path: <BreadcrumbPathModel>[],
            pathString: '',
          ),
          fileType: '',
        ),
      );
    }

    // Add Files
    for (final SharedFileModel file in user.sharedItems.files) {
      items.add(
        ItemModel(
          id: file.id,
          name: file.name,
          description: '',
          type: 'file',
          parentId: file.parentId,
          isLocked: false, // Defaulting to false
          owner: OwnerModel(
            id: user.id,
            fullName: user.fullName,
            email: user.email,
          ),
          linkedUsers: <dynamic>[],
          createdAt: file.sharedAt?.toIso8601String() ?? '',
          updatedAt: file.sharedAt?.toIso8601String() ?? '',
          breadcrumb: BreadcrumbModel(
            path: <BreadcrumbPathModel>[],
            pathString: '',
          ),
          fileType: file.fileType ?? 'document',
        ),
      );
    }

    return items;
  }

  void _handleItemTap(ItemModel item) {
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
