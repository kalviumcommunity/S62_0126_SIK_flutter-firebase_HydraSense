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
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + pulseAnimation.value * 0.6,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF007AFF).withValues(
                              alpha: 0.3 * (1 - pulseAnimation.value),
                            ),
                            const Color(0xFF007AFF)
                                .withValues(alpha: 0),
                          ],
                          stops: const [0.1, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Middle pulse ring
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + pulseAnimation.value * 0.4,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF007AFF).withValues(
                          alpha: 0.2 * (1 - pulseAnimation.value),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Location pin
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF007AFF),
                      Color(0xFF5856D6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF)
                          .withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
