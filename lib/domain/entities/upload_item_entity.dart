enum UploadStatus { queued, uploading, retrying, synced, failed }

class UploadItemEntity {
  final int? id;
  final String filePath;
  final String filename;
  final int fileSizeBytes;
  final UploadStatus status;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;

  const UploadItemEntity({
    this.id,
    required this.filePath,
    required this.filename,
    required this.fileSizeBytes,
    this.status = UploadStatus.queued,
    this.retryCount = 0,
    this.maxRetries = 5,
    required this.createdAt,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
