import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intelligent_machines_assessment/core/network_info.dart';
import 'package:intelligent_machines_assessment/core/sync_engine.dart';
import 'package:intelligent_machines_assessment/domain/usecases/camera_usecase.dart';

import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraUsecase cameraUsecase;
  final NetworkInfo networkInfo;
  final SyncEngine syncEngine;

  CameraController? _controller;
  CameraDescription? _mainCamera;

  Timer? _focusTimer;
  StreamSubscription<bool>? _connectivitySub;

  CameraBloc({
    required this.cameraUsecase,
    required this.networkInfo,
    required this.syncEngine,
  }) : super(CameraInitial()) {
    on<CameraInitializedEvent>(_onInitialized);
    on<CameraDisposeEvent>(_onDispose);
    on<CameraZoomChangedEvent>(_onZoomChanged);
    on<CameraFocusedEvent>(_onFocused);
    on<CameraFocusClearedEvent>(_onFocusCleared);
    on<CameraPhotoTakenEvent>(_onPhotoTaken);
    on<CameraUploadBatchEvent>(_onUploadBatch);
    on<CameraLoadQueueEvent>(_onLoadQueue);
    on<CameraConnectivityChangedEvent>(_onConnectivityChanged);
    on<CameraSyncTriggerEvent>(_onSyncTrigger);
  }

  Future<void> _onInitialized(
    CameraInitializedEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (await Permission.camera.isPermanentlyDenied) {
      emit(CameraPermissionDenied());
      return;
    }

    emit(CameraLoading());

    try {
      final cameras = await availableCameras();
      final backCameras = cameras
          .where((c) => c.lensDirection == CameraLensDirection.back)
          .toList();

      _mainCamera = backCameras.isNotEmpty ? backCameras.first : cameras.first;

      _controller?.dispose();
      _controller = CameraController(
        _mainCamera!,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();

      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();

      final isConnected = await networkInfo.isConnected;
      final queueResult = await cameraUsecase.getUploadQueue();
      final queue = queueResult.fold((_) => <dynamic>[], (items) => items);

      _connectivitySub?.cancel();
      _connectivitySub = syncEngine.connectivityStream.listen((connected) {
        add(CameraConnectivityChangedEvent(connected));
        if (connected) add(const CameraSyncTriggerEvent());
      });

      emit(CameraReady(
        controller: _controller,
        minZoom: minZoom,
        maxZoom: maxZoom,
        zoomLevel: minZoom > 1.0 ? minZoom : 1.0,
        isConnected: isConnected,
        hasUltraWide: false,
        uploadQueue: List.from(queue),
      ));
    } catch (e) {
      emit(CameraError('Failed to initialize camera: $e'));
    }
  }

  Future<void> _onDispose(
    CameraDisposeEvent event,
    Emitter<CameraState> emit,
  ) async {
    _focusTimer?.cancel();
    _connectivitySub?.cancel();
    emit(CameraInitial());
    final controller = _controller;
    _controller = null;
    await controller?.pausePreview();
    await controller?.dispose();
  }

  Future<void> _onZoomChanged(
    CameraZoomChangedEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady) return;
    final current = state as CameraReady;
    final clamped = event.zoom.clamp(current.minZoom, current.maxZoom);
    await _controller?.setZoomLevel(clamped);
    emit(current.copyWith(zoomLevel: clamped));
  }

  Future<void> _onFocused(
    CameraFocusedEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady) return;
    final current = state as CameraReady;

    final x = (event.point.dx / event.previewWidth).clamp(0.0, 1.0);
    final y = (event.point.dy / event.previewHeight).clamp(0.0, 1.0);

    try {
      await _controller?.setFocusPoint(Offset(x, y));
      await _controller?.setExposurePoint(Offset(x, y));
    } catch (_) {}

    emit(current.copyWith(focusPoint: event.point));

    _focusTimer?.cancel();
    _focusTimer = Timer(
      const Duration(seconds: 2),
      () => add(const CameraFocusClearedEvent()),
    );
  }

  void _onFocusCleared(CameraFocusClearedEvent event, Emitter<CameraState> emit) {
    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(clearFocus: true));
    }
  }

  Future<void> _onPhotoTaken(
    CameraPhotoTakenEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady) return;
    final current = state as CameraReady;

    try {
      if (_controller == null) return;
      final xFile = await _controller!.takePicture();
      emit(current.copyWith(capturedPaths: [...current.capturedPaths, xFile.path]));
    } catch (_) {}
  }

  Future<void> _onUploadBatch(
    CameraUploadBatchEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady) return;
    final current = state as CameraReady;
    if (current.capturedPaths.isEmpty) return;

    final result = await cameraUsecase.enqueueImages(current.capturedPaths);

    await result.fold(
      (error) async => emit(current.copyWith(message: error)),
      (_) async {
        final queueResult = await cameraUsecase.getUploadQueue();
        final queue = queueResult.fold((_) => current.uploadQueue, (q) => q);
        emit(current.copyWith(
          capturedPaths: [],
          uploadQueue: queue,
          message: 'Batch queued for upload.',
        ));
        final isConnected = await networkInfo.isConnected;
        if (isConnected) add(const CameraSyncTriggerEvent());
      },
    );
  }

  Future<void> _onLoadQueue(
    CameraLoadQueueEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady) return;
    final current = state as CameraReady;
    final result = await cameraUsecase.getUploadQueue();
    result.fold((_) {}, (queue) => emit(current.copyWith(uploadQueue: queue)));
  }

  void _onConnectivityChanged(
    CameraConnectivityChangedEvent event,
    Emitter<CameraState> emit,
  ) {
    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(isConnected: event.isConnected));
    }
  }

  Future<void> _onSyncTrigger(
    CameraSyncTriggerEvent event,
    Emitter<CameraState> emit,
  ) async {
    await cameraUsecase.syncPendingUploads();
    if (state is CameraReady) {
      final queueResult = await cameraUsecase.getUploadQueue();
      final current = state as CameraReady;
      queueResult.fold((_) {}, (queue) => emit(current.copyWith(uploadQueue: queue)));
    }
  }

  @override
  Future<void> close() {
    _focusTimer?.cancel();
    _connectivitySub?.cancel();
    _controller?.dispose();
    return super.close();
  }
}
