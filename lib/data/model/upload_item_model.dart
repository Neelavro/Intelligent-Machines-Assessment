import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';

class UploadItemModel extends UploadItemEntity {
  const UploadItemModel({
    super.id,
    required super.filePath,
    required super.filename,
    required super.fileSizeBytes,
    super.status,
    super.retryCount,
    super.maxRetries,
    required super.createdAt,
  });

  UploadItemModel copyWith({
    int? id,
    String? filePath,
    String? filename,
    int? fileSizeBytes,
    UploadStatus? status,
    int? retryCount,
    int? maxRetries,
    DateTime? createdAt,
  }) {
    return UploadItemModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      filename: filename ?? this.filename,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
