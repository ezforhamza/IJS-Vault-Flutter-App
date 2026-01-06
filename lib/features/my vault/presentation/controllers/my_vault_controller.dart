import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/core/services/resumeable_upload_service.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/linkable_user_model.dart';
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
  Future<void> addNewFolder({
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
        Get.back();
        // getVaultItems();
        final ItemModel newItem = ItemModel.fromJson(response.data['folder']);
        items.add(newItem);

        // Link users if provided
        if (linkedUsers != null && linkedUsers.isNotEmpty) {
          await repo.linkSelectedUsers(itemId: newItem.id, users: linkedUsers);
        }
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Add folder error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  /// Fetch vault items
  Future<void> getVaultItems({bool refresh = false}) async {
    isGettingVault.value = true;
    try {
      final ApiResponse response = await repo.getVaultItems(
        // page: pagination.value?.page ?? 1,
      );

      if (response.success) {
        final ItemsResponseModel data = ItemsResponseModel.fromJson(
          response.data,
        );

        items.value = data.items;
        // pagination.value = data.pagination;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Get vault items error: $e');
    } finally {
      isGettingVault.value = false;
    }
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

  Future<void> pickAndConfirmUpload(BuildContext context) async {
    // Pick any file
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // allows any file type
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final File file = File(result.files.first.path!);

    // Show your upload confirmation dialog
    _showUploadConfirmationDialog(context: context, file: file);
  }

  void _showUploadConfirmationDialog({
    required BuildContext context,
    required File file,
  }) {
    Get.dialog(
      barrierColor: const Color(0xFF494a51).withValues(alpha: 0.4),
      UploadConfirmationDialog(
        file: file,
        onTap: () {
          return uploadSelectedFile(file);
        },
        isUploading: isUploading,
      ),
    );
  }

  Future<void> uploadSelectedFile(File file) async {
    const int fileSizeThreshold = 100 * 1024 * 1024; // 100MB in bytes

    try {
      isUploading.value = true;

      // Get file size
      final int fileSize = await file.length();
      final String filename = file.path.split('/').last;

      // Check file size and route to appropriate upload method
      if (fileSize > fileSizeThreshold) {
        // Use resumable upload for files > 100MB
        await _uploadLargeFile(file, filename, fileSize);
      } else {
        // Use standard upload for files <= 100MB
        await _uploadSmallFile(file);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isUploading.value = false;
      AppLoader.hideLoadingDialog();
    }
  }

  /// Upload small files (<= 100MB) using standard method
  Future<void> _uploadSmallFile(File file) async {
    AppLoader.showLoadingDialog();

    final ApiResponse response = await repo.uploadFileLessThan100Mb(
      filePath: file.path,
      description: 'Uploaded from gallery',
      parentId: null, // pass folder id if needed
    );

    if (response.success) {
      AppToasts.showSuccessToast(message: response.message);
      final ItemModel newItem = ItemModel.fromJson(response.data['item']);
      items.add(newItem);
    } else {
      AppToasts.showErrorToast(message: response.message);
    }
  }

  /// Upload large files (> 100MB) using resumable upload service
  Future<void> _uploadLargeFile(
    File file,
    String filename,
    int fileSize,
  ) async {
    AppLoader.showLoadingDialog();

    try {
      // Get access token
      final String? token = await LocalStorageService.getAccessToken();
      if (token == null) {
        AppToasts.showErrorToast(message: 'Authentication required');
        return;
      }

      // Determine content type
      final String? mimeType = lookupMimeType(file.path);
      final String contentType = mimeType ?? 'application/octet-stream';

      // Initialize resumable upload service
      final ResumableUploadService uploadService = ResumableUploadService();

      // Upload file
      final bool success = await uploadService.uploadFile(
        file: file,
        filename: filename,
        contentType: contentType,
        parentId: '', // pass folder id if needed
        token: token,
        concurrentUploads: 3, // parallel uploads
      );

      if (success) {
        AppToasts.showSuccessToast(message: 'File uploaded successfully');
        // Refresh vault items to show the new file
        await getVaultItems();
      } else {
        AppToasts.showErrorToast(message: 'Upload failed');
      }
    } catch (e) {
      debugPrint('Large file upload error: $e');
      AppToasts.showErrorToast(message: 'Failed to upload large file');
    }
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
