import 'package:dartz/dartz.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';

abstract class CameraRepository {
  Future<Either<String, List<UploadItemEntity>>> getUploadQueue();
  Future<Either<String, Unit>> enqueueImages(List<String> filePaths);
  Future<Either<String, Unit>> syncPendingUploads();
  Future<Either<String, Unit>> removeUploadImage(int id);
}
