import 'package:dio/dio.dart';
import 'package:ijs_vault/core/network/api_services.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class MyVaultRepo {
  ApiService apiService = ApiService();

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

  Future<ApiResponse> getUsersForLinking({required String query}) async {
    return await apiService.get('${AppUrls.searchUserForLinking}?query=$query');
  }

  // Link User
  Future<ApiResponse> linkSelectedUsers({
    required String itemId,
    required List<Map<String, String>> users,
  }) async {
    return await apiService.post(
      'vault/items/$itemId/share',
      data: <String, dynamic>{'users': users},
    );
  }

  // Set PIN
  Future<ApiResponse> setItemPin({
    required String itemId,
    required String pin,
  }) async {
    return await apiService.post(
      'vault/items/$itemId/set-pin',
      data: <String, dynamic>{'pin': pin},
    );
  }

  // Verify Pin
  Future<ApiResponse> verifyItemPin({
    required String itemId,
    required String pin,
  }) async {
    return await apiService.post(
      'vault/items/$itemId/verify-pin',
      data: <String, dynamic>{'pin': pin},
    );
  }

  // Get Download URL
  Future<ApiResponse> getDownloadUrl({required String itemId}) async {
    return await apiService.get('${AppUrls.downloadFile}/$itemId/download');
  }

  // Get PIN Status
  Future<ApiResponse> getPinStatus({required String itemId}) async {
    return await apiService.get('${AppUrls.pinStatus}/$itemId/pin-status');
  }

  // Lock Item (Revoke PIN Session)
  Future<ApiResponse> lockItem({required String itemId}) async {
    return await apiService.post('${AppUrls.lockItem}/$itemId/lock');
  }

  // Get Shared Items (items shared with current user)
  Future<ApiResponse> getSharedItems() async {
    return await apiService.get(AppUrls.getSharedVault);
  }

  // Get Shared Folder Items (items inside a shared folder)
  Future<ApiResponse> getSharedFolderItems({required String folderId}) async {
    return await apiService.get('${AppUrls.getSharedVault}/$folderId/items');
  }

  // Update Item (name, description, pin, linkedUsers)
  Future<ApiResponse> updateItem({
    required String id,
    String? name,
    String? description,
    String? pin,
    List<Map<String, String>>? linkedUsers,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (pin != null) data['pin'] = pin;
    if (linkedUsers != null) data['linkedUsers'] = linkedUsers;

    return await apiService.put('${AppUrls.renameItem}/$id', data: data);
  }

  // Remove PIN from item
  Future<ApiResponse> removePin({required String itemId}) async {
    return await apiService.post('vault/items/$itemId/remove-pin');
  }

  // Unshare item (remove user access)
  Future<ApiResponse> unshareItem({
    required String itemId,
    required String userId,
  }) async {
    return await apiService.delete('vault/items/$itemId/share/$userId');
  }

  // Get item by ID
  Future<ApiResponse> getItemById({required String itemId}) async {
    return await apiService.get('${AppUrls.getVaultItems}/$itemId');
  }

  // Upload item image (custom folder/file icon)
  Future<ApiResponse> uploadItemImage({
    required String filePath,
    String? itemId,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'image': await MultipartFile.fromFile(filePath),
      if (itemId != null) 'itemId': itemId,
    });
    return await apiService.post('vault/items/upload-image', data: formData);
  }
}
