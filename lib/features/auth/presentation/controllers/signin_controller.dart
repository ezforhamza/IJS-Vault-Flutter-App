import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/screens/bottom_nav_bar_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';

class SigninController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool forceError = false.obs;

  void login() async {
    AppLoader.showLoadingDialog();

    await Future.delayed(const Duration(seconds: 4));

    AppLoader.hideLoadingDialog(); // 🔴 MUST CLOSE FIRST

    Get.offAll(() => const HomeWithBottomNavScreen());
  }
}
