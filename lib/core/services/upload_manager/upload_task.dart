import 'dart:io';

/// Represents the current state of an upload task
enum UploadStatus {
  pending,
  preparing,
  uploading,
  processing,
  completed,
  failed,
  cancelled,
  paused,
}

/// Model representing a single upload task with progress tracking
class UploadTask {
  UploadTask({
    required this.id,
    required this.file,
    required this.filename,
    required this.fileSize,
    required this.contentType,
    this.parentId,
    this.description,
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.uploadedBytes = 0,
    this.errorMessage,
    this.uploadId,
    this.key,
    this.totalParts = 0,
    this.uploadedParts = 0,
    this.uploadSpeed = 0,
    this.lastUploadedParts = const <int>{},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final File file;
  final String filename;
  final int fileSize;
  final String contentType;
  final String? parentId;
  final String? description;
  final DateTime createdAt;

  // Upload state
  UploadStatus status;
  double progress; // 0.0 to 1.0
  int uploadedBytes;
  String? errorMessage;

  // Resumable upload specific
  String? uploadId;
  String? key;
  int totalParts;
  int uploadedParts;
  
  // Speed tracking
  int uploadSpeed; // bytes per second
  Set<int> lastUploadedParts; // Track which parts are already uploaded (for resume)

  /// Whether this is a large file requiring resumable upload
  bool get isLargeFile => fileSize > 100 * 1024 * 1024; // > 100MB

  /// Formatted file size string
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Formatted uploaded bytes string
  String get formattedUploadedBytes {
    if (uploadedBytes < 1024) return '$uploadedBytes B';
    if (uploadedBytes < 1024 * 1024) {
      return '${(uploadedBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (uploadedBytes < 1024 * 1024 * 1024) {
      return '${(uploadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(uploadedBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Progress percentage string
  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';

  /// Formatted upload speed
  String get formattedSpeed {
    if (uploadSpeed < 1024) return '$uploadSpeed B/s';
    if (uploadSpeed < 1024 * 1024) {
      return '${(uploadSpeed / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(uploadSpeed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Estimated time remaining
  String get estimatedTimeRemaining {
    if (uploadSpeed <= 0 || uploadedBytes >= fileSize) return '';
    final int remainingBytes = fileSize - uploadedBytes;
    final int seconds = (remainingBytes / uploadSpeed).round();
    if (seconds < 60) return '${seconds}s remaining';
    if (seconds < 3600) return '${(seconds / 60).round()}m remaining';
    return '${(seconds / 3600).toStringAsFixed(1)}h remaining';
  }

  /// File extension
  String get fileExtension {
    final int dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == filename.length - 1) return '';
    return filename.substring(dotIndex + 1).toUpperCase();
  }

  /// Status display text
  String get statusText {
    switch (status) {
      case UploadStatus.pending:
        return 'Waiting...';
      case UploadStatus.preparing:
        return 'Preparing...';
      case UploadStatus.uploading:
        return 'Uploading $progressPercentage';
      case UploadStatus.processing:
        return 'Processing...';
      case UploadStatus.completed:
        return 'Completed';
      case UploadStatus.failed:
        return 'Failed';
      case UploadStatus.cancelled:
        return 'Cancelled';
      case UploadStatus.paused:
        return 'Paused';
    }
  }

  /// Create a copy with updated values
  UploadTask copyWith({
    UploadStatus? status,
    double? progress,
    int? uploadedBytes,
    String? errorMessage,
    String? uploadId,
    String? key,
    int? totalParts,
    int? uploadedParts,
    int? uploadSpeed,
    Set<int>? lastUploadedParts,
  }) {
    return UploadTask(
      id: id,
      file: file,
      filename: filename,
      fileSize: fileSize,
      contentType: contentType,
      parentId: parentId,
      description: description,
      createdAt: createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadId: uploadId ?? this.uploadId,
      key: key ?? this.key,
      totalParts: totalParts ?? this.totalParts,
      uploadedParts: uploadedParts ?? this.uploadedParts,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      lastUploadedParts: lastUploadedParts ?? this.lastUploadedParts,
    );
  }
}
