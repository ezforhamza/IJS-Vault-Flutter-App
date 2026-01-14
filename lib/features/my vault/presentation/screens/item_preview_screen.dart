import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/file_preview_controller.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:video_player/video_player.dart';

class ItemPreviewScreen extends StatelessWidget {
  const ItemPreviewScreen({super.key, required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final FilePreviewController controller = Get.put(FilePreviewController());
    controller.init(item);

    return Scaffold(
      appBar: CustomAppBar(text: item.name),
      body: Obx(() {
        // Show loading state
        if (controller.isLoading.value) {
          return const _LoadingView();
        }

        // Check if item is locked and session is not active
        if (controller.hasPinProtection.value && !controller.sessionActive.value) {
          return _LockedView(
            item: item,
            onUnlock: () async {
              final result = await Get.to<bool>(
                () => VerifyPinScreen(
                  itemId: item.id,
                  onSuccess: () {
                    Get.back(result: true);
                  },
                ),
              );
              if (result == true) {
                controller.onPinVerified();
              }
            },
          );
        }

        // Show error state
        if (controller.errorMessage.value != null) {
          return _ErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.getDownloadUrl,
          );
        }

        // Show preview based on file type
        return _PreviewContent(
          item: item,
          downloadUrl: controller.downloadUrl.value,
          controller: controller,
        );
      }),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: isDarkMode ? Colors.white : AppColors.gradient[0],
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading preview...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  const _LockedView({required this.item, required this.onUnlock});
  final ItemModel item;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF292416)
                    : const Color(0xFFf4edd7),
                shape: BoxShape.circle,
                border: const GradientBoxBorder(
                  gradient: LinearGradient(colors: AppColors.gradient),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.gradient[0],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'This file is protected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your PIN to view this file',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            _GradientButton(
              text: 'Unlock File',
              icon: Icons.lock_open,
              onTap: onUnlock,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            _GradientButton(
              text: 'Retry',
              icon: Icons.refresh,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent({
    required this.item,
    required this.downloadUrl,
    required this.controller,
  });
  final ItemModel item;
  final String? downloadUrl;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    if (item.isImage && downloadUrl != null) {
      return _ImagePreview(url: downloadUrl!, item: item, controller: controller);
    } else if (item.isVideo && downloadUrl != null) {
      return _VideoPreview(url: downloadUrl!, item: item, controller: controller);
    } else if (item.isAudio && downloadUrl != null) {
      return _AudioPreview(url: downloadUrl!, item: item, controller: controller);
    } else if (item.isPdf && downloadUrl != null) {
      return _PdfPreview(url: downloadUrl!, item: item, controller: controller);
    } else {
      return _NoPreviewView(item: item, controller: controller);
    }
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.url,
    required this.item,
    required this.controller,
  });
  final String url;
  final ItemModel item;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const _LoadingView(),
                errorWidget: (context, url, error) => _ImageErrorWidget(
                  item: item,
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
        _FileInfoBar(item: item, controller: controller),
      ],
    );
  }
}

class _ImageErrorWidget extends StatelessWidget {
  const _ImageErrorWidget({required this.item, required this.controller});
  final ItemModel item;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.broken_image_outlined,
          size: 64,
          color: isDarkMode ? Colors.white54 : Colors.black38,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load image',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({
    required this.url,
    required this.item,
    required this.controller,
  });
  final String url;
  final ItemModel item;
  final FilePreviewController controller;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading video',
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Failed to load video';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Column(
      children: [
        Expanded(
          child: _isInitializing
              ? const _LoadingView()
              : _errorMessage != null
                  ? _buildErrorView(isDarkMode)
                  : _chewieController != null
                      ? Container(
                          color: Colors.black,
                          child: Center(
                            child: Chewie(controller: _chewieController!),
                          ),
                        )
                      : _buildErrorView(isDarkMode),
        ),
        _FileInfoBar(item: widget.item, controller: widget.controller),
      ],
    );
  }

  Widget _buildErrorView(bool isDarkMode) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF292416) : const Color(0xFFf4edd7),
          borderRadius: BorderRadius.circular(20),
          border: const GradientBoxBorder(
            gradient: LinearGradient(colors: AppColors.gradient),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gradient[0].withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_circle_outline,
                size: 80,
                color: AppColors.gradient[0],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Video file',
              style: TextStyle(
                fontSize: 14,
                color: _errorMessage != null
                    ? Colors.red[400]
                    : (isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ),
            if (widget.item.formattedSize.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.item.formattedSize,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Download to view in external player',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPreview extends StatelessWidget {
  const _AudioPreview({
    required this.url,
    required this.item,
    required this.controller,
  });
  final String url;
  final ItemModel item;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF292416)
                    : const Color(0xFFf4edd7),
                borderRadius: BorderRadius.circular(20),
                border: const GradientBoxBorder(
                  gradient: LinearGradient(colors: AppColors.gradient),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.gradient[0].withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.audiotrack,
                      size: 80,
                      color: AppColors.gradient[0],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Audio file',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (item.formattedSize.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.formattedSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Audio playback coming soon.\nDownload to listen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _FileInfoBar(item: item, controller: controller),
      ],
    );
  }
}

class _PdfPreview extends StatelessWidget {
  const _PdfPreview({
    required this.url,
    required this.item,
    required this.controller,
  });
  final String url;
  final ItemModel item;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF292416)
                    : const Color(0xFFf4edd7),
                borderRadius: BorderRadius.circular(20),
                border: const GradientBoxBorder(
                  gradient: LinearGradient(colors: AppColors.gradient),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      size: 80,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF Document',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (item.formattedSize.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.formattedSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'PDF preview coming soon.\nDownload to view.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _FileInfoBar(item: item, controller: controller),
      ],
    );
  }
}

class _NoPreviewView extends StatelessWidget {
  const _NoPreviewView({required this.item, required this.controller});
  final ItemModel item;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final String ext = item.extension?.toLowerCase() ??
        item.name.split('.').last.toLowerCase();

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF292416)
                    : const Color(0xFFf4edd7),
                borderRadius: BorderRadius.circular(20),
                border: const GradientBoxBorder(
                  gradient: LinearGradient(colors: AppColors.gradient),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: FileIcon(
                      item.name,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gradient[0].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ext.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gradient[0],
                      ),
                    ),
                  ),
                  if (item.formattedSize.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.formattedSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_off_outlined,
                          size: 20,
                          color: isDarkMode ? Colors.white54 : Colors.black38,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No preview available',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download this file to open it\nwith a compatible app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white38 : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _FileInfoBar(item: item, controller: controller),
      ],
    );
  }
}

class _FileInfoBar extends StatelessWidget {
  const _FileInfoBar({required this.item, required this.controller});
  final ItemModel item;
  final FilePreviewController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File info row
            if (item.description.isNotEmpty) ...[
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Obx(() => _ActionButton(
                        icon: Icons.download,
                        label: controller.isDownloading.value
                            ? '${(controller.downloadProgress.value * 100).toInt()}%'
                            : 'Download',
                        onTap: controller.isDownloading.value
                            ? null
                            : controller.downloadFile,
                        isLoading: controller.isDownloading.value,
                      )),
                ),
                if (controller.hasPinProtection.value &&
                    controller.sessionActive.value) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.lock,
                      label: 'Lock',
                      onTap: controller.lockItem,
                      isSecondary: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isSecondary = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppColors.gradient[0]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: AppColors.gradient[0], size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: AppColors.gradient[0],
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradient),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradient),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
