import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
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
        getVaultItems();
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

  // Future<void> logout() async {
  //   await LocalStorageService.
  //   user.value = null;
  //   items.clear();
  // }
}
