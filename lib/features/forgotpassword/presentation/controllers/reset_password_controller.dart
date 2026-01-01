import 'package:get/get.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';

class ResetPasswordController extends GetxController {
  void resePassword() async {
    AppLoader.showLoadingDialog();

    await Future.delayed(const Duration(seconds: 4));
    Get.off(() => const LoginScreen());
  }
}
