import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/controllers/fcm_controller.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
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

        // if (user.isEmailVerified == false) {
        //   AppLoader.hideLoadingDialog();

        //   Get.to(() => SigninEmailVerificationScreen(email: email));

        //   return;
        // }

        await LocalStorageService.saveTokens(tokens);

        // Update ProfileController with user data
        final ProfileController profileController =
            Get.find<ProfileController>();
        await profileController.updateUser(user);

        // Register FCM Token
        final FCMController fcmController = Get.find<FCMController>();
        await fcmController.registerFCMToken();

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
