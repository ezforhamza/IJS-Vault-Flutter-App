import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class LegalRepo {
  final ApiService _apiService = ApiService();

  /// Get all published legal pages
  Future<ApiResponse> getAllLegalPages() async {
    return await _apiService.get('legal');
  }

  /// Get a specific legal page by type
  /// Types: terms_of_service, privacy_policy, cookie_policy, disclaimer, refund_policy
  Future<ApiResponse> getLegalPageByType({required String type}) async {
    return await _apiService.get('legal/$type');
  }
}
