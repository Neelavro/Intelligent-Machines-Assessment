import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intelligent_machines_assessment/core/location_service.dart';
import 'package:intelligent_machines_assessment/domain/entites/location_entity.dart';
import 'package:intelligent_machines_assessment/domain/usecases/attendance_usecase.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceUsecase attendanceUsecase;
  final LocationService locationService;
  StreamSubscription<Position>? _positionSub;

  LocationEntity? _officeLocation;
  LocationEntity? _currentLocation;
  double? _distanceInMeters;

  AttendanceBloc({
    required this.attendanceUsecase,
    required this.locationService,
  }) : super(AttendanceInitial()) {
    on<AttendanceInitialLoadEvent>(_onInitialLoad);
    on<AttendanceSetOfficeLocationEvent>(_onSetOfficeLocation);
    on<AttendanceMarkAttendanceEvent>(_onMarkAttendance);
    on<AttendanceLocationUpdatedEvent>(_onLocationUpdated);
  }

  Future<void> _onInitialLoad(
    AttendanceInitialLoadEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    if (await Permission.location.isPermanentlyDenied) {
      emit(AttendancePermissionDenied());
      return;
    }

    final result = await attendanceUsecase.getOfficeLocation();
    result.fold(
      (_) {},
      (location) => _officeLocation = location,
    );

    emit(AttendanceLoaded(
      officeLocation: _officeLocation,
      currentLocation: _currentLocation,
      distanceInMeters: _distanceInMeters,
    ));

    final hasPermission = await locationService.requestPermission();
    if (!hasPermission) {
      emit(AttendanceError('Location permission denied. Please enable it in settings.'));
      return;
    }

    _positionSub?.cancel();
    _positionSub = locationService.getPositionStream().listen(
      (position) => add(AttendanceLocationUpdatedEvent(
        lat: position.latitude,
        lon: position.longitude,
      )),
    );
  }

  Future<void> _onSetOfficeLocation(
    AttendanceSetOfficeLocationEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    try {
      final position = await locationService.getCurrentPosition();

      final result = await attendanceUsecase.saveOfficeLocation(
        lat: position.latitude,
        lon: position.longitude,
      );

      result.fold(
        (error) {
          emit(AttendanceError(error));
          emit(AttendanceLoaded(
            officeLocation: _officeLocation,
            currentLocation: _currentLocation,
            distanceInMeters: _distanceInMeters,
          ));
        },
        (_) {
          _officeLocation = LocationEntity(
            lat: position.latitude,
            lon: position.longitude,
          );
          if (_currentLocation != null) {
            _distanceInMeters = locationService.distanceBetween(
              _officeLocation!.lat,
              _officeLocation!.lon,
              _currentLocation!.lat,
              _currentLocation!.lon,
            );
          }
          emit(AttendanceSuccess('Office location saved!'));
          emit(AttendanceLoaded(
            officeLocation: _officeLocation,
            currentLocation: _currentLocation,
            distanceInMeters: _distanceInMeters,
          ));
        },
      );
    } catch (_) {
      emit(AttendanceError('Failed to get location. Please try again.'));
      emit(AttendanceLoaded(
        officeLocation: _officeLocation,
        currentLocation: _currentLocation,
        distanceInMeters: _distanceInMeters,
      ));
    }
  }

  Future<void> _onMarkAttendance(
    AttendanceMarkAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    if (_currentLocation == null) return;

    emit(AttendanceLoading());

    final result = await attendanceUsecase.markAttendance(
      lat: _currentLocation!.lat,
      lon: _currentLocation!.lon,
    );

    result.fold(
      (error) {
        emit(AttendanceError(error));
        emit(AttendanceLoaded(
          officeLocation: _officeLocation,
          currentLocation: _currentLocation,
          distanceInMeters: _distanceInMeters,
        ));
      },
      (_) {
        emit(AttendanceSuccess('Attendance marked successfully!'));
        emit(AttendanceLoaded(
          officeLocation: _officeLocation,
          currentLocation: _currentLocation,
          distanceInMeters: _distanceInMeters,
        ));
      },
    );
  }

  void _onLocationUpdated(
    AttendanceLocationUpdatedEvent event,
    Emitter<AttendanceState> emit,
  ) {
    _currentLocation = LocationEntity(lat: event.lat, lon: event.lon);
    if (_officeLocation != null) {
      _distanceInMeters = locationService.distanceBetween(
        _officeLocation!.lat,
        _officeLocation!.lon,
        event.lat,
        event.lon,
      );
    }
    if (state is! AttendanceLoading) {
      emit(AttendanceLoaded(
        officeLocation: _officeLocation,
        currentLocation: _currentLocation,
        distanceInMeters: _distanceInMeters,
      ));
    }
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
