import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intelligent_machines_assessment/data/datasource/camera_local_datasource.dart';
import 'package:intelligent_machines_assessment/data/datasource/camera_remote_datasource.dart';
import 'package:intelligent_machines_assessment/data/model/upload_item_model_adapter.dart';
import 'package:intelligent_machines_assessment/data/repository/camera_repository_impl.dart';

const _syncTaskName = 'syncUploadTask';
const _syncTaskTag = 'upload_sync';

class SyncEngine {
  final Connectivity connectivity;
  StreamSubscription<bool>? _sub;

  SyncEngine({required this.connectivity});

  Stream<bool> get connectivityStream => connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  void startWatching(VoidCallback onConnectionRestored) {
    _sub?.cancel();
    _sub = connectivityStream.listen((isConnected) {
      if (isConnected) onConnectionRestored();
    });
  }

  void stopWatching() {
    _sub?.cancel();
    _sub = null;
  }

  static Future<void> registerBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      _syncTaskName,
      _syncTaskName,
      tag: _syncTaskTag,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> runBackgroundSync() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UploadItemModelAdapter());
    }
    final localDs = CameraLocalDatasource();
    final remoteDs = CameraRemoteDatasource();
    final repo = CameraRepositoryImpl(
      cameraLocalDatasource: localDs,
      cameraRemoteDatasource: remoteDs,
    );
    await repo.syncPendingUploads();
    await localDs.close();
  }
}
