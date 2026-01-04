import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class MyVaultRepo {
  ApiService apiService = .new();

  // Create New FOlder

  Future<ApiResponse> createNewFolder({
    required String name,
    required String description,
    String? parentId,
  }) async {
    return await apiService.post(
      AppUrls.createFolder,
      data: <String, String?>{
        "name": name,
        "parentId": parentId,
        "description": description,
      },
    );
  }

  // Get Vault Items
  Future<ApiResponse> getVaultItems() async {
    return await apiService.get(AppUrls.getVaultItems);
  }
}
