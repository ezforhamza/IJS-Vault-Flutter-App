import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class AppLoader {
  static void showLoadingDialog() {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      const Center(child: SpinKitThreeBounce(color: Colors.red, size: 35)),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
