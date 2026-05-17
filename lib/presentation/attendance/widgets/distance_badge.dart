import 'dart:math' as math;
import 'package:flutter/material.dart';

const green = Color(0xFF10B981);
const danger = Color(0xFFEF4444);
const textPrimary = Color(0xFF050505);
const textTertiary = Color(0xFF94A3B8);
const bgTrack = Color(0xFFF3F4F6);

class DistanceBadge extends StatelessWidget {
  final double? distanceInMeters;
  final double allowedRadius;
  final bool inRange;
  final bool hasOfficeLocation;

  const DistanceBadge({
    super.key,
    required this.distanceInMeters,
    required this.allowedRadius,
    required this.inRange,
    required this.hasOfficeLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (distanceInMeters == null) {
      if (!hasOfficeLocation) return const SizedBox.shrink();
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Fetching location...',
            style: TextStyle(color: textTertiary, fontSize: 13),
          ),
        ],
      );
    }

    final double progress = inRange
        ? (1 - (distanceInMeters! / allowedRadius)).clamp(0.0, 1.0)
        : (distanceInMeters! / (allowedRadius * 4)).clamp(0.1, 0.95);
    final Color arcColor = inRange ? green : danger;

    return Column(
      children: [
        SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(128, 128),
                painter: ArcPainter(progress: progress, color: arcColor),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${distanceInMeters!.toInt()}m',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'AWAY',
                    style: TextStyle(
                      fontSize: 11,
                      color: textTertiary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: arcColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: arcColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                inRange ? 'IN RANGE' : 'OUT OF RANGE',
                style: TextStyle(
                  color: arcColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          inRange
              ? 'You are ${distanceInMeters!.toInt()}m from the office — within check-in range'
              : 'You are ${distanceInMeters!.toInt()}m away from the office',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: inRange ? green : danger,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Move within ${allowedRadius.toInt()} meters to enable check-in',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textTertiary,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class ArcPainter extends CustomPainter {
  ArcPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    final track = Paint()
      ..color = bgTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant ArcPainter old) =>
      old.progress != progress || old.color != color;
}
