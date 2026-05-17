import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_machines_assessment/domain/entities/upload_item_entity.dart';

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraPermissionDenied extends CameraState {}

class CameraError extends CameraState {
  final String message;
  CameraError(this.message);
}

class CameraReady extends CameraState {
  final CameraController? controller;
  final List<String> capturedPaths;
  final List<UploadItemEntity> uploadQueue;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final Offset? focusPoint;
  final bool isConnected;
  final bool hasUltraWide;
  final String? message;

  CameraReady({
    this.controller,
    this.capturedPaths = const [],
    this.uploadQueue = const [],
    this.zoomLevel = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 5.0,
    this.focusPoint,
    this.isConnected = true,
    this.hasUltraWide = false,
    this.message,
  });

  CameraReady copyWith({
    CameraController? controller,
    List<String>? capturedPaths,
    List<UploadItemEntity>? uploadQueue,
    double? zoomLevel,
    double? minZoom,
    double? maxZoom,
    Offset? focusPoint,
    bool clearFocus = false,
    bool? isConnected,
    bool? hasUltraWide,
    String? message,
    bool clearMessage = false,
  }) {
    return CameraReady(
      controller: controller ?? this.controller,
      capturedPaths: capturedPaths ?? this.capturedPaths,
      uploadQueue: uploadQueue ?? this.uploadQueue,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      focusPoint: clearFocus ? null : (focusPoint ?? this.focusPoint),
      isConnected: isConnected ?? this.isConnected,
      hasUltraWide: hasUltraWide ?? this.hasUltraWide,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
