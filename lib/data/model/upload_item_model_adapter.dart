import 'package:hive_flutter/hive_flutter.dart';
import 'package:intelligent_machines_assessment/data/model/upload_item_model.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';

class UploadItemModelAdapter extends TypeAdapter<UploadItemModel> {
  @override
  final int typeId = 0;

  @override
  UploadItemModel read(BinaryReader reader) {
    return UploadItemModel(
      filePath: reader.readString(),
      filename: reader.readString(),
      fileSizeBytes: reader.readInt(),
      status: UploadStatus.values[reader.readInt()],
      retryCount: reader.readInt(),
      maxRetries: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, UploadItemModel obj) {
    writer.writeString(obj.filePath);
    writer.writeString(obj.filename);
    writer.writeInt(obj.fileSizeBytes);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.retryCount);
    writer.writeInt(obj.maxRetries);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
