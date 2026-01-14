import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

    // Show download options bottom sheet
    _showDownloadOptionsSheet();
  }

  void _showDownloadOptionsSheet() {
    final bool isDarkMode = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Download Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Option 1: Save to Downloads (Quick)
            _buildDownloadOption(
              icon: Icons.download,
              title: 'Quick Download',
              subtitle: 'Save to Downloads folder',
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                _downloadToDefaultLocation();
              },
            ),
            const SizedBox(height: 12),
            // Option 2: Choose Location (Android only)
            if (Platform.isAndroid)
              _buildDownloadOption(
                icon: Icons.folder_open,
                title: 'Choose Location',
                subtitle: 'Select where to save the file',
                isDarkMode: isDarkMode,
                onTap: () {
                  Get.back();
                  _downloadToSelectedLocation();
                },
              ),
            if (Platform.isAndroid) const SizedBox(height: 12),
            // Option 3: Share (iOS best practice)
            _buildDownloadOption(
              icon: Icons.share,
              title: 'Share File',
              subtitle: Platform.isIOS
                  ? 'Save to Files or share with other apps'
                  : 'Share with other apps',
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                _downloadAndShare();
              },
            ),
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2a2a2a) : const Color(0xFFf5f5f5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadToDefaultLocation() async {
    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      final Directory? downloadsDir = await getDownloadsDirectory();
      final String savePath = '${downloadsDir?.path ?? '/storage/emulated/0/Download'}/${item.name}';

      final Dio dio = Dio();
      await dio.download(
        downloadUrl.value!,
        savePath,
        onReceiveProgress: (int received, int total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      AppToasts.showSuccessToast(message: 'File saved to Downloads');
    } catch (e) {
      debugPrint('Download error: $e');
      AppToasts.showErrorToast(message: 'Failed to download file');
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> _downloadToSelectedLocation() async {
    try {
      // Let user select directory
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User cancelled
        return;
      }

      // Check if directory is writable by testing with a temp file
      final Directory dir = Directory(selectedDirectory);
      if (!await dir.exists()) {
        AppToasts.showErrorToast(message: 'Selected directory does not exist');
        return;
      }

      isDownloading.value = true;
      downloadProgress.value = 0.0;

      final String savePath = '$selectedDirectory/${item.name}';

      final Dio dio = Dio();
      await dio.download(
        downloadUrl.value!,
        savePath,
        onReceiveProgress: (int received, int total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      AppToasts.showSuccessToast(message: 'File saved successfully');
    } on PathAccessException catch (e) {
      debugPrint('Permission error: $e');
      AppToasts.showErrorToast(
        message: 'Cannot save to this location. Please choose a different folder like Downloads.',
      );
    } on FileSystemException catch (e) {
      debugPrint('File system error: $e');
      AppToasts.showErrorToast(
        message: 'Cannot write to this location. Try selecting Downloads folder.',
      );
    } catch (e) {
      debugPrint('Download error: $e');
      AppToasts.showErrorToast(message: 'Failed to download file');
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> _downloadAndShare() async {
    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      // Download to temp directory first
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/${item.name}';

      final Dio dio = Dio();
      await dio.download(
        downloadUrl.value!,
        tempPath,
        onReceiveProgress: (int received, int total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      // Share the file
      await Share.shareXFiles(
        <XFile>[XFile(tempPath)],
        text: item.name,
      );
    } catch (e) {
      debugPrint('Download/Share error: $e');
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
