import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FloodZonesLayer extends StatefulWidget {
  final LatLng center;
  final double currentRadius;
  final double? predictedRadius;
  final Color color;
  final bool isSelected;

  const FloodZonesLayer({
    super.key,
    required this.center,
    required this.currentRadius,
    required this.predictedRadius,
    required this.color,
    required this.isSelected,
  });

  @override
  State<FloodZonesLayer> createState() => _FloodZonesLayerState();
}

class _FloodZonesLayerState extends State<FloodZonesLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) {
        final pulseStrength = widget.isSelected ? 1.0 : 0.6;
        final pulseValue = 0.85 + (_pulse.value * 0.15 * pulseStrength);

        return CircleLayer(
          circles: [
            /// 🌊 OUTER HALO (water spread / pressure)
            CircleMarker(
              point: widget.center,
              radius: widget.currentRadius * 1.12,
              useRadiusInMeter: true,
              color: base.withValues(alpha: 0.08),
              borderStrokeWidth: 0,
            ),

            /// 🌊 MAIN FLOOD BODY
            CircleMarker(
              point: widget.center,
              radius: widget.currentRadius * pulseValue,
              useRadiusInMeter: true,
              color: base.withValues(
                alpha: widget.isSelected ? 0.35 : 0.22,
              ),
              borderColor: base.withValues(
                alpha: widget.isSelected ? 0.9 : 0.6,
              ),
              borderStrokeWidth: widget.isSelected ? 3.5 : 2.0,
            ),

            /// 🔮 PREDICTED EXPANSION (if any)
            if (widget.predictedRadius != null)
              CircleMarker(
                point: widget.center,
                radius: widget.predictedRadius!,
                useRadiusInMeter: true,
                color: base.withValues(alpha: 0.06),
                borderColor: base.withValues(alpha: 0.35),
                borderStrokeWidth: 1.5,
              ),
          ],
        );
      },
    );
  }
}
