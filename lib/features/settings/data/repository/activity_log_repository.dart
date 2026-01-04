import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ActivityLogRepo {
  final ApiService _apiService = ApiService();

  Future<ApiResponse> getActivityLogs({int page = 1, int limit = 20}) async {
    return await _apiService.get(
      '${AppUrls.auditLogs}?page=$page&limit=$limit',
    );
  }
}
