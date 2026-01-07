import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class SharedVaultController extends GetxController {
  final MyVaultRepo _repo = MyVaultRepo();

  // State
  final RxBool isLoading = false.obs;
  final RxList<ItemModel> sharedItems = <ItemModel>[].obs;
  final Rxn<String> errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    getSharedItems();
  }

  Future<void> getSharedItems() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final ApiResponse response = await _repo.getSharedItems();

      if (response.success) {
        final List<dynamic> itemsJson = response.data['items'] ?? <dynamic>[];
        sharedItems.value = itemsJson
            .map((dynamic item) => ItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      debugPrint('Get shared items error: $e');
      errorMessage.value = 'Failed to load shared items';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await getSharedItems();
  }
}
