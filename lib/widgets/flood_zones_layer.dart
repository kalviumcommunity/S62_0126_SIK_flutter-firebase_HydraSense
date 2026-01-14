import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FloodZonesLayer extends StatelessWidget {
  final LatLng center;
  final double currentRadius;
  final double? predictedRadius;
  final Color color;

  const FloodZonesLayer({
    super.key,
    required this.center,
    required this.currentRadius,
    required this.predictedRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        CircleMarker(
          point: center,
          radius: currentRadius,
          useRadiusInMeter: true,
          color: color.withOpacity(0.25),
          borderColor: color,
          borderStrokeWidth: 2,
        ),
        if (predictedRadius != null && predictedRadius! > currentRadius)
          CircleMarker(
            point: center,
            radius: predictedRadius!,
            useRadiusInMeter: true,
            color: color.withOpacity(0.15),
            borderStrokeWidth: 1,
            borderColor: color.withOpacity(0.4),
          ),
      ],
    );
  }
}
