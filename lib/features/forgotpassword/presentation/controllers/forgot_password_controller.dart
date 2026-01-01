import 'package:get/get.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/verify_code_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';

class ForgotPasswordController extends GetxController {
  void sendOTP({required String email}) async {
    AppLoader.showLoadingDialog();
    await Future.delayed(const Duration(seconds: 4));

    AppLoader.hideLoadingDialog();
    Get.to(() => VerifyCodeScreen(email: email));
  }
}
