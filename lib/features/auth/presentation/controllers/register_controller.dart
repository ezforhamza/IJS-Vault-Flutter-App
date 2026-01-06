import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:ijs_vault/features/auth/presentation/screens/registration_email_verification_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class RegisterController extends GetxController {
  final AuthRepository repository = AuthRepository();

  // Reactive state for profile picture and terms acceptance
  final Rx<File?> selectedProfilePicture = Rx<File?>(null);
  final RxBool termsAccepted = false.obs;

  // Store user ID after registration for pfp upload
  String? registeredUserId;

  /// Set profile picture
  void setProfilePicture(File? file) {
    selectedProfilePicture.value = file;
  }

  /// Toggle terms acceptance
  void toggleTermsAcceptance() {
    termsAccepted.value = !termsAccepted.value;
  }

  /// Register user with validation
  Future<void> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    // Validation: Profile picture must be selected
    if (selectedProfilePicture.value == null) {
      AppToasts.showErrorToast(message: 'Please select a profile picture');
      return;
    }

    // Validation: Terms must be accepted
    if (!termsAccepted.value) {
      AppToasts.showErrorToast(message: 'Please accept terms and conditions');
      return;
    }

    AppLoader.showLoadingDialog();

    try {
      // Step 1: Register user
      final ApiResponse res = await repository.register(
        fullname: fullname,
        email: email,
        password: password,
      );

      if (res.success) {
        // Extract user ID from response
        if (res.data != null && res.data['user'] != null) {
          registeredUserId = res.data['user']['id'];

          // Step 2: Upload profile picture
          if (registeredUserId != null &&
              selectedProfilePicture.value != null) {
            final ApiResponse pfpResponse = await repository
                .uploadProfilePicture(
                  userId: registeredUserId!,
                  filePath: selectedProfilePicture.value!,
                );

            if (!pfpResponse.success) {
              debugPrint(
                'Profile picture upload failed: ${pfpResponse.message}',
              );
              // Continue anyway, don't block registration
            }
          }
        }

        AppLoader.hideLoadingDialog();

        // Navigate to registration email verification screen
        Get.offAll(() => RegistrationEmailVerificationScreen(email: email));
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Registration error: $e');
      AppToasts.showErrorToast(
        message: 'Registration failed. Please try again.',
      );
    }
  }
}
