import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FloodZonesLayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        CircleMarker(
          point: center,
          radius: currentRadius,
          useRadiusInMeter: true,
          color: color.withOpacity(isSelected ? 0.35 : 0.25),
          borderColor: color,
          borderStrokeWidth: isSelected ? 3 : 2,
        ),
        if (predictedRadius != null && predictedRadius! > currentRadius)
          CircleMarker(
            point: center,
            radius: predictedRadius!,
            useRadiusInMeter: true,
            color: color.withOpacity(isSelected ? 0.2 : 0.15),
            borderColor: color.withOpacity(0.4),
            borderStrokeWidth: 1,
          ),
      ],
    );
  }
}