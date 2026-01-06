import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/controllers/fcm_controller.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';

/// Universal Profile Controller
/// Manages user data across the app with reactive updates
class ProfileController extends GetxController {
  // Reactive user data
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  /// Load user from local storage
  Future<void> loadUser() async {
    final UserModel? user = await LocalStorageService.getUser();
    currentUser.value = user;
  }

  /// Update user in local storage and reactive state
  Future<void> updateUser(UserModel user) async {
    await LocalStorageService.saveUser(user);
    currentUser.value = user;
  }

  /// Clear user data (logout)
  Future<void> clearUser() async {
    try {
      final FCMController fcmController = Get.find<FCMController>();
      await fcmController.unregisterFCMToken();
    } catch (e) {
      debugPrint('FCM unregister error: $e');
    }
    await LocalStorageService().clearAll();
    currentUser.value = null;
  }

  /// Get user ID
  String? get userId => currentUser.value?.id;

  /// Get user email
  String? get userEmail => currentUser.value?.email;

  /// Get user full name
  String? get userFullName => currentUser.value?.fullName;

  /// Check if user is verified
  bool get isEmailVerified => currentUser.value?.isEmailVerified ?? false;
}
