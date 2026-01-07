import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/linked_users/data/repository/linked_users_repo.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class LinkedUsersController extends GetxController {
  final LinkedUsersRepo _repository = LinkedUsersRepo();

  // Reactive state
  final RxBool isLoading = false.obs;
  final Rxn<LinkedUsersDataModel> linkedUsersData = Rxn<LinkedUsersDataModel>();
  final RxList<LinkedUserModel> users = <LinkedUserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getLinkedUsers(showLoader: false);
  }

  Future<void> getLinkedUsers({bool showLoader = true, bool refresh = false}) async {
    if (showLoader && !refresh) {
      isLoading.value = true;
    }
    try {
      final ApiResponse response = await _repository.getLinkedUsers();

      if (response.success) {
        final LinkedUsersDataModel responseModel =
            LinkedUsersDataModel.fromJson(response.data);
        // linkedUsersData.value = responseModel.;
        users.assignAll(responseModel.users);
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Error fetching linked users: $e');
      AppToasts.showErrorToast(message: 'Failed to fetch linked users');
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  /// Refresh linked users (for pull-to-refresh)
  Future<void> refresh() async {
    await getLinkedUsers(showLoader: false, refresh: true);
  }

  // Helper getters
  int get totalLinkedUsers =>
      linkedUsersData.value?.summary.totalLinkedUsers ?? 0;
  int get totalSharedItems =>
      linkedUsersData.value?.summary.totalSharedItems ?? 0;
}
