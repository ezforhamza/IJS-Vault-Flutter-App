import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_manager.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/linkable_user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_filter_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/file_confirmation_widget.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class MyVaultController extends GetxController {
  // UI state
  RxBool isAddButtonTapped = false.obs;
  RxBool showAddButton = true.obs;
  RxBool isLoading = false.obs;
  RxBool isGettingVault = false.obs;
  RxBool isLoadingMore = false.obs;

  // User
  Rxn<UserModel> user = Rxn<UserModel>();

  // Vault items
  RxList<ItemModel> items = <ItemModel>[].obs;
  Rxn<PaginationModel> pagination = Rxn<PaginationModel>();

  // Linkable users
  RxList<LinkableUser> linkableUsers = <LinkableUser>[].obs;
  RxBool isSearchingUsers = false.obs;

  // Repository
  final MyVaultRepo repo = MyVaultRepo();

  // Pagination helpers
  bool get hasMoreItems => pagination.value?.hasNextPage ?? false;
  int get currentPage => pagination.value?.page ?? 1;

  // Filter state
  final Rx<VaultFilter> filter = VaultFilter.defaultFilter().obs;
  bool get hasActiveFilters => !filter.value.isDefault;
  int get activeFilterCount => filter.value.activeFilterCount;

  /// Apply filter and refresh items
  Future<void> applyFilter(VaultFilter newFilter) async {
    filter.value = newFilter;
    pagination.value = null;
    await getVaultItems();
  }

  /// Update a single filter property
  void updateFilter({
    VaultItemType? type,
    VaultFileType? fileType,
    VaultSortBy? sortBy,
    VaultSortOrder? sortOrder,
  }) {
    filter.value = filter.value.copyWith(
      type: type,
      fileType: fileType,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Reset filters to default
  Future<void> resetFilters() async {
    filter.value = VaultFilter.defaultFilter();
    pagination.value = null;
    await getVaultItems();
  }

  // Local storage

  @override
  void onInit() async {
    super.onInit();

    _loadUser();

    // getVaultItems();
  }

  /* -------------------------------------------------------------------------- */
  /*                               Local Storage                                */
  /* -------------------------------------------------------------------------- */

  void _loadUser() async {
    final UserModel? savedUser = await LocalStorageService.getUser();
    if (savedUser != null) {
      user.value = savedUser;
    }
  }

  void toggleAddTap() {
    isAddButtonTapped.value = !isAddButtonTapped.value;
  }

  /* -------------------------------------------------------------------------- */
  /*                              Vault Operations                               */
  /* -------------------------------------------------------------------------- */

  /// Create new folder
  Future<ItemModel?> addNewFolder({
    required String name,
    required String description,
    String? parentId,
    List<Map<String, String>>? linkedUsers,
  }) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.createNewFolder(
        name: name,
        description: description,
        parentId: parentId,
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        // getVaultItems();
        final ItemModel newItem = ItemModel.fromJson(response.data['folder']);
        items.add(newItem);

        // Link users if provided
        if (linkedUsers != null && linkedUsers.isNotEmpty) {
          await repo.linkSelectedUsers(itemId: newItem.id, users: linkedUsers);
        }
        return newItem;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Add folder error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
    return null;
  }

  /// Set Item PIN
  Future<bool> setItemPin({required String itemId, required String pin}) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.setItemPin(
        itemId: itemId,
        pin: pin,
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        return true;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Set PIN error: $e');
      AppToasts.showErrorToast(message: 'Failed to set PIN');
    } finally {
      AppLoader.hideLoadingDialog();
    }
    return false;
  }

  /// Verify Item PIN
  Future<bool> verifyItemPin({
    required String itemId,
    required String pin,
  }) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.verifyItemPin(
        itemId: itemId,
        pin: pin,
      );

      if (response.success) {
        return true;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Verify PIN error: $e');
      AppToasts.showErrorToast(message: 'Failed to verify PIN');
    } finally {
      AppLoader.hideLoadingDialog();
    }
    return false;
  }

  /// Verify Item PIN with full response (for new PIN screen)
  Future<ApiResponse> verifyItemPinWithResponse({
    required String itemId,
    required String pin,
  }) async {
    try {
      final ApiResponse response = await repo.verifyItemPin(
        itemId: itemId,
        pin: pin,
      );
      return response;
    } catch (e) {
      debugPrint('Verify PIN error: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to verify PIN',
      );
    }
  }

  /// Fetch vault items (first page)
  Future<void> getVaultItems({bool refresh = false}) async {
    if (!refresh) {
      isGettingVault.value = true;
    }
    try {
      final ApiResponse response = await repo.getVaultItems(
        page: 1,
        filter: filter.value,
      );

      if (response.success) {
        final ItemsResponseModel data = ItemsResponseModel.fromJson(
          response.data,
        );

        items.value = data.items;
        pagination.value = data.pagination;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Get vault items error: $e');
    } finally {
      isGettingVault.value = false;
    }
  }

  /// Load more items (infinite scroll)
  Future<void> loadMoreItems() async {
    if (isLoadingMore.value || !hasMoreItems) return;

    isLoadingMore.value = true;
    try {
      final int nextPage = currentPage + 1;
      final ApiResponse response = await repo.getVaultItems(
        page: nextPage,
        filter: filter.value,
      );

      if (response.success) {
        final ItemsResponseModel data = ItemsResponseModel.fromJson(
          response.data,
        );

        items.addAll(data.items);
        pagination.value = data.pagination;
      }
    } catch (e) {
      debugPrint('Load more items error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh vault items (for pull-to-refresh)
  Future<void> refresh() async {
    pagination.value = null;
    await getVaultItems(refresh: true);
  }

  /* -------------------------------------------------------------------------- */
  /*                                   Logout                                   */
  /* -------------------------------------------------------------------------- */

  // Rename Item
  Future<void> renameItem(String id, String newName) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.renameItem(
        id: id,
        newName: newName,
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        getVaultItems();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Rename error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // Move Item
  Future<void> moveItem(String id, String newParentId, int index) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.moveItem(
        id: id,
        newParentId: newParentId,
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        // getVaultItems();
        items.removeAt(index);
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Move error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
      Get.back();
    }
  }

  // Delete Item
  Future<void> deleteItem(String id, int index) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.deleteItem(id: id);

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        // getVaultItems();
        items.removeAt(index);
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // Future<void> logout() async {
  //   await LocalStorageService.
  //   user.value = null;
  //   items.clear();
  // }

  ////////////////////////////////////////////////////////////////////////////////File Upload/////////////////////////////////////////
  final ImagePicker _picker = ImagePicker();
  final RxBool isUploading = false.obs;
  final RxBool isLoadingFiles = false.obs; // Loading state for file picker
  final RxList<File> selectedFiles = <File>[].obs; // Selected files for upload

  @override
  void onReady() {
    super.onReady();
    _setupUploadManager();
  }

  /// Setup upload manager callbacks
  void _setupUploadManager() {
    final UploadManager uploadManager = Get.find<UploadManager>();
    
    // When upload completes, add the item to the list
    uploadManager.onUploadComplete = (ItemModel item) {
      items.add(item);
      AppToasts.showSuccessToast(message: '${item.name} uploaded successfully');
    };
    
    // When upload fails, show error
    uploadManager.onUploadError = (String taskId, String error) {
      debugPrint('Upload failed: $error');
    };
  }

  Future<void> pickAndConfirmUpload(BuildContext context) async {
    // Show loading indicator while picking files
    isLoadingFiles.value = true;
    
    try {
      // Pick multiple files
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true, // Allow multiple file selection
      );

      if (result == null || result.files.isEmpty) {
        isLoadingFiles.value = false;
        return;
      }

      // Convert to File objects
      final List<File> files = result.files
          .where((PlatformFile f) => f.path != null)
          .map((PlatformFile f) => File(f.path!))
          .toList();

      if (files.isEmpty) {
        isLoadingFiles.value = false;
        return;
      }

      isLoadingFiles.value = false;
      selectedFiles.value = files;

      // Show upload confirmation dialog with file info
      _showUploadConfirmationDialog(context: context, files: files);
    } catch (e) {
      isLoadingFiles.value = false;
      debugPrint('File picker error: $e');
      AppToasts.showErrorToast(message: 'Failed to select files');
    }
  }

  void _showUploadConfirmationDialog({
    required BuildContext context,
    required List<File> files,
  }) {
    Get.dialog(
      barrierColor: const Color(0xFF494a51).withValues(alpha: 0.4),
      UploadConfirmationDialog(
        files: files,
        onUpload: uploadSelectedFiles,
        onRemoveFile: (int index) {
          selectedFiles.removeAt(index);
          if (selectedFiles.isEmpty) {
            Get.back();
          }
        },
      ),
    );
  }

  /// Upload multiple files using the background upload manager (non-blocking)
  /// Note: Dialog closes itself before calling this
  Future<void> uploadSelectedFiles(List<File> files) async {
    final UploadManager uploadManager = Get.find<UploadManager>();
    int successCount = 0;

    debugPrint('📤 MyVaultController: Starting upload of ${files.length} files');

    for (final File file in files) {
      try {
        // Get file info
        final String filename = file.path.split('/').last;
        final String? mimeType = lookupMimeType(file.path);
        final String contentType = mimeType ?? 'application/octet-stream';

        debugPrint('📤 MyVaultController: Adding file $filename to upload queue');

        // Add to upload manager - await to ensure task is added to queue
        // The actual upload runs in background via unawaited
        await uploadManager.addUpload(
          file: file,
          filename: filename,
          contentType: contentType,
          parentId: null, // pass folder id if needed
          description: 'Uploaded file',
        );
        successCount++;
        debugPrint('📤 MyVaultController: File $filename added to queue');
      } catch (e) {
        debugPrint('❌ Upload error for ${file.path}: $e');
      }
    }

    // Show toast
    if (successCount > 0) {
      AppToasts.showSuccessToast(
        message: successCount == 1
            ? 'Upload started'
            : '$successCount uploads started',
      );
    }
    
    selectedFiles.clear();
    debugPrint('📤 MyVaultController: Upload queue complete. $successCount files queued.');
  }

  /* -------------------------------------------------------------------------- */
  /*                            User Linking Search                             */
  /* -------------------------------------------------------------------------- */

  /// Search users for linking
  Future<void> searchUsersForLinking(String query) async {
    if (query.trim().isEmpty) {
      linkableUsers.clear();
      return;
    }

    isSearchingUsers.value = true;

    try {
      final ApiResponse response = await repo.getUsersForLinking(query: query);

      if (response.success) {
        final LinkableUsersResponse data = LinkableUsersResponse.fromJson(
          response.data,
        );
        linkableUsers.value = data.users;
      } else {
        linkableUsers.clear();
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Search users error: $e');
      linkableUsers.clear();
    } finally {
      isSearchingUsers.value = false;
    }
  }
}
