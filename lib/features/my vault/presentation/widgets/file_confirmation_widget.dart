import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/loader_widget.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class UploadConfirmationDialog extends StatelessWidget {
  const UploadConfirmationDialog({
    super.key,
    required this.file,
    required this.onTap,
    required this.isUploading,
    this.parentId,
  });

  final File file;

  /// Callback when user taps Upload
  final Future<void> Function() onTap;

  /// RxBool or ValueNotifier to indicate uploading state
  final RxBool isUploading;

  /// Optional parent ID if needed
  final String? parentId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // File name
              Text(
                file.path.split('/').last,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                'Upload this File?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Show loading or button
              isUploading.value
                  ? const LoaderWidget()
                  : CustomButton(onTap: onTap, text: 'Upload'),
            ],
          );
        }),
      ),
    );
  }
}
