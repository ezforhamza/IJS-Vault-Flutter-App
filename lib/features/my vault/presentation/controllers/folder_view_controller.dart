import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_manager.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/file_confirmation_widget.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

/// =======================================================
/// Folder View Controller
/// =======================================================

class FolderViewController extends GetxController {
  final MyVaultRepo repo = MyVaultRepo();

  // State
  final RxBool showAddButton = true.obs;
  final RxBool isAddButtonTapped = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<ItemModel> items = <ItemModel>[].obs;

  // Context
  String? parentId;

  void init(String? id) {
    parentId = id;
    getVaultItems();
  }

  void toggleAddTap() {
    isAddButtonTapped.value = !isAddButtonTapped.value;
  }

  void closeMenu() {
    isAddButtonTapped.value = false;
  }

  // API Operations

  Future<void> getVaultItems({bool refresh = false}) async {
    if (parentId == null) return;

    if (!refresh) {
      isLoading.value = true;
    }
    try {
      final ApiResponse response = await repo.getVaultItems(parentId: parentId);

      if (response.success) {
        final ItemsResponseModel data = ItemsResponseModel.fromJson(
          response.data,
        );
        items.value = data.items;
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Error getting folder items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh folder items (for pull-to-refresh)
  Future<void> refresh() async {
    await getVaultItems(refresh: true);
  }

  Future<ItemModel?> addNewFolder({
    required String name,
    required String description,
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
        // getVaultItems(); // Refresh list
        final ItemModel newItem = ItemModel.fromJson(response.data['folder']);
        items.add(newItem);
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

  // Upload File
  Future<void> uploadFile(String filePath) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse response = await repo.uploadFileLessThan100Mb(
        filePath: filePath,
        parentId: parentId,
        description: 'Description',
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        getVaultItems();
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

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

  ////////////////////////////////////////////////////////////////////////////////File Upload/////////////////////////////////////////
  final ImagePicker _picker = ImagePicker();
  final RxBool isUploading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _setupUploadManager();
  }

  /// Setup upload manager callbacks for this folder
  void _setupUploadManager() {
    final UploadManager uploadManager = Get.find<UploadManager>();
    
    // When upload completes, add the item to the list if it belongs to this folder
    uploadManager.onUploadComplete = (ItemModel item) {
      // Only add if the item belongs to this folder
      if (item.parentId == parentId) {
        items.add(item);
      }
      AppToasts.showSuccessToast(message: '${item.name} uploaded successfully');
    };
    
    // When upload fails, show error
    uploadManager.onUploadError = (String taskId, String error) {
      debugPrint('Upload failed: $error');
    };
  }

  Future<void> pickAndConfirmUpload(
    BuildContext context,
    String parentId,
  ) async {
    // Pick multiple files
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    // Convert to File objects
    final List<File> files = result.files
        .where((PlatformFile f) => f.path != null)
        .map((PlatformFile f) => File(f.path!))
        .toList();

    if (files.isEmpty) return;

    // Show upload confirmation dialog with file info
    _showUploadConfirmationDialog(
      context: context,
      files: files,
      parentId: parentId,
    );
  }

  void _showUploadConfirmationDialog({
    required BuildContext context,
    required List<File> files,
    required String parentId,
  }) {
    Get.dialog(
      barrierColor: const Color(0xFF494a51).withValues(alpha: 0.4),
      UploadConfirmationDialog(
        files: files,
        onUpload: (List<File> filesToUpload) => uploadSelectedFiles(filesToUpload, parentId),
      ),
    );
  }

  /// Upload multiple files using the background upload manager (non-blocking)
  Future<void> uploadSelectedFiles(List<File> files, String parentId) async {
    // Close the confirmation dialog immediately
    Get.back();

    final UploadManager uploadManager = Get.find<UploadManager>();
    int successCount = 0;

    for (final File file in files) {
      try {
        // Get file info
        final String filename = file.path.split('/').last;
        final String? mimeType = lookupMimeType(file.path);
        final String contentType = mimeType ?? 'application/octet-stream';

        // Add to upload manager - await to ensure task is added to queue
        // The actual upload runs in background via unawaited
        await uploadManager.addUpload(
          file: file,
          filename: filename,
          contentType: contentType,
          parentId: parentId,
          description: 'Uploaded file',
        );
        successCount++;
      } catch (e) {
        debugPrint('Upload error for ${file.path}: $e');
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
  }
}
