import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:ijs_vault/core/controllers/network_controller.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (int? status) => true,
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(_loggingInterceptor());
  }

  late final Dio _dio;
  String? _token;

  /// =====================================================
  /// Init Access Token
  /// =====================================================

  Future<void> _initToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(LocalStorageService.keyAccessToken);

    if (_token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    }
  }

  /// =====================================================
  /// Refresh Token
  /// =====================================================

  Future<bool> _refreshToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString(
        LocalStorageService.keyRefreshToken,
      );
      debugPrint('Message: $refreshToken');

      if (refreshToken == null) return false;

      final Response response = await _dio.post(
        AppUrls.refreshToken, // <-- refresh endpoint
        data: <String, dynamic>{'refreshToken': refreshToken},
        options: Options(
          headers: <String, dynamic>{
            'Authorization': null, // IMPORTANT
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final TokensModel tokens = TokensModel.fromJson(
          response.data['data']['tokens'],
        );

        await LocalStorageService.saveTokens(tokens);

        _dio.options.headers['Authorization'] = 'Bearer ${tokens.access.token}';

        return true;
      }
    } catch (e) {
      debugPrint('Refresh token failed: $e');
    }
    return false;
  }

  /// =====================================================
  /// CHECK CONNECTIVITY
  /// =====================================================

  bool _checkConnectivity() {
    final NetworkController networkController = Get.find<NetworkController>();
    if (!networkController.isConnected.value) {
      // AppToasts.showErrorToast(message: 'No Internet Connection');
      return false;
    }
    return true;
  }

  /// =====================================================
  /// HTTP METHODS
  /// =====================================================

  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    if (!_checkConnectivity()) {
      return ApiResponse(success: false, message: 'No Internet Connection');
    }
    await _initToken();

    try {
      final Response response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      return await _handleResponse(
        response,
        retry: () => _dio.get(endpoint, queryParameters: queryParams),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    if (!_checkConnectivity()) {
      return ApiResponse(success: false, message: 'No Internet Connection');
    }
    await _initToken();

    try {
      final Response response = await _dio.post(endpoint, data: data);

      return await _handleResponse(
        response,
        retry: () => _dio.post(endpoint, data: data),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    if (!_checkConnectivity()) {
      return ApiResponse(success: false, message: 'No Internet Connection');
    }
    await _initToken();

    try {
      final Response response = await _dio.put(endpoint, data: data);

      return await _handleResponse(
        response,
        retry: () => _dio.put(endpoint, data: data),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> patch(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    if (!_checkConnectivity()) {
      return ApiResponse(success: false, message: 'No Internet Connection');
    }
    await _initToken();

    try {
      final Response response = await _dio.patch(endpoint, data: data);

      return await _handleResponse(
        response,
        retry: () => _dio.patch(endpoint, data: data),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    if (!_checkConnectivity()) {
      return ApiResponse(success: false, message: 'No Internet Connection');
    }
    await _initToken();

    try {
      final Response response = await _dio.delete(endpoint, data: data);

      return await _handleResponse(
        response,
        retry: () => _dio.delete(endpoint, data: data),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// =====================================================
  /// RESPONSE HANDLER
  /// =====================================================

  Future<ApiResponse> _handleResponse(
    Response response, {
    required Future<Response> Function() retry,
    bool skipAuthRedirect = false,
  }) async {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final int? errorCode = data['error'] != null
          ? data['error']['code']
          : null;
      final String? errorMessage = data['error'] != null
          ? data['error']['message']
          : null;
      final dynamic responseData = data['data'];
      
      // Check for PIN lockout (403 with PIN-related message)
      if (errorCode == 403 && 
          errorMessage != null &&
          (errorMessage.toLowerCase().contains('pin attempts') ||
           errorMessage.toLowerCase().contains('too many failed'))) {
        await _handleSessionExpiry(
          message: 'Too many failed PIN attempts. Please login again for security.',
        );
        return ApiResponse.fromJson(data);
      }

      // Trigger refresh token if error code is 401 OR message indicates authentication required
      if (errorCode == 401 ||
          (errorMessage != null &&
              errorMessage.toLowerCase().contains('please authenticate'))) {
        final bool refreshed = await _refreshToken();
        if (refreshed) {
          final Response retryResponse = await retry();
          return ApiResponse.fromJson(retryResponse.data);
        }

        // Refresh failed → logout and redirect
        if (!skipAuthRedirect) {
          await _handleSessionExpiry(
            message: 'Your session has expired. Please login again.',
          );
        }
        return ApiResponse(
          success: false,
          message: errorMessage ?? 'Session expired. Please login again.',
        );
      }

      // Normal response
      return ApiResponse.fromJson(data);
    }

    // Unexpected format
    return ApiResponse(success: false, message: 'Unexpected response format');
  }

  /// Handle session expiry - clear tokens and redirect to login
  Future<void> _handleSessionExpiry({required String message}) async {
    await LocalStorageService().clearAll();
    AppToasts.showErrorToast(message: message);
    Get.offAll(() => const LoginScreen());
  }

  /// =====================================================
  /// ERROR HANDLER
  /// =====================================================

  ApiResponse _handleError(Object error) {
    if (error is DioException) {
      return ApiResponse(
        success: false,
        message: error.message ?? 'Network error',
      );
    }

    return ApiResponse(success: false, message: 'Something went wrong');
  }

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        debugPrint('━━━━━━━━━━━━━━ REQUEST ━━━━━━━━━━━━━━');
        debugPrint('➡️ ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Token: $_token');
        debugPrint('Data: ${options.data}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        handler.next(options);
      },
      onResponse:
          (Response<dynamic> response, ResponseInterceptorHandler handler) {
            debugPrint('━━━━━━━━━━━━━━ RESPONSE ━━━━━━━━━━━━━');
            debugPrint(
              '⬅️ ${response.statusCode} ${response.requestOptions.uri}',
            );
            debugPrint('Response: ${response.data}');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            handler.next(response);
          },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        debugPrint('━━━━━━━━━━━━━━ ERROR ━━━━━━━━━━━━━━━━');
        debugPrint('❌ ${error.requestOptions.uri}');
        debugPrint('Message: ${error.message}');
        debugPrint('Response: ${error.response?.data}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        handler.next(error);
      },
    );
  }
}
