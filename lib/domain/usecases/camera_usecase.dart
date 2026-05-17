import 'package:dartz/dartz.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';
import 'package:intelligent_machines_assessment/domain/repository/camera_repository.dart';

class CameraUsecase {
  final CameraRepository cameraRepository;

  CameraUsecase(this.cameraRepository);

  Future<Either<String, List<UploadItemEntity>>> getUploadQueue() =>
      cameraRepository.getUploadQueue();

  Future<Either<String, Unit>> enqueueImages(List<String> filePaths) =>
      cameraRepository.enqueueImages(filePaths);

  Future<Either<String, Unit>> syncPendingUploads() =>
      cameraRepository.syncPendingUploads();

  Future<Either<String, Unit>> removeUploadImage(int id) =>
      cameraRepository.removeUploadImage(id);
}
