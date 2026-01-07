import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/linkable_user_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

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
        // AppToasts.showSuccessToast(message: response.message);
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
