import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;
import 'package:intelligent_machines_assessment/data/datasource/camera_local_datasource.dart';
import 'package:intelligent_machines_assessment/data/datasource/camera_remote_datasource.dart';
import 'package:intelligent_machines_assessment/data/model/upload_item_model.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';
import 'package:intelligent_machines_assessment/domain/repository/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraLocalDatasource cameraLocalDatasource;
  final CameraRemoteDatasource cameraRemoteDatasource;

  CameraRepositoryImpl({
    required this.cameraLocalDatasource,
    required this.cameraRemoteDatasource,
  });

  @override
  Future<Either<String, List<UploadItemEntity>>> getUploadQueue() async {
    try {
      final images = await cameraLocalDatasource.getQueue();
      return Right(images);
    } catch (_) {
      return const Left('Failed to load upload queue.');
    }
  }

  @override
  Future<Either<String, Unit>> enqueueImages(List<String> filePaths) async {
    try {
      for (final path in filePaths) {
        final file = File(path);
        final size = await file.length();
        final model = UploadItemModel(
          filePath: path,
          filename: p.basename(path),
          fileSizeBytes: size,
          status: UploadStatus.queued,
          retryCount: 0,
          maxRetries: 5,
          createdAt: DateTime.now(),
        );
        await cameraLocalDatasource.insertItem(model);
      }
      return const Right(unit);
    } catch (_) {
      return const Left('Failed to queue images.');
    }
  }

  @override
  Future<Either<String, Unit>> syncPendingUploads() async {
    try {
      final pending = await cameraLocalDatasource.getPendingItems();
      for (final image in pending) {
        await cameraLocalDatasource.updateStatus(image.id!, UploadStatus.uploading);
        try {
          final result = await cameraRemoteDatasource.uploadImage(image.filePath);
          if (result.statusCode == 200 || result.statusCode == 201) {
            await cameraLocalDatasource.updateStatus(image.id!, UploadStatus.synced);
          } else {
            final newRetry = image.retryCount + 1;
            await cameraLocalDatasource.updateStatus(
              image.id!,
              newRetry >= image.maxRetries ? UploadStatus.failed : UploadStatus.retrying,
              retryCount: newRetry,
            );
          }
        } catch (_) {
          final newRetry = image.retryCount + 1;
          await cameraLocalDatasource.updateStatus(
            image.id!,
            newRetry >= image.maxRetries ? UploadStatus.failed : UploadStatus.retrying,
            retryCount: newRetry,
          );
        }
      }
      return const Right(unit);
    } catch (_) {
      return const Left('Sync failed.');
    }
  }

  @override
  Future<Either<String, Unit>> removeUploadImage(int id) async {
    try {
      await cameraLocalDatasource.deleteItem(id);
      return const Right(unit);
    } catch (_) {
      return const Left('Failed to remove image.');
    }
  }
}
