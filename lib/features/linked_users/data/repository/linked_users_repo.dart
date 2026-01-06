import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class LinkedUsersRepo {
  final ApiService _apiService = ApiService();

  Future<ApiResponse> getLinkedUsers() async {
    return await _apiService.get(AppUrls.getLinkedUsers);
  }
}
