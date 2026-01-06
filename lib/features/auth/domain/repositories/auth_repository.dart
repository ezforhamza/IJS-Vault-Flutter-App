import 'dart:io';

import 'package:dio/dio.dart';
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

  Future<ApiResponse> changePassword({
    required String otp,
    required String newPassword,
  }) async {
    return await apiService.post(
      AppUrls.changePassword,
      data: <String, String>{"otp": otp, "newPassword": newPassword},
    );
  }

  // SEND oTP Send Function for Change password
  Future<ApiResponse> sendPasswordChangeOtp({
    required String currentPassword,
  }) async {
    return await apiService.post(
      AppUrls.sendPasswordChangeOtp,
      data: <String, String>{"currentPassword": currentPassword},
    );
  }

  // Upload PFP
  Future<ApiResponse> uploadProfilePicture({
    required String userId,
    required File filePath,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'image': await MultipartFile.fromFile(filePath.path),
      'userId': userId,
    });

    return await apiService.post(AppUrls.uploadPfp, data: formData);
  }

  Future<ApiResponse> deleteAccount() async {
    return await apiService.delete(AppUrls.deleteAccount);
  }
}
