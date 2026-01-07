import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:mime/mime.dart';

class UploadConfirmationDialog extends StatelessWidget {
  const UploadConfirmationDialog({
    super.key,
    required this.files,
    required this.onUpload,
    this.onRemoveFile,
    this.parentId,
  });

  final List<File> files;

  /// Callback when user taps Upload
  final Future<void> Function(List<File> files) onUpload;

  /// Callback to remove a file from the list
  final void Function(int index)? onRemoveFile;

  /// Optional parent ID if needed
  final String? parentId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Get.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            _buildHeader(),
            // File list
            Flexible(child: _buildFileList()),
            // Footer with buttons
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final int totalSize = files.fold(0, (int sum, File f) {
      try {
        return sum + f.lengthSync();
      } catch (_) {
        return sum;
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  files.length == 1 ? 'Upload File' : 'Upload ${files.length} Files',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${_formatFileSize(totalSize)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        return _FileInfoTile(
          file: files[index],
          onRemove: onRemoveFile != null ? () => onRemoveFile!(index) : null,
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF252525) : Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gradient[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            await onUpload(files);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.cloud_upload, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                files.length == 1 ? 'Upload File' : 'Upload ${files.length} Files',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Individual file info tile
class _FileInfoTile extends StatelessWidget {
  const _FileInfoTile({
    required this.file,
    this.onRemove,
  });

  final File file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final String filename = file.path.split('/').last;
    final String extension = _getFileExtension(filename);
    final String? mimeType = lookupMimeType(file.path);
    final int fileSize = _getFileSize();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.isDarkMode ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: <Widget>[
          // File icon
          _buildFileIcon(mimeType, extension),
          const SizedBox(width: 12),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  filename,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Get.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    // File type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getFileColor(mimeType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        extension.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getFileColor(mimeType),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // File size
                    Text(
                      _formatFileSize(fileSize),
                      style: TextStyle(
                        fontSize: 12,
                        color: Get.isDarkMode ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    // Large file warning
                    if (fileSize > 100 * 1024 * 1024) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.info_outline, size: 10, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              'Large file',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                size: 18,
                color: Get.isDarkMode ? Colors.white54 : Colors.black45,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String? mimeType, String extension) {
    IconData icon;
    Color color = _getFileColor(mimeType);

    if (mimeType?.startsWith('image/') ?? false) {
      icon = Icons.image;
    } else if (mimeType?.startsWith('video/') ?? false) {
      icon = Icons.videocam;
    } else if (mimeType?.startsWith('audio/') ?? false) {
      icon = Icons.audiotrack;
    } else if (mimeType?.contains('pdf') ?? false) {
      icon = Icons.picture_as_pdf;
    } else if (mimeType?.contains('document') ?? mimeType?.contains('word') ?? false) {
      icon = Icons.description;
    } else if (mimeType?.contains('spreadsheet') ?? mimeType?.contains('excel') ?? false) {
      icon = Icons.table_chart;
    } else if (mimeType?.contains('presentation') ?? mimeType?.contains('powerpoint') ?? false) {
      icon = Icons.slideshow;
    } else if (mimeType?.contains('zip') ?? mimeType?.contains('archive') ?? false) {
      icon = Icons.folder_zip;
    } else {
      icon = Icons.insert_drive_file;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Color _getFileColor(String? mimeType) {
    if (mimeType?.startsWith('image/') ?? false) return Colors.blue;
    if (mimeType?.startsWith('video/') ?? false) return Colors.red;
    if (mimeType?.startsWith('audio/') ?? false) return Colors.purple;
    if (mimeType?.contains('pdf') ?? false) return Colors.orange;
    if (mimeType?.contains('document') ?? mimeType?.contains('word') ?? false) {
      return Colors.blue;
    }
    if (mimeType?.contains('spreadsheet') ?? mimeType?.contains('excel') ?? false) {
      return Colors.green;
    }
    if (mimeType?.contains('presentation') ?? mimeType?.contains('powerpoint') ?? false) {
      return Colors.deepOrange;
    }
    if (mimeType?.contains('zip') ?? mimeType?.contains('archive') ?? false) {
      return Colors.amber;
    }
    return Colors.grey;
  }

  String _getFileExtension(String filename) {
    final int dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == filename.length - 1) return 'FILE';
    return filename.substring(dotIndex + 1);
  }

  int _getFileSize() {
    try {
      return file.lengthSync();
    } catch (_) {
      return 0;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
