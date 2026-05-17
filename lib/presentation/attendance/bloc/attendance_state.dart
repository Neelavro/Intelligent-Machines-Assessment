import 'package:intelligent_machines_assessment/domain/entites/location_entity.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendancePermissionDenied extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final LocationEntity? officeLocation;
  final LocationEntity? currentLocation;
  final double? distanceInMeters;

  AttendanceLoaded({
    this.officeLocation,
    this.currentLocation,
    this.distanceInMeters,
  });
}

class AttendanceSuccess extends AttendanceState {
  final String message;

  AttendanceSuccess(this.message);
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}
