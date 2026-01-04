import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

/// =======================================================
/// Folder View Controller
/// =======================================================

class FolderViewController extends GetxController {
  final RxBool showAddButton = true.obs;
  final RxBool isAddButtonTapped = false.obs;

  void toggleAddTap() {
    isAddButtonTapped.value = !isAddButtonTapped.value;
  }

  void closeMenu() {
    isAddButtonTapped.value = false;
  }
}
