import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/folder_view_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';
import 'package:intl/intl.dart';

class LinkedUserSharedItemsScreen extends StatefulWidget {
  const LinkedUserSharedItemsScreen({super.key, required this.user});
  final LinkedUserModel user;

  @override
  State<LinkedUserSharedItemsScreen> createState() =>
      _LinkedUserSharedItemsScreenState();
}

class _LinkedUserSharedItemsScreenState
    extends State<LinkedUserSharedItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MyVaultRepo _repo = MyVaultRepo();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppBar(text: 'Shared Items'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            // User Info Header
            _buildUserHeader(isDarkMode, textTheme),
            const SizedBox(height: 20),
            // Tab Bar
            _buildTabBar(isDarkMode),
            const SizedBox(height: 16),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  _buildFoldersList(isDarkMode, textTheme),
                  _buildFilesList(isDarkMode, textTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(bool isDarkMode, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          ProfilePictureWidget(radius: 28, imageUrl: widget.user.image),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.user.fullName,
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.email,
                  style: textTheme.labelSmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    _buildStatChip(
                      'Folders',
                      widget.user.sharedItems.folders.length.toString(),
                      Icons.folder_outlined,
                      isDarkMode,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      'Files',
                      widget.user.sharedItems.files.length.toString(),
                      Icons.insert_drive_file_outlined,
                      isDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.gradient),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              widget.user.primaryRole.capitalizeFirst!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 14,
          color: isDarkMode ? Colors.white54 : Colors.black54,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF494a51) : const Color(0xFFf4f4f4),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        splashBorderRadius: BorderRadius.circular(AppSizes.borderRadius),
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.gradient),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        tabs: const <Widget>[
          Tab(text: 'Folders'),
          Tab(text: 'Files'),
        ],
      ),
    );
  }

  Widget _buildFoldersList(bool isDarkMode, TextTheme textTheme) {
    final List<SharedFolderModel> folders = widget.user.sharedItems.folders;

    if (folders.isEmpty) {
      return _buildEmptyState(
        'No Shared Folders',
        'No folders have been shared with this user yet.',
        Icons.folder_off_outlined,
        textTheme,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: folders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final SharedFolderModel folder = folders[index];
        return _SharedFolderTile(
          folder: folder,
          isDarkMode: isDarkMode,
          onTap: () => _navigateToVaultItem(folder.id, 'folder'),
          onUnlink: () => _showUnlinkConfirmation(folder.id, folder.name, 'folder'),
        );
      },
    );
  }

  Widget _buildFilesList(bool isDarkMode, TextTheme textTheme) {
    final List<SharedFileModel> files = widget.user.sharedItems.files;

    if (files.isEmpty) {
      return _buildEmptyState(
        'No Shared Files',
        'No files have been shared with this user yet.',
        Icons.insert_drive_file_outlined,
        textTheme,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final SharedFileModel file = files[index];
        return _SharedFileTile(
          file: file,
          isDarkMode: isDarkMode,
          onTap: () => _navigateToVaultItem(file.id, 'file'),
          onUnlink: () => _showUnlinkConfirmation(file.id, file.name, 'file'),
        );
      },
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 64,
            color: Get.isDarkMode ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToVaultItem(String itemId, String type) async {
    // For folders, navigate directly
    if (type == 'folder') {
      await _openItem(itemId, type);
      return;
    }

    // For files, show options bottom sheet
    _showFileOptionsBottomSheet(itemId);
  }

  void _showFileOptionsBottomSheet(String itemId) {
    final bool isDarkMode = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.folder_open,
              title: 'View in Folder',
              subtitle: 'Navigate to the folder containing this file',
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                _navigateToParentFolder(itemId);
              },
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.visibility,
              title: 'Preview File',
              subtitle: 'Open file preview and download options',
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                _openItem(itemId, 'file');
              },
            ),
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToParentFolder(String itemId) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse response = await _repo.getItemById(itemId: itemId);

      if (response.success) {
        final ItemModel item = ItemModel.fromJson(response.data['item'] ?? response.data);
        AppLoader.hideLoadingDialog();

        // Get the parent folder ID from the item
        final String? parentId = item.parentId?.toString();

        if (parentId != null && parentId.isNotEmpty) {
          // Fetch the parent folder details
          final ApiResponse parentResponse = await _repo.getItemById(itemId: parentId);

          if (parentResponse.success) {
            final ItemModel parentFolder = ItemModel.fromJson(
              parentResponse.data['item'] ?? parentResponse.data,
            );

            if (parentFolder.isLocked) {
              Get.to(
                () => VerifyPinScreen(
                  itemId: parentFolder.id,
                  onSuccess: () {
                    Get.off(() => FolderViewScreen(item: parentFolder));
                  },
                ),
              );
            } else {
              Get.to(() => FolderViewScreen(item: parentFolder));
            }
          } else {
            AppToasts.showErrorToast(message: 'Failed to load parent folder');
          }
        } else {
          // File is in root, navigate to vault home
          AppToasts.showSuccessToast(message: 'File is in root folder');
          Get.back(); // Go back to previous screen
        }
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error navigating to parent folder: $e');
      AppToasts.showErrorToast(message: 'Failed to load folder');
    }
  }

  Future<void> _openItem(String itemId, String type) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse response = await _repo.getItemById(itemId: itemId);

      if (response.success) {
        // API returns {data: {item: {...}}} so we need to access the nested item
        final ItemModel item = ItemModel.fromJson(response.data['item'] ?? response.data);
        AppLoader.hideLoadingDialog();

        if (item.isLocked) {
          Get.to(
            () => VerifyPinScreen(
              itemId: item.id,
              onSuccess: () {
                if (type == 'folder') {
                  Get.off(() => FolderViewScreen(item: item));
                } else {
                  Get.off(() => ItemPreviewScreen(item: item));
                }
              },
            ),
          );
        } else {
          if (type == 'folder') {
            Get.to(() => FolderViewScreen(item: item));
          } else {
            Get.to(() => ItemPreviewScreen(item: item));
          }
        }
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error navigating to vault item: $e');
      AppToasts.showErrorToast(message: 'Failed to load item');
    }
  }

  void _showUnlinkConfirmation(String itemId, String itemName, String type) {
    final bool isDarkMode = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Access',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${widget.user.fullName}\'s access to "$itemName"?',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _unlinkUser(itemId, itemName, type);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlinkUser(String itemId, String itemName, String type) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse response = await _repo.unshareItem(
        itemId: itemId,
        userId: widget.user.userId,
      );

      AppLoader.hideLoadingDialog();

      if (response.success) {
        AppToasts.showSuccessToast(
          message: '${widget.user.fullName}\'s access to "$itemName" has been removed',
        );
        // Go back to refresh the linked users list
        Get.back();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error unlinking user: $e');
      AppToasts.showErrorToast(message: 'Failed to remove access');
    }
  }
}

class _SharedFolderTile extends StatelessWidget {
  const _SharedFolderTile({
    required this.folder,
    required this.isDarkMode,
    required this.onTap,
    required this.onUnlink,
  });

  final SharedFolderModel folder;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onUnlink;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onUnlink,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.black12,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.folder,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    folder.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (folder.parentName != null)
                    Text(
                      'In: ${folder.parentName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      _buildRoleBadge(folder.role),
                      if (folder.sharedAt != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(folder.sharedAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: role == 'edit'
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.capitalizeFirst!,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: role == 'edit' ? Colors.green : Colors.blue,
        ),
      ),
    );
  }
}

class _SharedFileTile extends StatelessWidget {
  const _SharedFileTile({
    required this.file,
    required this.isDarkMode,
    required this.onTap,
    required this.onUnlink,
  });

  final SharedFileModel file;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onUnlink;

  IconData _getFileIcon() {
    switch (file.fileType ?? 'document') {
      case 'media':
        return Icons.image_outlined;
      case 'document':
        return Icons.description_outlined;
      case 'note':
        return Icons.note_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileColor() {
    switch (file.fileType ?? 'document') {
      case 'media':
        return Colors.purple;
      case 'document':
        return Colors.red;
      case 'note':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onUnlink,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.black12,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getFileColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getFileIcon(),
                color: _getFileColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (file.parentName != null)
                    Text(
                      'In: ${file.parentName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      _buildRoleBadge(file.role),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getFileColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (file.fileType ?? 'document').capitalizeFirst!,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getFileColor(),
                          ),
                        ),
                      ),
                      if (file.sharedAt != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(file.sharedAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: role == 'edit'
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.capitalizeFirst!,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: role == 'edit' ? Colors.green : Colors.blue,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2a2a2a) : const Color(0xFFf5f5f5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
