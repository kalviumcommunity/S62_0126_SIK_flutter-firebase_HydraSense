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
          width: 90,
          height: 90,
          child: AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, _) {
              final t = pulseAnimation.value;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // 🌊 Expanding radar wave
                  Container(
                    width: 70 + t * 30,
                    height: 70 + t * 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF007AFF)
                          .withValues(alpha: (1 - t) * 0.12),
                    ),
                  ),

                  // 🌀 Rotating orbit ring
                  Transform.rotate(
                    angle: t * 2 * pi,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF5AC8FA)
                              .withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // 🔵 Core glow
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF007AFF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007AFF)
                              .withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // 📍 Inner dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
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
