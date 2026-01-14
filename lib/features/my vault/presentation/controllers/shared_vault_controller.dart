import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_filter_model.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class SharedVaultController extends GetxController {
  final MyVaultRepo _repo = MyVaultRepo();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<ItemModel> sharedItems = <ItemModel>[].obs;
  final Rxn<String> errorMessage = Rxn<String>();

  // Pagination
  Rxn<PaginationModel> pagination = Rxn<PaginationModel>();
  bool get hasMoreItems => pagination.value?.hasNextPage ?? false;
  int get currentPage => pagination.value?.page ?? 1;

  // Filter state
  final Rx<VaultFilter> filter = VaultFilter.defaultFilter().obs;
  bool get hasActiveFilters => !filter.value.isDefault;
  int get activeFilterCount => filter.value.activeFilterCount;

  @override
  void onInit() {
    super.onInit();
    getSharedItems();
  }

  /// Apply filter and refresh items
  Future<void> applyFilter(VaultFilter newFilter) async {
    filter.value = newFilter;
    pagination.value = null;
    await getSharedItems();
  }

  /// Reset filters to default
  Future<void> resetFilters() async {
    filter.value = VaultFilter.defaultFilter();
    pagination.value = null;
    await getSharedItems();
  }

  Future<void> getSharedItems({bool refresh = false}) async {
    if (!refresh) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final ApiResponse response = await _repo.getSharedItems(
        page: 1,
        filter: filter.value,
      );

      if (response.success) {
        // Support both old format (items only) and new format (items + pagination)
        final dynamic data = response.data;

        if (data is Map<String, dynamic>) {
          // Check if pagination exists (new format)
          if (data.containsKey('pagination')) {
            final ItemsResponseModel parsedData = ItemsResponseModel.fromJson(data);
            sharedItems.value = parsedData.items;
            pagination.value = parsedData.pagination;
          } else {
            // Old format - just items array
            final List<dynamic> itemsJson = data['items'] ?? <dynamic>[];
            sharedItems.value = itemsJson
                .map((dynamic item) => ItemModel.fromJson(item as Map<String, dynamic>))
                .toList();
            pagination.value = null;
          }
        }
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

  /// Load more items (infinite scroll)
  Future<void> loadMoreItems() async {
    if (isLoadingMore.value || !hasMoreItems) return;

    isLoadingMore.value = true;
    try {
      final int nextPage = currentPage + 1;
      final ApiResponse response = await _repo.getSharedItems(
        page: nextPage,
        filter: filter.value,
      );

      if (response.success) {
        final dynamic data = response.data;

        if (data is Map<String, dynamic> && data.containsKey('pagination')) {
          final ItemsResponseModel parsedData = ItemsResponseModel.fromJson(data);
          sharedItems.addAll(parsedData.items);
          pagination.value = parsedData.pagination;
        }
      }
    } catch (e) {
      debugPrint('Load more shared items error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refresh() async {
    pagination.value = null;
    await getSharedItems(refresh: true);
  }
}
