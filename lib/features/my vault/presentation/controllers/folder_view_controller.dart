import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

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
}
