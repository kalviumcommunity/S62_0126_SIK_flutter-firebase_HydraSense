import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserLocationMarker extends StatelessWidget {
  final LatLng location;
  final Animation<double> pulseAnimation;

  const UserLocationMarker({
    super.key,
    required this.location,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: location,
          width: 60,
          height: 60,
          child: AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60 * (1 + pulseAnimation.value * 0.5),
                    height: 60 * (1 + pulseAnimation.value * 0.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(
                        0.3 * (1 - pulseAnimation.value),
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
