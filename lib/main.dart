import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intelligent_machines_assessment/data/model/upload_item_model_adapter.dart';
import 'package:intelligent_machines_assessment/core/sync_engine.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/screen/attendance_screen.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_bloc.dart';

import 'injection_container.dart' as di;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'syncUploadTask') {
      await SyncEngine.runBackgroundSync();
    }
    return true;
  });
}

List<BlocProvider> get appProviders => [
      BlocProvider<AttendanceBloc>(create: (_) => di.sl<AttendanceBloc>()),
      BlocProvider<CameraBloc>(create: (_) => di.sl<CameraBloc>()),
    ];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UploadItemModelAdapter());
  await _requestLocationPermission();
  await _requestCameraPermission();
  await di.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await SyncEngine.registerBackgroundTask();
  runApp(const MyApp());
}

Future<void> _requestCameraPermission() async {
  final status = await Permission.camera.status;
  if (status.isDenied) {
    await Permission.camera.request();
  }
}

Future<void> _requestLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Intelligent Machines',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AttendanceScreen(),
      ),
    );
  }
}
