import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class CameraInitializedEvent extends CameraEvent {
  const CameraInitializedEvent();
}

class CameraDisposeEvent extends CameraEvent {
  const CameraDisposeEvent();
}

class CameraZoomChangedEvent extends CameraEvent {
  final double zoom;
  const CameraZoomChangedEvent(this.zoom);

  @override
  List<Object?> get props => [zoom];
}

class CameraFocusedEvent extends CameraEvent {
  final Offset point;
  final double previewWidth;
  final double previewHeight;

  const CameraFocusedEvent(this.point, this.previewWidth, this.previewHeight);

  @override
  List<Object?> get props => [point, previewWidth, previewHeight];
}

class CameraFocusClearedEvent extends CameraEvent {
  const CameraFocusClearedEvent();
}

class CameraPhotoTakenEvent extends CameraEvent {
  const CameraPhotoTakenEvent();
}

class CameraUploadBatchEvent extends CameraEvent {
  const CameraUploadBatchEvent();
}

class CameraLoadQueueEvent extends CameraEvent {
  const CameraLoadQueueEvent();
}

class CameraConnectivityChangedEvent extends CameraEvent {
  final bool isConnected;
  const CameraConnectivityChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class CameraSyncTriggerEvent extends CameraEvent {
  const CameraSyncTriggerEvent();
}
