import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/network/app_urls.dart';
import 'package:ijs_vault/core/services/local_storage.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_notification_service.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_task.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:uuid/uuid.dart';

/// Cancel tokens for each upload task
final Map<String, dio.CancelToken> _cancelTokens = <String, dio.CancelToken>{};

/// Callback for when an upload completes successfully
typedef OnUploadComplete = void Function(ItemModel item);

/// Callback for when an upload fails
typedef OnUploadError = void Function(String taskId, String error);

/// Singleton service that manages all file uploads in the background
/// Supports both small file uploads and resumable uploads for large files
class UploadManager extends GetxController {
  static UploadManager get instance => Get.find<UploadManager>();

  final dio.Dio _dio = dio.Dio();
  final Uuid _uuid = const Uuid();
  final UploadNotificationService _notificationService =
      UploadNotificationService();

  // Observable list of all upload tasks
  final RxList<UploadTask> tasks = <UploadTask>[].obs;

  // Whether the upload panel is expanded (false = minimized to circular button)
  final RxBool isPanelExpanded = true.obs;

  // Whether the panel is completely hidden (minimized to floating button)
  final RxBool isMinimized = false.obs;

  // Speed tracking
  final Map<String, int> _lastBytesUploaded = <String, int>{};
  final Map<String, DateTime> _lastSpeedUpdate = <String, DateTime>{};

  // Track completed uploads for notification
  int _completedUploadsCount = 0;

  @override
  void onInit() {
    super.onInit();
    _notificationService.initialize();
  }

  // Whether there are any active uploads
  bool get hasActiveUploads => tasks.any(
    (UploadTask task) =>
        task.status == UploadStatus.uploading ||
        task.status == UploadStatus.preparing ||
        task.status == UploadStatus.processing,
  );

  // Count of active uploads
  int get activeUploadCount => tasks
      .where(
        (UploadTask task) =>
            task.status == UploadStatus.uploading ||
            task.status == UploadStatus.preparing ||
            task.status == UploadStatus.processing,
      )
      .length;

  // Total progress across all active uploads
  double get totalProgress {
    final List<UploadTask> activeTasks = tasks
        .where(
          (UploadTask t) =>
              t.status == UploadStatus.uploading ||
              t.status == UploadStatus.preparing ||
              t.status == UploadStatus.processing,
        )
        .toList();
    if (activeTasks.isEmpty) return 0.0;
    final double sum = activeTasks.fold(
      0.0,
      (double prev, UploadTask t) => prev + t.progress,
    );
    return sum / activeTasks.length;
  }

  // Callbacks
  OnUploadComplete? onUploadComplete;
  OnUploadError? onUploadError;

  // Configuration
  static const int _partSize = 5 * 1024 * 1024; // 5MB
  static const int _concurrentUploads = 3;
  static const int _maxRetries = 3;

  /// Add a new file to the upload queue and start uploading
  Future<String> addUpload({
    required File file,
    required String filename,
    required String contentType,
    String? parentId,
    String? description,
  }) async {
    final int fileSize = await file.length();
    final String taskId = _uuid.v4();

    final UploadTask task = UploadTask(
      id: taskId,
      file: file,
      filename: filename,
      fileSize: fileSize,
      contentType: contentType,
      parentId: parentId,
      description: description,
    );

    tasks.add(task);

    // Start upload in background
    _startUpload(taskId);

    return taskId;
  }

  /// Cancel an upload task
  Future<void> cancelUpload(String taskId) async {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];

    // Cancel the HTTP request
    _cancelTokens[taskId]?.cancel('Upload cancelled by user');
    _cancelTokens.remove(taskId);

    // If it's a resumable upload, abort it on the server
    if (task.uploadId != null && task.key != null) {
      try {
        final String? token = await LocalStorageService.getAccessToken();
        if (token != null) {
          await _dio.post(
            '${AppUrls.baseUrl}vault/resumable/abort',
            options: dio.Options(
              headers: <String, dynamic>{'Authorization': 'Bearer $token'},
            ),
            data: <String, dynamic>{'uploadId': task.uploadId, 'key': task.key},
          );
        }
      } catch (e) {
        debugPrint('Error aborting upload: $e');
      }
    }

    tasks[index] = task.copyWith(status: UploadStatus.cancelled);
  }

  /// Pause an upload task
  Future<void> pauseUpload(String taskId) async {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];
    if (task.status != UploadStatus.uploading) return;

    // Cancel the current HTTP request but keep the upload state
    _cancelTokens[taskId]?.cancel('Upload paused');
    _cancelTokens.remove(taskId);

    tasks[index] = task.copyWith(status: UploadStatus.paused);
  }

  /// Resume a paused upload task
  Future<void> resumeUpload(String taskId) async {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];
    if (task.status != UploadStatus.paused) return;

    tasks[index] = task.copyWith(status: UploadStatus.uploading);

    // Resume the upload
    _startUpload(taskId);
  }

  /// Toggle minimize state
  void toggleMinimize() {
    isMinimized.value = !isMinimized.value;
  }

  /// Expand from minimized state
  void expandPanel() {
    isMinimized.value = false;
    isPanelExpanded.value = true;
  }

  /// Remove a task from the list (only completed, failed, or cancelled)
  void removeTask(String taskId) {
    _cancelTokens.remove(taskId);
    _lastBytesUploaded.remove(taskId);
    _lastSpeedUpdate.remove(taskId);
    tasks.removeWhere(
      (UploadTask t) =>
          t.id == taskId &&
          (t.status == UploadStatus.completed ||
              t.status == UploadStatus.failed ||
              t.status == UploadStatus.cancelled),
    );
  }

  /// Clear all completed/failed/cancelled tasks
  void clearCompletedTasks() {
    final List<String> toRemove = tasks
        .where(
          (UploadTask t) =>
              t.status == UploadStatus.completed ||
              t.status == UploadStatus.failed ||
              t.status == UploadStatus.cancelled,
        )
        .map((UploadTask t) => t.id)
        .toList();

    for (final String id in toRemove) {
      _cancelTokens.remove(id);
      _lastBytesUploaded.remove(id);
      _lastSpeedUpdate.remove(id);
    }

    tasks.removeWhere(
      (UploadTask t) =>
          t.status == UploadStatus.completed ||
          t.status == UploadStatus.failed ||
          t.status == UploadStatus.cancelled,
    );
  }

  /// Retry a failed upload
  Future<void> retryUpload(String taskId) async {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];
    if (task.status != UploadStatus.failed) return;

    tasks[index] = task.copyWith(
      status: UploadStatus.pending,
      progress: 0.0,
      uploadedBytes: 0,
      uploadSpeed: 0,
      errorMessage: null,
      uploadId: null,
      key: null,
      totalParts: 0,
      uploadedParts: 0,
      lastUploadedParts: const <int>{},
    );

    _lastBytesUploaded.remove(taskId);
    _lastSpeedUpdate.remove(taskId);

    _startUpload(taskId);
  }

  /// Toggle panel expanded state
  void togglePanel() {
    isPanelExpanded.value = !isPanelExpanded.value;
  }

  /// Start the upload process for a task
  Future<void> _startUpload(String taskId) async {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];

    // Create cancel token for this upload
    _cancelTokens[taskId] = dio.CancelToken();

    try {
      final String? token = await LocalStorageService.getAccessToken();
      if (token == null) {
        _updateTaskStatus(
          taskId,
          UploadStatus.failed,
          'Authentication required',
        );
        return;
      }

      if (task.isLargeFile) {
        await _uploadLargeFile(taskId, token);
      } else {
        await _uploadSmallFile(taskId, token);
      }
    } on dio.DioException catch (e) {
      if (e.type == dio.DioExceptionType.cancel) {
        // Upload was cancelled or paused, don't mark as failed
        debugPrint('Upload cancelled/paused: $taskId');
        return;
      }
      debugPrint('Upload error: $e');
      _updateTaskStatus(
        taskId,
        UploadStatus.failed,
        e.message ?? 'Upload failed',
      );
      onUploadError?.call(taskId, e.message ?? 'Upload failed');
    } catch (e) {
      debugPrint('Upload error: $e');
      _updateTaskStatus(taskId, UploadStatus.failed, e.toString());
      onUploadError?.call(taskId, e.toString());
    }
  }

  /// Upload small files (< 100MB) using direct upload
  Future<void> _uploadSmallFile(String taskId, String token) async {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];

    _updateTaskStatus(taskId, UploadStatus.uploading);

    final dio.FormData formData = dio.FormData.fromMap(<String, dynamic>{
      'file': await dio.MultipartFile.fromFile(
        task.file.path,
        filename: task.filename,
      ),
      'parentId': task.parentId,
      'description': task.description ?? 'Uploaded file',
    });

    // Track start time for accurate speed calculation
    final DateTime uploadStartTime = DateTime.now();
    int lastProgressUpdate = 0;

    final dio.Response<dynamic> response = await _dio.post(
      '${AppUrls.baseUrl}${AppUrls.uploadlessThan100}',
      data: formData,
      cancelToken: _cancelTokens[taskId],
      options: dio.Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
      ),
      onSendProgress: (int sent, int total) {
        final double progress = total > 0 ? sent / total : 0;

        // Calculate actual speed based on elapsed time since start
        final Duration elapsed = DateTime.now().difference(uploadStartTime);
        if (elapsed.inMilliseconds > 500 && sent > lastProgressUpdate) {
          final int actualSpeed = (sent * 1000 / elapsed.inMilliseconds)
              .round();
          _updateActualSpeed(taskId, actualSpeed);
          lastProgressUpdate = sent;
        }

        _updateTaskProgress(taskId, progress, sent);
      },
    );

    if (response.data['success'] == true) {
      _updateTaskStatus(taskId, UploadStatus.completed);
      final ItemModel item = ItemModel.fromJson(response.data['data']['item']);
      onUploadComplete?.call(item);
    } else {
      final String message = response.data['message'] ?? 'Upload failed';
      _updateTaskStatus(taskId, UploadStatus.failed, message);
      onUploadError?.call(taskId, message);
    }
  }

  /// Upload large files (> 100MB) using resumable multipart upload
  Future<void> _uploadLargeFile(String taskId, String token) async {
    int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    final UploadTask task = tasks[index];

    // Check if this is a resume from paused state
    final bool isResume = task.uploadId != null && task.key != null;
    String uploadId;
    String key;
    int totalParts;
    Set<int> alreadyUploadedParts = task.lastUploadedParts;

    try {
      if (isResume) {
        // Resume from existing upload
        uploadId = task.uploadId!;
        key = task.key!;
        totalParts = task.totalParts;
        _updateTaskStatus(taskId, UploadStatus.uploading);
      } else {
        // Step 1: Initiate upload
        _updateTaskStatus(taskId, UploadStatus.preparing);

        final dio.Response<dynamic> initiateResp = await _dio.post(
          '${AppUrls.baseUrl}vault/resumable/initiate',
          cancelToken: _cancelTokens[taskId],
          options: dio.Options(
            headers: <String, dynamic>{'Authorization': 'Bearer $token'},
          ),
          data: <String, dynamic>{
            'filename': task.filename,
            'contentType': task.contentType,
            'size': task.fileSize,
            'parentId': task.parentId,
            'description': task.description ?? 'Uploaded file',
          },
        );

        if (initiateResp.data['success'] != true) {
          throw Exception(
            initiateResp.data['message'] ?? 'Failed to initiate upload',
          );
        }

        uploadId = initiateResp.data['data']['uploadId'];
        key = initiateResp.data['data']['key'];
        totalParts = initiateResp.data['data']['totalParts'];

        // Update task with upload info
        index = tasks.indexWhere((UploadTask t) => t.id == taskId);
        if (index == -1) return;
        tasks[index] = tasks[index].copyWith(
          uploadId: uploadId,
          key: key,
          totalParts: totalParts,
          status: UploadStatus.uploading,
        );
      }

      // Step 2: Get part URLs and upload parts
      final List<int> allPartNumbers = List<int>.generate(
        totalParts,
        (int i) => i + 1,
      );

      // Filter out already uploaded parts (for resume)
      final List<int> remainingParts = allPartNumbers
          .where((int p) => !alreadyUploadedParts.contains(p))
          .toList();

      int uploadedPartsCount = alreadyUploadedParts.length;
      int totalUploadedBytes = uploadedPartsCount * _partSize;
      if (totalUploadedBytes > task.fileSize) {
        totalUploadedBytes =
            task.fileSize - ((totalParts - uploadedPartsCount) * _partSize);
      }

      // Process parts in batches
      for (int i = 0; i < remainingParts.length; i += 100) {
        // Check if cancelled or paused
        index = tasks.indexWhere((UploadTask t) => t.id == taskId);
        if (index == -1) return;
        final UploadStatus currentStatus = tasks[index].status;
        if (currentStatus == UploadStatus.cancelled ||
            currentStatus == UploadStatus.paused) {
          return;
        }

        final List<int> batchPartNumbers = remainingParts
            .skip(i)
            .take(100)
            .toList();

        // Get presigned URLs for this batch
        final dio.Response<dynamic> partUrlsResp = await _dio.post(
          '${AppUrls.baseUrl}vault/resumable/part-urls',
          cancelToken: _cancelTokens[taskId],
          options: dio.Options(
            headers: <String, dynamic>{'Authorization': 'Bearer $token'},
          ),
          data: <String, dynamic>{
            'uploadId': uploadId,
            'key': key,
            'partNumbers': batchPartNumbers,
          },
        );

        if (partUrlsResp.data['success'] != true) {
          throw Exception('Failed to get part URLs');
        }

        final List<dynamic> parts = partUrlsResp.data['data']['parts'];

        // Upload parts concurrently
        for (int j = 0; j < parts.length; j += _concurrentUploads) {
          // Check if cancelled or paused
          index = tasks.indexWhere((UploadTask t) => t.id == taskId);
          if (index == -1) return;
          final UploadStatus status = tasks[index].status;
          if (status == UploadStatus.cancelled ||
              status == UploadStatus.paused) {
            return;
          }

          final List<dynamic> batch = parts
              .skip(j)
              .take(_concurrentUploads)
              .toList();

          await Future.wait(
            batch.map((dynamic part) async {
              final int partNumber = part['partNumber'] as int;
              final String url = part['uploadUrl'] as String;

              final int start = (partNumber - 1) * _partSize;
              final int end = min(start + _partSize, task.fileSize);
              final int partLength = end - start;

              // Track time for accurate speed calculation
              final DateTime partStartTime = DateTime.now();

              // Upload with retries - stream file directly for real-time progress
              for (int retry = 0; retry < _maxRetries; retry++) {
                try {
                  // Create a stream that reads from file in small chunks for real-time progress
                  final Stream<List<int>> fileStream = _createFileStream(
                    task.file,
                    start,
                    partLength,
                    (int bytesRead) {
                      // Real-time KB-level progress callback
                      final int currentTotalBytes =
                          totalUploadedBytes + bytesRead;
                      final double progress = currentTotalBytes / task.fileSize;
                      _updateTaskProgress(taskId, progress, currentTotalBytes);
                    },
                  );

                  await _dio.put(
                    url,
                    data: fileStream,
                    cancelToken: _cancelTokens[taskId],
                    options: dio.Options(
                      headers: <String, dynamic>{
                        'Content-Type': 'application/octet-stream',
                        'Content-Length': partLength,
                      },
                      sendTimeout: const Duration(minutes: 5),
                      receiveTimeout: const Duration(minutes: 5),
                    ),
                  );
                  break; // Success
                } on dio.DioException catch (e) {
                  if (e.type == dio.DioExceptionType.cancel) rethrow;
                  if (retry == _maxRetries - 1) rethrow;
                  await Future.delayed(
                    Duration(seconds: pow(2, retry).toInt()),
                  );
                } catch (e) {
                  if (retry == _maxRetries - 1) rethrow;
                  await Future.delayed(
                    Duration(seconds: pow(2, retry).toInt()),
                  );
                }
              }

              // Calculate actual upload speed based on completed part
              final Duration partDuration = DateTime.now().difference(
                partStartTime,
              );
              if (partDuration.inMilliseconds > 0) {
                final int actualSpeed =
                    (partLength * 1000 / partDuration.inMilliseconds).round();
                _updateActualSpeed(taskId, actualSpeed);
              }

              uploadedPartsCount++;
              totalUploadedBytes += partLength;
              alreadyUploadedParts = Set<int>.from(alreadyUploadedParts)
                ..add(partNumber);

              // Update progress and track uploaded parts
              final double progress = totalUploadedBytes / task.fileSize;
              _updateTaskProgressWithSpeed(
                taskId,
                progress,
                totalUploadedBytes,
              );

              index = tasks.indexWhere((UploadTask t) => t.id == taskId);
              if (index != -1) {
                tasks[index] = tasks[index].copyWith(
                  uploadedParts: uploadedPartsCount,
                  lastUploadedParts: alreadyUploadedParts,
                );
              }
            }),
          );
        }
      }

      // Step 3: Get ETags from progress endpoint
      _updateTaskStatus(taskId, UploadStatus.processing);

      final dio.Response<dynamic> progressResp = await _dio.get(
        '${AppUrls.baseUrl}vault/resumable/progress',
        queryParameters: <String, dynamic>{'uploadId': uploadId, 'key': key},
        options: dio.Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $token'},
        ),
      );

      if (progressResp.data['success'] != true) {
        throw Exception('Failed to get upload progress');
      }

      final List<dynamic> uploadedParts =
          progressResp.data['data']['uploadedParts'];

      // Step 4: Complete upload
      final dio.Response<dynamic> completeResp = await _dio.post(
        '${AppUrls.baseUrl}vault/resumable/complete',
        options: dio.Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $token'},
        ),
        data: <String, dynamic>{
          'uploadId': uploadId,
          'key': key,
          'parts':
              uploadedParts
                  .map(
                    (p) => <String, dynamic>{
                      'partNumber': p['partNumber'],
                      'etag': p['etag'],
                    },
                  )
                  .toList()
                ..sort(
                  (Map<String, dynamic> a, Map<String, dynamic> b) =>
                      (a['partNumber'] as int).compareTo(
                        b['partNumber'] as int,
                      ),
                ),
          'filename': task.filename,
          'contentType': task.contentType,
          'size': task.fileSize,
          'parentId': task.parentId,
          'description': task.description,
        },
      );

      if (completeResp.data['success'] == true) {
        _updateTaskStatus(taskId, UploadStatus.completed);
        final ItemModel item = ItemModel.fromJson(
          completeResp.data['data']['item'],
        );
        onUploadComplete?.call(item);
      } else {
        throw Exception(
          completeResp.data['message'] ?? 'Failed to complete upload',
        );
      }
    } on dio.DioException catch (e) {
      // Check if this was a pause/cancel - don't mark as failed
      if (e.type == dio.DioExceptionType.cancel) {
        // Check current status - if paused, keep it paused
        final int idx = tasks.indexWhere((UploadTask t) => t.id == taskId);
        if (idx != -1 && tasks[idx].status == UploadStatus.paused) {
          return; // Keep paused status
        }
        // Otherwise it was cancelled
        return;
      }
      _updateTaskStatus(
        taskId,
        UploadStatus.failed,
        e.message ?? 'Upload failed',
      );
      onUploadError?.call(taskId, e.message ?? 'Upload failed');
    } catch (e) {
      // Check if task was paused during upload
      final int idx = tasks.indexWhere((UploadTask t) => t.id == taskId);
      if (idx != -1 && tasks[idx].status == UploadStatus.paused) {
        return; // Keep paused status
      }
      _updateTaskStatus(taskId, UploadStatus.failed, e.toString());
      onUploadError?.call(taskId, e.toString());
    }
  }

  /// Update task status
  void _updateTaskStatus(String taskId, UploadStatus status, [String? error]) {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    tasks[index] = tasks[index].copyWith(status: status, errorMessage: error);

    // Handle notification updates based on status
    if (status == UploadStatus.completed) {
      _completedUploadsCount++;
      _updateNotification();

      // If all uploads complete, show completion notification
      if (!hasActiveUploads) {
        _notificationService.showUploadComplete(
          totalFiles: _completedUploadsCount,
        );
        _completedUploadsCount = 0;
      }
    } else if (status == UploadStatus.failed ||
        status == UploadStatus.cancelled) {
      _updateNotification();

      // If no more active uploads, cancel notification
      if (!hasActiveUploads) {
        _notificationService.cancelUploadNotification();
      }
    }
  }

  /// Update task progress only (without speed calculation)
  void _updateTaskProgress(String taskId, double progress, int uploadedBytes) {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    tasks[index] = tasks[index].copyWith(
      progress: progress,
      uploadedBytes: uploadedBytes,
    );

    // Update notification with progress
    _updateNotification();
  }

  /// Update actual upload speed (calculated from completed transfers)
  void _updateActualSpeed(String taskId, int speed) {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    // Use exponential moving average to smooth speed readings
    final int currentSpeed = tasks[index].uploadSpeed;
    final int smoothedSpeed = currentSpeed > 0
        ? ((currentSpeed * 0.7) + (speed * 0.3)).round()
        : speed;

    tasks[index] = tasks[index].copyWith(uploadSpeed: smoothedSpeed);
  }

  /// Update task progress with speed calculation (for large file parts)
  void _updateTaskProgressWithSpeed(
    String taskId,
    double progress,
    int uploadedBytes,
  ) {
    final int index = tasks.indexWhere((UploadTask t) => t.id == taskId);
    if (index == -1) return;

    tasks[index] = tasks[index].copyWith(
      progress: progress,
      uploadedBytes: uploadedBytes,
    );

    // Update notification with progress
    _updateNotification();
  }

  /// Update the system notification with current upload progress
  void _updateNotification() {
    if (!hasActiveUploads) return;

    // Find the first active upload for display
    final UploadTask? activeTask = tasks.firstWhereOrNull(
      (UploadTask t) => t.status == UploadStatus.uploading,
    );

    if (activeTask == null) return;

    final int overallProgress = (totalProgress * 100).round();
    final String progressText =
        '${activeTask.formattedUploadedBytes} / ${activeTask.formattedFileSize}';

    _notificationService.showUploadProgress(
      filename: activeTask.filename,
      progress: overallProgress,
      progressText: progressText,
      activeUploads: activeUploadCount,
    );
  }

  /// Create a file stream that reads in small chunks for real-time progress
  Stream<List<int>> _createFileStream(
    File file,
    int start,
    int length,
    void Function(int bytesRead) onProgress,
  ) async* {
    const int chunkSize = 64 * 1024; // 64KB chunks for smooth progress
    final RandomAccessFile raf = await file.open();
    await raf.setPosition(start);

    int bytesRead = 0;
    while (bytesRead < length) {
      final int remaining = length - bytesRead;
      final int toRead = remaining < chunkSize ? remaining : chunkSize;
      final List<int> chunk = await raf.read(toRead);
      if (chunk.isEmpty) break;

      bytesRead += chunk.length;
      onProgress(bytesRead);
      yield chunk;
    }

    await raf.close();
  }
}
