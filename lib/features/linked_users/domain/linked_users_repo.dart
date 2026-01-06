import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class LinkedUsersRepo {
  ApiService apiService = ApiService();

  // Get Linked Users
  Future<ApiResponse> getLinkedUsers() async {
    return await apiService.get('users/linked/details');
  }
}
