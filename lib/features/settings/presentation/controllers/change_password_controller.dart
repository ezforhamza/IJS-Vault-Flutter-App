import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:ijs_vault/features/settings/presentation/screens/change_password_otp_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  // Reactive variable to store the new password temporarily
  final RxString tempNewPassword = ''.obs;

  // Step 1: Send OTP using Old Password
  Future<void> changePasswordRequest({
    required String oldPassword,
    required String newPassword,
  }) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse res = await _repository.sendPasswordChangeOtp(
        currentPassword: oldPassword,
      );

      if (res.success) {
        tempNewPassword.value = newPassword;
        AppLoader.hideLoadingDialog();
        AppToasts.showSuccessToast(message: res.message);

        // Navigate to OTP Screen
        Get.to(() => ChangePasswordOtpScreen(oldPassword: oldPassword));
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error sending password change OTP: $e');
      AppToasts.showErrorToast(
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  // Step 2: Verify OTP and Change Password
  Future<void> verifyAndChangePassword({required String otp}) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse res = await _repository.changePassword(
        otp: otp,
        newPassword: tempNewPassword.value,
      );

      if (res.success) {
        AppLoader.hideLoadingDialog();
        AppToasts.showSuccessToast(message: 'Password changed successfully');

        // Navigate back (Pop OTP screen and Change Password screen)
        Get.back(); // Close OTP Screen
        Get.back(); // Close Change Password Screen
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error changing password: $e');
      AppToasts.showErrorToast(
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
