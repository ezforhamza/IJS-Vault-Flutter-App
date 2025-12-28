import 'package:get/state_manager.dart';

class MyVaultController extends GetxController {
  RxBool isAddButtonTapped = false.obs;
  RxBool showAddButton = true.obs;

  void toggleAddTap() {
    isAddButtonTapped.value = !isAddButtonTapped.value;
  }
}
