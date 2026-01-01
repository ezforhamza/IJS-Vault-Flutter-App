import 'package:get/get.dart';
import 'package:ijs_vault/features/forgotpassword/presentation/screens/reset_password.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';

class VerifyOtpController extends GetxController {
  RxBool otpWrong = false.obs;
  // Verify Otp
  void verifycode() async {
    AppLoader.showLoadingDialog();
    await Future.delayed(const Duration(seconds: 4));
    AppLoader.hideLoadingDialog();
    Get.to(() => const ResetPasswordScreen());
  }
}
