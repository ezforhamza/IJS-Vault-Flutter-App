import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/settings/data/repository/change_profile_repo.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ChangeProfileController extends GetxController {
  final ChangeProfileRepo _repository = ChangeProfileRepo();

  final RxString fullName = ''.obs;
  final RxString phone = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  UserModel? currentUser;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final ProfileController profileController = Get.find<ProfileController>();
    currentUser = profileController.currentUser.value;
    if (currentUser != null) {
      fullName.value = currentUser!.fullName;
      phone.value = '';
    }
  }

  /// 🔹 Set profile image
  void setProfilePicture(File? file) {
    selectedImage.value = file;
  }

  /// 🔹 Update profile (image + name/phone)
  Future<void> updateProfile({String? newFullName, String? newPhone}) async {
    if (currentUser == null) {
      AppToasts.showErrorToast(message: 'User not found. Please login again.');
      return;
    }

    final bool hasImage = selectedImage.value != null;
    final bool hasName = newFullName != null && newFullName.trim().isNotEmpty;
    final bool hasPhone = newPhone != null && newPhone.trim().isNotEmpty;

    /// Validation
    if ((hasName && !hasPhone) || (!hasName && hasPhone)) {
      AppToasts.showErrorToast(
        message: 'Full name and phone must be updated together',
      );
      return;
    }

    if (!hasImage && !hasName && !hasPhone) {
      AppToasts.showErrorToast(message: 'No changes to update');
      return;
    }

    AppLoader.showLoadingDialog();

    try {
      /// 🔹 1. Upload profile picture
      if (hasImage) {
        final ApiResponse imageResponse = await _repository
            .uploadProfilePicture(
              userId: currentUser!.id,
              filePath: selectedImage.value!,
            );

        if (!imageResponse.success) {
          AppLoader.hideLoadingDialog();
          AppToasts.showErrorToast(message: imageResponse.message);

          return;
        }
        final UserModel user = UserModel.fromJson(imageResponse.data['user']);

        Get.find<ProfileController>().updateUser(user);
      }

      /// 🔹 2. Update name + phone
      if (hasName && hasPhone) {
        final ApiResponse infoResponse = await _repository.updateUserInfo(
          // userId: currentUser!.id,
          fullName: newFullName.trim(),
          phone: newPhone.trim(),
        );

        if (!infoResponse.success) {
          AppLoader.hideLoadingDialog();
          AppToasts.showErrorToast(message: infoResponse.message);
          return;
        }

        // await _updateLocalUserData(newFullName, newPhone);
        final UserModel user = UserModel.fromJson(infoResponse.data['user']);

        Get.find<ProfileController>().updateUser(user);
      }

      /// Success
      selectedImage.value = null;
      AppLoader.hideLoadingDialog();
      AppToasts.showSuccessToast(message: 'Profile updated successfully');
      Get.back();
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Update profile error: $e');
      AppToasts.showErrorToast(message: 'Failed to update profile');
    }
  }

  /// 🔹 Update local user data via ProfileController
  //   Future<void> _updateLocalUserData(String newFullName, String newPhone) async {
  //     if (currentUser == null) return;

  //     final UserModel updatedUser = UserModel(
  //       id: currentUser!.id,
  //       fullName: newFullName,
  //       email: currentUser!.email,
  //       role: currentUser!.role,
  //       isEmailVerified: currentUser!.isEmailVerified,
  //       provider: currentUser!.provider,
  //       notificationPreferences: currentUser!.notificationPreferences,
  //       subscription: currentUser!.subscription,
  //       billingHistory: currentUser!.billingHistory,
  //     );

  //     // Update via ProfileController
  //     final ProfileController profileController = Get.find<ProfileController>();
  //     await profileController.updateUser(updatedUser);

  //     currentUser = updatedUser;
  //     fullName.value = newFullName;
  //     phone.value = newPhone;
  //   }
  // }
}
