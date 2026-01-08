import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_manager.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_task.dart';

/// A floating overlay widget that shows upload progress
/// Can be minimized to a draggable circular button or expanded to show all uploads
class UploadProgressOverlay extends StatelessWidget {
  const UploadProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final UploadManager controller = Get.find<UploadManager>();
      debugPrint('📤 UploadProgressOverlay: Building with ${controller.tasks.length} tasks, isMinimized: ${controller.isMinimized.value}');
      
      if (controller.tasks.isEmpty) {
        return const SizedBox.shrink();
      }

      // Show minimized draggable circular button or expanded panel
      if (controller.isMinimized.value) {
        return _DraggableUploadButton(controller: controller);
      }

      return Positioned(
        bottom: 100,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildHeader(controller),
                if (controller.isPanelExpanded.value)
                  _buildTaskList(controller),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(UploadManager controller) {
    final int activeCount = controller.activeUploadCount;
    final int totalCount = controller.tasks.length;

    return InkWell(
      onTap: controller.togglePanel,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(16),
            bottom: controller.isPanelExpanded.value
                ? Radius.zero
                : const Radius.circular(16),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Upload icon with progress ring
            _CircularProgressIcon(
              progress: controller.totalProgress,
              isActive: activeCount > 0,
            ),
            const SizedBox(width: 12),
            // Title and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    activeCount > 0
                        ? 'Uploading $activeCount file${activeCount > 1 ? 's' : ''}'
                        : 'Uploads Complete',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeCount > 0
                        ? '${(controller.totalProgress * 100).toStringAsFixed(0)}%'
                        : '$totalCount done',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Minimize button
            _HeaderIconButton(
              icon: Icons.remove,
              onPressed: controller.toggleMinimize,
              tooltip: 'Minimize',
            ),
            const SizedBox(width: 6),
            // Clear all button (when no active uploads)
            if (activeCount == 0)
              _HeaderIconButton(
                icon: Icons.delete_sweep,
                onPressed: controller.clearCompletedTasks,
                tooltip: 'Clear all',
              ),
            if (activeCount == 0) const SizedBox(width: 6),
            // Expand/collapse icon
            AnimatedRotation(
              turns: controller.isPanelExpanded.value ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(UploadManager controller) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: controller.tasks.length,
        separatorBuilder: (BuildContext _, int __) => Divider(
          height: 1,
          indent: 12,
          endIndent: 12,
          color: Get.isDarkMode ? Colors.white10 : Colors.black12,
        ),
        itemBuilder: (BuildContext context, int index) {
          final UploadTask task = controller.tasks[index];
          return _UploadTaskTile(
            task: task,
            onCancel: () => controller.cancelUpload(task.id),
            onPause: () => controller.pauseUpload(task.id),
            onResume: () => controller.resumeUpload(task.id),
            onRetry: () => controller.retryUpload(task.id),
            onRemove: () => controller.removeTask(task.id),
          );
        },
      ),
    );
  }
}

/// Header icon button
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

/// Draggable minimized upload button with dismiss capability
class _DraggableUploadButton extends StatefulWidget {
  const _DraggableUploadButton({required this.controller});

  final UploadManager controller;

  @override
  State<_DraggableUploadButton> createState() => _DraggableUploadButtonState();
}

class _DraggableUploadButtonState extends State<_DraggableUploadButton>
    with SingleTickerProviderStateMixin {
  Offset _position = const Offset(0, 0);
  bool _initialized = false;
  bool _isDragging = false;
  bool _isNearDismiss = false;

  // Dismiss button position (top center)
  static const double _dismissButtonTop = 80;
  static const double _dismissButtonSize = 56;

  late AnimationController _dismissAnimController;

  @override
  void initState() {
    super.initState();
    _dismissAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _dismissAnimController.dispose();
    super.dispose();
  }

  bool _checkNearDismiss(Size screenSize) {
    final double dismissCenterX = screenSize.width / 2;
    const double dismissCenterY = _dismissButtonTop + _dismissButtonSize / 2;

    final double buttonCenterX = _position.dx + 28;
    final double buttonCenterY = _position.dy + 28;

    final double distance =
        ((buttonCenterX - dismissCenterX) * (buttonCenterX - dismissCenterX) +
        (buttonCenterY - dismissCenterY) * (buttonCenterY - dismissCenterY));

    // Within 60px radius
    return distance < 3600;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Initialize position on first build
    if (!_initialized) {
      _position = Offset(screenSize.width - 76, screenSize.height - 200);
      _initialized = true;
    }

    final bool allComplete = !widget.controller.hasActiveUploads;
    final bool showDismissButton = _isDragging && allComplete;

    return Stack(
      children: <Widget>[
        // Dismiss button at top center (only when dragging and all complete)
        if (showDismissButton)
          Positioned(
            top: _dismissButtonTop,
            left: (screenSize.width - _dismissButtonSize) / 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _dismissButtonSize,
              height: _dismissButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isNearDismiss
                    ? Colors.red
                    : Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.red, width: 2),
                boxShadow: _isNearDismiss
                    ? <BoxShadow>[
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedScale(
                scale: _isNearDismiss ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.close,
                  color: _isNearDismiss ? Colors.white : Colors.red,
                  size: 28,
                ),
              ),
            ),
          ),
        // Draggable upload button
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onTap: widget.controller.expandPanel,
            onPanStart: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(
                    0,
                    screenSize.width - 56,
                  ),
                  (_position.dy + details.delta.dy).clamp(
                    0,
                    screenSize.height - 56,
                  ),
                );
                // Check if near dismiss button
                if (allComplete) {
                  _isNearDismiss = _checkNearDismiss(screenSize);
                }
              });
            },
            onPanEnd: (DragEndDetails details) {
              // Check if should dismiss
              if (allComplete && _isNearDismiss) {
                widget.controller.clearCompletedTasks();
              }
              setState(() {
                _isDragging = false;
                _isNearDismiss = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: allComplete
                      ? <Color>[Colors.green.shade400, Colors.green.shade600]
                      : AppColors.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (allComplete ? Colors.green : AppColors.gradient[0])
                        .withOpacity(0.4),
                    blurRadius: _isDragging ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Progress ring
                  if (widget.controller.hasActiveUploads)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: widget.controller.totalProgress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  // Icon and count
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        allComplete ? Icons.cloud_done : Icons.cloud_upload,
                        color: Colors.white,
                        size: 20,
                      ),
                      if (widget.controller.activeUploadCount > 0)
                        Text(
                          '${widget.controller.activeUploadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular progress icon for header
class _CircularProgressIcon extends StatefulWidget {
  const _CircularProgressIcon({required this.progress, required this.isActive});

  final double progress;
  final bool isActive;

  @override
  State<_CircularProgressIcon> createState() => _CircularProgressIconState();
}

class _CircularProgressIconState extends State<_CircularProgressIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.isActive) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(_CircularProgressIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isActive && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          // Progress arc
          if (widget.isActive)
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: widget.progress > 0 ? widget.progress : null,
                strokeWidth: 2.5,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          // Icon
          Icon(
            widget.isActive ? Icons.cloud_upload : Icons.cloud_done,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }
}

/// Individual upload task tile showing individual upload progress - compact and responsive
class _UploadTaskTile extends StatelessWidget {
  const _UploadTaskTile({
    required this.task,
    required this.onCancel,
    required this.onPause,
    required this.onResume,
    required this.onRetry,
    required this.onRemove,
  });

  final UploadTask task;
  final VoidCallback onCancel;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          // File icon with progress
          _buildFileIcon(),
          const SizedBox(width: 10),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Filename row with percentage
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        task.filename,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Get.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Percentage (compact)
                    if (task.status == UploadStatus.uploading ||
                        task.status == UploadStatus.paused)
                      Text(
                        '${(task.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: task.status == UploadStatus.paused
                              ? Colors.amber
                              : AppColors.gradient[0],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Info row: uploaded/total, speed, status
                Row(
                  children: <Widget>[
                    // Uploaded / Total size (when uploading or paused)
                    if (task.status == UploadStatus.uploading ||
                        task.status == UploadStatus.paused)
                      Text(
                        '${task.formattedUploadedBytes} / ${task.formattedFileSize}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Get.isDarkMode
                              ? Colors.white54
                              : Colors.black45,
                        ),
                      )
                    else
                      Text(
                        task.formattedFileSize,
                        style: TextStyle(
                          fontSize: 11,
                          color: Get.isDarkMode
                              ? Colors.white54
                              : Colors.black45,
                        ),
                      ),
                    // Speed (when uploading)
                    if (task.status == UploadStatus.uploading &&
                        task.uploadSpeed > 0) ...<Widget>[
                      _dot(),
                      Text(
                        task.formattedSpeed,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gradient[0],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    // Status badge for non-uploading states
                    if (task.status != UploadStatus.uploading) ...<Widget>[
                      _dot(),
                      _buildStatusText(),
                    ],
                  ],
                ),
                // Progress bar
                if (_showProgressBar())
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _buildProgressBar(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action button(s)
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 10,
          color: Get.isDarkMode ? Colors.white30 : Colors.black26,
        ),
      ),
    );
  }

  bool _showProgressBar() {
    return task.status == UploadStatus.uploading ||
        task.status == UploadStatus.preparing ||
        task.status == UploadStatus.processing ||
        task.status == UploadStatus.paused;
  }

  Widget _buildFileIcon() {
    IconData icon;
    final Color color = _getFileColor();

    if (task.contentType.startsWith('image/')) {
      icon = Icons.image;
    } else if (task.contentType.startsWith('video/')) {
      icon = Icons.videocam;
    } else if (task.contentType.startsWith('audio/')) {
      icon = Icons.audiotrack;
    } else if (task.contentType.contains('pdf')) {
      icon = Icons.picture_as_pdf;
    } else {
      icon = Icons.insert_drive_file;
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Progress ring
          if (task.status == UploadStatus.uploading)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: task.progress,
                strokeWidth: 2.5,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
        ],
      ),
    );
  }

  Color _getFileColor() {
    if (task.contentType.startsWith('image/')) return Colors.blue;
    if (task.contentType.startsWith('video/')) return Colors.red;
    if (task.contentType.startsWith('audio/')) return Colors.purple;
    if (task.contentType.contains('pdf')) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildStatusText() {
    Color color;
    String text;

    switch (task.status) {
      case UploadStatus.pending:
        color = Colors.grey;
        text = 'Waiting';
      case UploadStatus.preparing:
        color = Colors.blue;
        text = 'Preparing';
      case UploadStatus.uploading:
        color = Colors.blue;
        text = 'Uploading';
      case UploadStatus.processing:
        color = Colors.orange;
        text = 'Processing';
      case UploadStatus.completed:
        color = Colors.green;
        text = 'Done';
      case UploadStatus.failed:
        color = Colors.red;
        text = 'Failed';
      case UploadStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelled';
      case UploadStatus.paused:
        color = Colors.amber;
        text = 'Paused';
    }

    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _buildProgressBar() {
    final bool isIndeterminate =
        task.status == UploadStatus.processing ||
        task.status == UploadStatus.preparing;
    final bool isPaused = task.status == UploadStatus.paused;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: isIndeterminate ? null : task.progress,
        backgroundColor: Get.isDarkMode ? Colors.white12 : Colors.black12,
        valueColor: AlwaysStoppedAnimation<Color>(
          isPaused
              ? Colors.amber
              : (task.status == UploadStatus.processing
                    ? Colors.orange
                    : AppColors.gradient[0]),
        ),
        minHeight: 4,
      ),
    );
  }

  Widget _buildActionButton() {
    switch (task.status) {
      case UploadStatus.uploading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SmallActionButton(
              icon: Icons.pause,
              color: Colors.amber,
              onPressed: onPause,
            ),
            const SizedBox(width: 4),
            _SmallActionButton(
              icon: Icons.close,
              color: Colors.red.shade300,
              onPressed: onCancel,
            ),
          ],
        );
      case UploadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SmallActionButton(
              icon: Icons.play_arrow,
              color: Colors.green,
              onPressed: onResume,
            ),
            const SizedBox(width: 4),
            _SmallActionButton(
              icon: Icons.close,
              color: Colors.red.shade300,
              onPressed: onCancel,
            ),
          ],
        );
      case UploadStatus.preparing:
      case UploadStatus.processing:
        return _SmallActionButton(
          icon: Icons.close,
          color: Colors.red.shade300,
          onPressed: onCancel,
        );
      case UploadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SmallActionButton(
              icon: Icons.refresh,
              color: Colors.blue,
              onPressed: onRetry,
            ),
            const SizedBox(width: 4),
            _SmallActionButton(
              icon: Icons.close,
              color: Colors.grey,
              onPressed: onRemove,
            ),
          ],
        );
      case UploadStatus.completed:
        return _SmallActionButton(
          icon: Icons.check,
          color: Colors.green,
          onPressed: onRemove,
        );
      case UploadStatus.cancelled:
      case UploadStatus.pending:
        return _SmallActionButton(
          icon: Icons.close,
          color: Colors.grey,
          onPressed: onRemove,
        );
    }
  }
}

/// Small compact action button
class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

/// Styled action icon button
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
