import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/file_confirmation_widget.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> getVaultItems() async {
    if (parentId == null) return;

    isLoading.value = true;
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

  Future<void> addNewFolder({
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
        Get.back(); // Close dialog
        // getVaultItems(); // Refresh list
        final ItemModel newItem = ItemModel.fromJson(response.data['folder']);
        items.add(newItem);
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Add folder error: $e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
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

  Future<void> pickAndConfirmUpload(
    BuildContext context,
    String parentId,
  ) async {
    // Pick any file
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // allows any file type
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final File file = File(result.files.first.path!);

    // Show your upload confirmation dialog
    _showUploadConfirmationDialog(
      context: context,
      file: file,
      parentId: parentId,
    );
  }

  void _showUploadConfirmationDialog({
    required BuildContext context,
    required File file,
    required String parentId,
  }) {
    Get.dialog(
      barrierColor: const Color(0xFF494a51).withValues(alpha: 0.4),
      UploadConfirmationDialog(
        file: file,
        onTap: () {
          return uploadSelectedFile(file, parentId);
        },
        isUploading: isUploading,
      ),
    );
  }

  Future<void> uploadSelectedFile(File file, String parentId) async {
    AppLoader.showLoadingDialog();
    try {
      isUploading.value = true;

      final ApiResponse response = await repo.uploadFileLessThan100Mb(
        filePath: file.path,
        description: 'Uploaded from gallery',
        parentId: parentId, // pass folder id if needed
      );

      if (response.success) {
        AppToasts.showSuccessToast(message: response.message);
        final ItemModel newItem = ItemModel.fromJson(response.data['item']);
        items.add(newItem);
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isUploading.value = false;
      AppLoader.hideLoadingDialog();
    }
  }
}
