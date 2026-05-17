import 'package:flutter/material.dart';

class ZoomPillRow extends StatelessWidget {
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final bool hasUltraWide;
  final ValueChanged<double> onSelect;
  final VoidCallback onUltraWideUnavailable;

  const ZoomPillRow({
    super.key,
    required this.zoomLevel,
    required this.minZoom,
    required this.maxZoom,
    required this.hasUltraWide,
    required this.onSelect,
    required this.onUltraWideUnavailable,
  });

  List<({String label, double value})> get _zooms => [
        (label: '0.5x', value: 0.5),
        (label: '1x', value: 1.0.clamp(minZoom, maxZoom)),
        (label: '2x', value: 2.0.clamp(minZoom, maxZoom)),
      ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _zooms.map((z) {
        final isUltraWide = z.value == 0.5;
        final isDisabled = isUltraWide && !hasUltraWide;
        final isSelected = !isDisabled && (zoomLevel - z.value).abs() < 0.05;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: isDisabled
                ? onUltraWideUnavailable
                : () => onSelect(z.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isSelected ? 44 : 36,
              height: isSelected ? 44 : 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.black.withOpacity(isDisabled ? 0.15 : 0.35),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  z.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.black
                        : Colors.white.withOpacity(isDisabled ? 0.3 : 1.0),
                    fontWeight: FontWeight.w600,
                    fontSize: isSelected ? 13 : 11,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
