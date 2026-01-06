import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ChangeProfileRepo {
  final ApiService _apiService = ApiService();

  /// 🔹 Upload profile picture only
  Future<ApiResponse> uploadProfilePicture({
    required String userId,
    required File filePath,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'image': await MultipartFile.fromFile(filePath.path),
      'userId': userId,
    });

    return await _apiService.post(AppUrls.uploadPfp, data: formData);
  }

  /// 🔹 Update full name + phone only
  Future<ApiResponse> updateUserInfo({
    // required String userId,
    required String fullName,
    required String phone,
  }) async {
    return await _apiService.put(
      AppUrls.updateusernameandphone,
      data: <String, dynamic>{'fullName': fullName, 'phone': phone},
    );
  }
}
