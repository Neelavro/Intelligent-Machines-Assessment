import 'package:dartz/dartz.dart';
import 'package:intelligent_machines_assessment/domain/entites/location_entity.dart';
import 'package:intelligent_machines_assessment/domain/repository/attendance_repository.dart';

class AttendanceUsecase {
  final AttendanceRepository attendanceRepository;

  AttendanceUsecase(this.attendanceRepository);

  Future<Either<String, LocationEntity?>> getOfficeLocation() =>
      attendanceRepository.getOfficeLocation();

  Future<Either<String, Unit>> saveOfficeLocation({
    required double lat,
    required double lon,
  }) =>
      attendanceRepository.saveOfficeLocation(lat: lat, lon: lon);

  Future<Either<String, bool>> markAttendance({
    required double lat,
    required double lon,
  }) =>
      attendanceRepository.markAttendance(lat: lat, lon: lon);
}
