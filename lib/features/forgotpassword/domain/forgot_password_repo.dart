import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ForgotPasswordRepo {
  ApiService apiService = ApiService.new();
  // Send OTP
  Future<ApiResponse> sendOtp({required String email}) async {
    return await apiService.post(
      AppUrls.forgotPassword,
      data: <String, String>{'email': email},
    );
  }

  // Resend Verification Code
  Future<ApiResponse> resendVerificationCode({required String email}) async {
    return await apiService.post(
      AppUrls.resendVerificationCode,
      data: <String, String>{'email': email},
    );
  }

  // Verify OTP
  Future<ApiResponse> verifyOtp({
    required String email,
    required String otp,
    required String verificationType,
  }) async {
    return await apiService.post(
      AppUrls.verifyOtp,
      data: <String, String>{
        'email': email,
        'otp': otp,
        "type": verificationType,
      },
    );
  }

  // Reset Password
  Future<ApiResponse> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    return await apiService.post(
      AppUrls.resetPassword,
      data: <String, String>{'email': email, 'otp': otp, 'password': password},
    );
  }
}
