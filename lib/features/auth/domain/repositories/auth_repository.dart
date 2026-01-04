import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class AuthRepository {
  ApiService apiService = .new();
  // Register User

  Future<ApiResponse> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    return await apiService.post(
      AppUrls.register,
      data: <String, String>{
        "fullName": fullname,
        "email": email,
        "password": password,
      },
    );
  }

  // Login User

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    return await apiService.post(
      AppUrls.login,
      data: <String, String>{"email": email, "password": password},
    );
  }
}
