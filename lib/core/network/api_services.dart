import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      validateStatus: (int? status) => true,

      baseUrl: AppUrls.baseUrl, // Replace with your actual base URL
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  String? _token;

  /// Call this during app startup or before making secure API calls
  Future<void> initToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    debugPrint(_token);
    if (_token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    }
  }

  // POST
  Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    await initToken();

    try {
      final Response<dynamic> response = await _dio.post(endpoint, data: data);
      debugPrint("$response");

      return _buildResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // GET
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    await initToken();
    try {
      final Response<dynamic> response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      debugPrint("$response");
      return _buildResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    await initToken();

    try {
      final Response<dynamic> response = await _dio.put(endpoint, data: data);
      return _buildResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE
  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    await initToken();

    try {
      final Response<dynamic> response = await _dio.delete(
        endpoint,
        data: data,
      );
      return _buildResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // === Helpers ===

  ApiResponse _buildResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return ApiResponse.fromJson(response.data);
    } else {
      return ApiResponse(status: false, message: 'Unexpected response format');
    }
  }

  ApiResponse _handleError(Object error) {
    if (error is DioException) {
      final Map<String, dynamic> errData = _handleDioError(error);
      return ApiResponse(
        status: errData['status'],
        message: errData['message'],
      );
    }
    return ApiResponse(status: false, message: 'Something went wrong: $error');
  }

  Map<String, dynamic> _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      return e.response?.data ??
          <String, dynamic>{'status': false, 'message': 'Unknown error'};
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return <String, dynamic>{
        'status': false,
        'message': 'Connection timeout',
      };
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return <String, dynamic>{'status': false, 'message': 'Receive timeout'};
    } else {
      return <String, dynamic>{
        'status': false,
        'message': 'Network error or unexpected issue',
      };
    }
  }
}
