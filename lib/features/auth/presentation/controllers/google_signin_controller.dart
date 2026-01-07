import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ijs_vault/core/controllers/fcm_controller.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/screens/bottom_nav_bar_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class GoogleSignInController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      AppLoader.showLoadingDialog();
      isLoading.value = true;

      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        AppLoader.hideLoadingDialog();
        isLoading.value = false;
        return;
      }

      // Step 2: Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with the credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // Step 5: Get Firebase ID token to send to backend
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        AppToasts.showErrorToast(message: 'Failed to get authentication token');
        AppLoader.hideLoadingDialog();
        isLoading.value = false;
        return;
      }

      // Step 6: Send Firebase ID token to backend
      final ApiResponse res = await _repository.googleLogin(
        idToken: firebaseIdToken,
      );

      if (res.success) {
        final UserModel user = UserModel.fromJson(res.data['user']);
        final TokensModel tokens = TokensModel.fromJson(res.data['tokens']);

        // Save tokens locally
        await LocalStorageService.saveTokens(tokens);

        // Update ProfileController with user data
        final ProfileController profileController =
            Get.find<ProfileController>();
        await profileController.updateUser(user);

        // Register FCM Token
        final FCMController fcmController = Get.find<FCMController>();
        await fcmController.registerFCMToken();

        // Navigate to home screen
        Get.offAll(() => const HomeWithBottomNavScreen());
      } else {
        debugPrint('Google login error: ${res.message}');
        AppToasts.showErrorToast(message: res.message);
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      AppToasts.showErrorToast(
        message: 'Google sign-in failed. Please try again.',
      );
    } finally {
      AppLoader.hideLoadingDialog();
      isLoading.value = false;
    }
  }

  /// Sign out from Google (useful for logout functionality)
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
  }
}
