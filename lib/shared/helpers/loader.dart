import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/loader_widget.dart';

class AppLoader {
  static void showLoadingDialog() {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(const LoaderWidget(), barrierDismissible: false);
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
