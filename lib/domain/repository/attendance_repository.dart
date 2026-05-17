import 'package:dartz/dartz.dart';
import 'package:intelligent_machines_assessment/domain/entites/location_entity.dart';

abstract class AttendanceRepository {
  Future<Either<String, LocationEntity?>> getOfficeLocation();

  Future<Either<String, Unit>> saveOfficeLocation({
    required double lat,
    required double lon,
  });

  Future<Either<String, bool>> markAttendance({
    required double lat,
    required double lon,
  });
}
