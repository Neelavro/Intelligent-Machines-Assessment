import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceInitialLoadEvent extends AttendanceEvent {
  const AttendanceInitialLoadEvent();
}

class AttendanceSetOfficeLocationEvent extends AttendanceEvent {
  const AttendanceSetOfficeLocationEvent();
}

class AttendanceMarkAttendanceEvent extends AttendanceEvent {
  const AttendanceMarkAttendanceEvent();
}

class AttendanceLocationUpdatedEvent extends AttendanceEvent {
  final double lat;
  final double lon;

  const AttendanceLocationUpdatedEvent({required this.lat, required this.lon});

  @override
  List<Object?> get props => [lat, lon];
}
