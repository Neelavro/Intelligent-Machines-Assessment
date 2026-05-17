import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intelligent_machines_assessment/core/location_service.dart';
import 'package:intelligent_machines_assessment/core/network_info.dart';
import 'package:intelligent_machines_assessment/core/sync_engine.dart';
import 'package:intelligent_machines_assessment/data/datasource/attendance_datasource.dart';
import 'package:intelligent_machines_assessment/data/datasource/attendance_local_datasource.dart';
import 'package:intelligent_machines_assessment/data/datasource/camera_local_datasource.dart';
import 'package:intelligent_machines_assessment/data/datasource/camera_remote_datasource.dart';
import 'package:intelligent_machines_assessment/data/repository/attendance_repository_impl.dart';
import 'package:intelligent_machines_assessment/data/repository/camera_repository_impl.dart';
import 'package:intelligent_machines_assessment/domain/repository/attendance_repository.dart';
import 'package:intelligent_machines_assessment/domain/repository/camera_repository.dart';
import 'package:intelligent_machines_assessment/domain/usecases/attendance_usecase.dart';
import 'package:intelligent_machines_assessment/domain/usecases/camera_usecase.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // core
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl()));
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<SyncEngine>(() => SyncEngine(connectivity: sl()));

  // datasources
  sl.registerLazySingleton<AttendanceDatasource>(() => AttendanceDatasource());
  sl.registerLazySingleton<AttendanceLocalDatasource>(
    () => AttendanceLocalDatasource(),
  );
  sl.registerLazySingleton<CameraLocalDatasource>(() => CameraLocalDatasource());
  sl.registerLazySingleton<CameraRemoteDatasource>(() => CameraRemoteDatasource());

  // repositories
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      attendanceDatasource: sl(),
      attendanceLocalDatasource: sl(),
    ),
  );
  sl.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(
      cameraLocalDatasource: sl(),
      cameraRemoteDatasource: sl(),
    ),
  );

  // usecases
  sl.registerLazySingleton<AttendanceUsecase>(() => AttendanceUsecase(sl()));
  sl.registerLazySingleton<CameraUsecase>(() => CameraUsecase(sl()));

  // blocs
  sl.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      attendanceUsecase: sl(),
      locationService: sl(),
    ),
  );
  sl.registerFactory<CameraBloc>(
    () => CameraBloc(
      cameraUsecase: sl(),
      networkInfo: sl(),
      syncEngine: sl(),
    ),
  );
}
