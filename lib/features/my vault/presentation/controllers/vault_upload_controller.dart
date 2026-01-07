import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/core/services/resumeable_upload_service.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/folder_view_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/file_confirmation_widget.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:mime/mime.dart';

class VaultUploadController extends GetxController {
  final MyVaultRepo repo = MyVaultRepo();
  final RxBool isUploading = false.obs;

  Future<void> pickAndConfirmUpload(
    BuildContext context, {
    String? parentId,
  }) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final File file = File(result.files.first.path!);
    _showUploadConfirmationDialog(
      context: context,
      file: file,
      parentId: parentId,
    );
  }

  void _showUploadConfirmationDialog({
    required BuildContext context,
    required File file,
    String? parentId,
  }) {
    Get.dialog(
      barrierColor: const Color(0xFF494a51).withValues(alpha: 0.4),
      UploadConfirmationDialog(
        file: file,
        onTap: () {
          return uploadSelectedFile(file, parentId: parentId);
        },
        isUploading: isUploading,
      ),
    );
  }

  Future<void> uploadSelectedFile(File file, {String? parentId}) async {
    const int fileSizeThreshold = 100 * 1024 * 1024; // 100MB

    try {
      isUploading.value = true;
      final int fileSize = await file.length();
      final String filename = file.path.split('/').last;

      if (fileSize > fileSizeThreshold) {
        await _uploadLargeFile(file, filename, fileSize, parentId: parentId);
      } else {
        await _uploadSmallFile(file, parentId: parentId);
      }
    } catch (e) {
      AppToasts.showErrorToast(message: e.toString());
    } finally {
      isUploading.value = false;
      AppLoader.hideLoadingDialog();
    }
  }

  Future<void> _uploadSmallFile(File file, {String? parentId}) async {
    AppLoader.showLoadingDialog();

    final ApiResponse response = await repo.uploadFileLessThan100Mb(
      filePath: file.path,
      description: 'Uploaded from device',
      parentId: parentId,
    );

    if (response.success) {
      AppToasts.showSuccessToast(message: response.message);
      final ItemModel newItem = ItemModel.fromJson(response.data['item']);
      _addItemToCorrectController(newItem, parentId);
    } else {
      AppToasts.showErrorToast(message: response.message);
    }
  }

  Future<void> _uploadLargeFile(
    File file,
    String filename,
    int fileSize, {
    String? parentId,
  }) async {
    AppLoader.showLoadingDialog();

    try {
      final String? token = await LocalStorageService.getAccessToken();
      if (token == null) {
        AppToasts.showErrorToast(message: 'Authentication required');
        return;
      }

      final String? mimeType = lookupMimeType(file.path);
      final String contentType = mimeType ?? 'application/octet-stream';
      final ResumableUploadService uploadService = ResumableUploadService();

      final bool success = await uploadService.uploadFile(
        file: file,
        filename: filename,
        contentType: contentType,
        parentId: parentId ?? '',
        token: token,
        concurrentUploads: 3,
      );

      if (success) {
        AppToasts.showSuccessToast(message: 'File uploaded successfully');
        _refreshCorrectController(parentId);
      } else {
        AppToasts.showErrorToast(message: 'Upload failed');
      }
    } catch (e) {
      debugPrint('Large file upload error: $e');
      AppToasts.showErrorToast(message: 'Failed to upload large file');
    }
  }

  void _addItemToCorrectController(ItemModel newItem, String? parentId) {
    if (parentId == null) {
      if (Get.isRegistered<MyVaultController>()) {
        Get.find<MyVaultController>().items.add(newItem);
      }
    } else {
      if (Get.isRegistered<FolderViewController>(tag: parentId)) {
        Get.find<FolderViewController>(tag: parentId).items.add(newItem);
      }
    }
  }

  Future<void> _refreshCorrectController(String? parentId) async {
    if (parentId == null) {
      if (Get.isRegistered<MyVaultController>()) {
        await Get.find<MyVaultController>().getVaultItems();
      }
    } else {
      if (Get.isRegistered<FolderViewController>(tag: parentId)) {
        await Get.find<FolderViewController>(tag: parentId).getVaultItems();
      }
    }
  }
}
