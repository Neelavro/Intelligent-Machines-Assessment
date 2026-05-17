import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:intelligent_machines_assessment/data/datasource/attendance_datasource.dart';
import 'package:intelligent_machines_assessment/data/datasource/attendance_local_datasource.dart';
import 'package:intelligent_machines_assessment/data/model/attendance_model.dart';
import 'package:intelligent_machines_assessment/domain/entites/location_entity.dart';
import 'package:intelligent_machines_assessment/domain/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceDatasource attendanceDatasource;
  final AttendanceLocalDatasource attendanceLocalDatasource;

  AttendanceRepositoryImpl({
    required this.attendanceDatasource,
    required this.attendanceLocalDatasource,
  });

  @override
  Future<Either<String, LocationEntity?>> getOfficeLocation() async {
    try {
      final data = await attendanceLocalDatasource.getOfficeLocation();
      if (data == null) return const Right(null);
      return Right(LocationEntity(lat: data['lat']!, lon: data['lon']!));
    } catch (_) {
      return const Left('Failed to load office location.');
    }
  }

  @override
  Future<Either<String, Unit>> saveOfficeLocation({
    required double lat,
    required double lon,
  }) async {
    try {
      await attendanceLocalDatasource.saveOfficeLocation(lat, lon);
      return const Right(unit);
    } catch (_) {
      return const Left('Failed to save office location.');
    }
  }

  @override
  Future<Either<String, bool>> markAttendance({
    required double lat,
    required double lon,
  }) async {
    try {
      final apiResult = await attendanceDatasource.markAttendance(
        lat: lat,
        lon: lon,
      );

      if (apiResult.statusCode == 200) {
        final model = AttendanceModel.fromJson(
          jsonDecode(apiResult.body) as Map<String, dynamic>,
        );
        return Right(model.success);
      }

      return const Left('Server error. Please try again.');
    } catch (_) {
      return const Left('Failed to mark attendance.');
    }
  }
}
