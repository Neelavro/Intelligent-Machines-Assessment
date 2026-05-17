import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intelligent_machines_assessment/core/app_toast.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_event.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_state.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/widgets/distance_badge.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/widgets/mark_attendance_button.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/widgets/office_location_card.dart';
import 'package:intelligent_machines_assessment/presentation/camera/screen/camera_preview_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const primary = Color(0xFF013E5B);
  static const allowedRadius = 50.0;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const AttendanceInitialLoadEvent());
  }

  Widget _buildPermissionDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_outlined, color: primary, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Location Permission Denied',
                style: TextStyle(
                  color: primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Location access has been permanently denied. Please enable it in Settings to mark attendance.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => openAppSettings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listenWhen: (_, current) =>
          current is AttendanceSuccess || current is AttendanceError,
      listener: (context, state) {
        if (state is AttendanceSuccess) AppToast.success(state.message);
        if (state is AttendanceError) AppToast.error(state.message);
      },
      builder: (context, state) {
        if (state is AttendancePermissionDenied) {
          return _buildPermissionDenied(context);
        }

        final isLoading = state is AttendanceLoading;
        final loaded = state is AttendanceLoaded ? state : null;

        final distanceInMeters = loaded?.distanceInMeters;
        final inRange =
            distanceInMeters != null && distanceInMeters <= allowedRadius;
        final canMark = loaded?.officeLocation != null &&
            loaded?.currentLocation != null &&
            inRange;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: primary, size: 28),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: const Text(
              'Attendance',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: primary),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CameraPreviewScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OfficeLocationCard(
                  officeLocation: loaded?.officeLocation,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 28),
                DistanceBadge(
                  distanceInMeters: distanceInMeters,
                  allowedRadius: allowedRadius,
                  inRange: inRange,
                  hasOfficeLocation: loaded?.officeLocation != null,
                ),
                const SizedBox(height: 28),
                MarkAttendanceButton(
                  canMarkAttendance: canMark,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
