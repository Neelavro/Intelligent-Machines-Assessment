import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_bloc.dart';
import 'package:intelligent_machines_assessment/presentation/attendance/bloc/attendance_event.dart';

const primary = Color(0xFF013E5B);
const textTertiary = Color(0xFF94A3B8);
const disabled = Color(0xFFD1D5DB);
const borderDashed = Color(0xFFCBD5E1);

class MarkAttendanceButton extends StatelessWidget {
  final bool canMarkAttendance;
  final bool isLoading;

  const MarkAttendanceButton({
    super.key,
    required this.canMarkAttendance,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(color: borderDashed, radius: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          children: [
            if (!canMarkAttendance) ...[
              const Icon(Icons.lock_outline, color: textTertiary, size: 28),
              const SizedBox(height: 18),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canMarkAttendance && !isLoading
                    ? () => context
                        .read<AttendanceBloc>()
                        .add(const AttendanceMarkAttendanceEvent())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: disabled,
                  disabledForegroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Mark Attendance',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'AVAILABLE 09:00 AM - 10:30 AM',
              style: TextStyle(
                color: textTertiary,
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 1.5,
    this.radius = 16,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));
    final dashed = Path();

    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        dashed.addPath(
          m.extractPath(d, math.min(d + dashWidth, m.length)),
          Offset.zero,
        );
        d += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace ||
      old.radius != radius;
}
