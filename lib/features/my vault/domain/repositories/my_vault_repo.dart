import 'package:dio/dio.dart';
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
  Future<ApiResponse> getVaultItems({String? parentId}) async {
    return await apiService.get(
      AppUrls.getVaultItems,
      queryParams: parentId != null
          ? <String, dynamic>{'parentId': parentId}
          : null,
    );
  }

  // Upload File
  Future<ApiResponse> uploadFileLessThan100Mb({
    required String filePath,
    String? parentId,
    required String description,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath),
      'parentId': parentId,
      'description': description,
    });
    return await apiService.post(AppUrls.uploadlessThan100, data: formData);
  }

  // Rename Item
  Future<ApiResponse> renameItem({
    required String id,
    required String newName,
    String? description,
  }) async {
    return await apiService.put(
      '${AppUrls.renameItem}/$id',
      data: <String, dynamic>{'name': newName, "description": description},
    );
  }

  // Move Item
  Future<ApiResponse> moveItem({
    required String id,
    required String newParentId,
  }) async {
    return await apiService.post(
      '${AppUrls.moveItem}/$id/move',
      data: <String, dynamic>{'newParentId': newParentId},
    );
  }

  // Delete Item
  Future<ApiResponse> deleteItem({required String id}) async {
    return await apiService.delete('${AppUrls.deleteItem}/$id');
  }
}
