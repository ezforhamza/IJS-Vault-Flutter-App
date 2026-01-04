import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/forgotpassword/domain/forgot_password_repo.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/verify_code_screen.dart';
import 'package:ijs_vault/shared/enum/verification_types.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordRepo repo = .new();

  void sendOTP({required String email}) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse res = await repo.sendOtp(email: email);
      if (res.success) {
        AppLoader.hideLoadingDialog();

        Get.to(() => VerifyCodeScreen(email: email));

        AppToasts.showSuccessToast(message: res.message);
      } else {
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  /// Verify otp
  ///
  void verifyOTP({
    required String email,
    required String otp,
    required String verificationType,
  }) async {
    AppLoader.showLoadingDialog();
    try {
      final ApiResponse res = await repo.verifyOtp(
        email: email,
        otp: otp,
        verificationType: verificationType,
      );
      if (res.success) {
        AppLoader.hideLoadingDialog();
        if (verificationType == VerificationType.emailVerification.value) {
          Get.to(() => const LoginScreen());
          AppToasts.showSuccessToast(message: res.message);
        }
        if (verificationType == VerificationType.resetPassword.value) {
          Get.to(() => const LoginScreen());
          AppToasts.showSuccessToast(message: res.message);
        }
        AppToasts.showSuccessToast(message: res.message);
      } else {
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }

  // Rest Password
}
