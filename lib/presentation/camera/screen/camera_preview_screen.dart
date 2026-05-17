import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_event.dart';
import 'package:intelligent_machines_assessment/presentation/camera/bloc/camera_state.dart';
import 'package:intelligent_machines_assessment/presentation/camera/screen/upload_manager_screen.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/batch_thumbnail.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/circle_icon_button.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/focus_indicator.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/shutter_button.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/vertical_zoom_slider.dart';
import 'package:intelligent_machines_assessment/presentation/camera/widgets/zoom_pill_row.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  double _baseZoom = 1.0;
  late final CameraBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CameraBloc>();
    _bloc.add(const CameraInitializedEvent());
  }

  @override
  void dispose() {
    _bloc.add(const CameraDisposeEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraBloc, CameraState>(
      listener: (context, state) {
        if (state is CameraReady && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CameraState state) {
    if (state is CameraPermissionDenied) {
      return _buildPermissionDenied(context);
    }
    if (state is CameraLoading || state is CameraInitial) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (state is CameraError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.white)),
      );
    }
    if (state is CameraReady) return _buildReadyUI(context, state);
    return const SizedBox.shrink();
  }

  Widget _buildPermissionDenied(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white54, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Denied',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Camera access has been permanently denied. Please enable it in Settings to use this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'OPEN SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyUI(BuildContext context, CameraReady state) {
    return Stack(
      children: [
        if (state.controller != null && state.controller!.value.isInitialized)
          _buildCameraPreview(context, state)
        else
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF3A5A52), Color(0xFF1F2F2C), Color(0xFF0F1818)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
        SafeArea(
          child: Stack(
            children: [
              // Top bar
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleIconButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      children: [
                        CircleIconButton(icon: Icons.flash_on, onTap: () {}),
                        const SizedBox(width: 12),
                        CircleIconButton(
                          icon: Icons.photo_library_outlined,
                          onTap: () => _openUploadManager(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // VISUAL label
              const Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'VISUAL',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Vertical zoom slider
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: VerticalZoomSlider(
                    value: state.zoomLevel,
                    min: state.minZoom,
                    max: state.maxZoom,
                    onChanged: (v) =>
                        context.read<CameraBloc>().add(CameraZoomChangedEvent(v)),
                  ),
                ),
              ),

              // No-connection banner
              if (!state.isConnected)
                Positioned(
                  top: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NO CONNECTION — IMAGES QUEUED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

              // LIVE VIEWING watermark
              Positioned(
                left: 0,
                right: 0,
                bottom: 160,
                child: Center(
                  child: Text(
                    'LIVE VIEWING',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 28,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ZoomPillRow(
                        zoomLevel: state.zoomLevel,
                        minZoom: state.minZoom,
                        maxZoom: state.maxZoom,
                        hasUltraWide: state.hasUltraWide,
                        onSelect: (zoom) =>
                            context.read<CameraBloc>().add(CameraZoomChangedEvent(zoom)),
                        onUltraWideUnavailable: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No ultra wide camera available on this device'),
                            duration: Duration(seconds: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BatchThumbnail(
                            count: state.capturedPaths.length,
                            onTap: () => _openUploadManager(context),
                          ),
                          ShutterButton(
                            onTap: () => context
                                .read<CameraBloc>()
                                .add(const CameraPhotoTakenEvent()),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: state.capturedPaths.isEmpty
                              ? null
                              : () => context
                                  .read<CameraBloc>()
                                  .add(const CameraUploadBatchEvent()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E6BFF),
                            disabledBackgroundColor:
                                const Color(0xFF2E6BFF).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(
                            Icons.upload_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: Text(
                            'UPLOAD BATCH (${state.capturedPaths.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Focus indicator
              if (state.focusPoint != null)
                Positioned(
                  left: state.focusPoint!.dx - 30,
                  top: state.focusPoint!.dy - 30,
                  child: const FocusIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview(BuildContext context, CameraReady state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onScaleStart: (_) => _baseZoom = state.zoomLevel,
          onScaleUpdate: (details) {
            final newZoom =
                (_baseZoom * details.scale).clamp(state.minZoom, state.maxZoom);
            context.read<CameraBloc>().add(CameraZoomChangedEvent(newZoom));
          },
          onTapUp: (details) {
            context.read<CameraBloc>().add(
              CameraFocusedEvent(
                details.localPosition,
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            );
          },
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: state.controller!.value.previewSize?.height ??
                    constraints.maxWidth,
                height: state.controller!.value.previewSize?.width ??
                    constraints.maxHeight,
                child: CameraPreview(state.controller!),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openUploadManager(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CameraBloc>(),
          child: const UploadManagerScreen(),
        ),
      ),
    );
  }
}
