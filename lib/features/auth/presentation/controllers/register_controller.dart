import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/verify_code_screen.dart';
import 'package:ijs_vault/shared/enum/verification_types.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class RegisterController extends GetxController {
  AuthRepository repository = .new();

  // Register User
  void register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse res = await repository.register(
        fullname: fullname,
        email: email,
        password: password,
      );
      if (res.success) {
        Get.offAll(
          () => VerifyCodeScreen(
            email: email,
            verificationType: VerificationType.emailVerification,
          ),
        );
      } else {
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }
}
