import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:path_provider/path_provider.dart';

class FilePreviewController extends GetxController {
  final MyVaultRepo _repo = MyVaultRepo();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final Rxn<String> downloadUrl = Rxn<String>();
  final Rxn<String> errorMessage = Rxn<String>();

  // PIN Status
  final RxBool isLocked = false.obs;
  final RxBool hasPinProtection = false.obs;
  final RxBool sessionActive = false.obs;
  final RxInt remainingSeconds = 0.obs;

  late ItemModel item;

  void init(ItemModel itemModel) {
    item = itemModel;
    isLocked.value = item.isLocked;
    hasPinProtection.value = item.isLocked;

    if (item.type != 'folder') {
      _checkPinStatusAndLoadPreview();
    }
  }

  Future<void> _checkPinStatusAndLoadPreview() async {
    if (item.isLocked) {
      await checkPinStatus();
      if (sessionActive.value) {
        await getDownloadUrl();
      }
    } else {
      await getDownloadUrl();
    }
  }

  Future<void> checkPinStatus() async {
    try {
      final ApiResponse response = await _repo.getPinStatus(itemId: item.id);

      if (response.success) {
        final data = response.data;
        isLocked.value = data['isLocked'] ?? false;
        hasPinProtection.value = data['hasPinProtection'] ?? false;
        sessionActive.value = data['sessionActive'] ?? false;
        remainingSeconds.value = data['remainingSeconds'] ?? 0;
      }
    } catch (e) {
      debugPrint('Check PIN status error: $e');
    }
  }

  Future<void> getDownloadUrl() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final ApiResponse response = await _repo.getDownloadUrl(itemId: item.id);

      if (response.success) {
        downloadUrl.value = response.data['downloadUrl'];
      } else {
        errorMessage.value = response.message;
        if (response.message.toLowerCase().contains('pin')) {
          isLocked.value = true;
          sessionActive.value = false;
        }
      }
    } catch (e) {
      debugPrint('Get download URL error: $e');
      errorMessage.value = 'Failed to load file preview';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onPinVerified() async {
    sessionActive.value = true;
    await getDownloadUrl();
  }

  Future<void> lockItem() async {
    try {
      final ApiResponse response = await _repo.lockItem(itemId: item.id);

      if (response.success) {
        sessionActive.value = false;
        downloadUrl.value = null;
        AppToasts.showSuccessToast(message: 'Item locked successfully');
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Lock item error: $e');
      AppToasts.showErrorToast(message: 'Failed to lock item');
    }
  }

  Future<void> downloadFile() async {
    if (downloadUrl.value == null) {
      AppToasts.showErrorToast(message: 'Download URL not available');
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      final Directory? downloadsDir = await getDownloadsDirectory();
      final String savePath = '${downloadsDir?.path ?? '/storage/emulated/0/Download'}/${item.name}';

      final Dio dio = Dio();
      await dio.download(
        downloadUrl.value!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      AppToasts.showSuccessToast(message: 'File downloaded to $savePath');
    } catch (e) {
      debugPrint('Download error: $e');
      AppToasts.showErrorToast(message: 'Failed to download file');
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  @override
  void onClose() {
    downloadUrl.value = null;
    super.onClose();
  }
}
