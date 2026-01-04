import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/screens/bottom_nav_bar_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class SigninController extends GetxController {
  AuthRepository repository = .new();

  // Register User
  void login({required String email, required String password}) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse res = await repository.login(
        email: email,
        password: password,
      );
      if (res.success) {
        final UserModel user = UserModel.fromJson(res.data['user']);
        final TokensModel tokens = TokensModel.fromJson(res.data['tokens']);

        await LocalStorageService.saveUser(user);
        await LocalStorageService.saveTokens(tokens);

        Get.offAll(() => const HomeWithBottomNavScreen());
      } else {
        debugPrint('Login error${res.message}');
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      AppLoader.hideLoadingDialog();
    }
  }
}
