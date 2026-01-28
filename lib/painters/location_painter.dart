import 'dart:math' as math;
import 'package:flutter/material.dart';

// Wave painter
class LocationWavePainter extends CustomPainter {
  final double animation;

  LocationWavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.06);

    for (var i = 0; i < 6; i++) {
      final path = Path();
      final yOffset = size.height * 0.1 + (i * 50);
      final waveHeight = 15.0 - (i * 1.5);
      final frequency = 180.0 + (i * 25);

      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset +
            math.sin(
              (x / frequency) * 2 * math.pi +
                  (animation * 2 * math.pi) +
                  (i * 0.7),
            ) *
                waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Sand painter
class LocationSandPainter extends CustomPainter {
  final double animation;

  LocationSandPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 190, 150, 70).withValues(alpha:0.12);

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final yOffset = size.height * 0.7 + (i * 40);
      final duneHeight = 30.0 - (i * 6);
      final frequency = 220.0 + (i * 35);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset +
            math.sin(
              (x / frequency) * math.pi +
                  (animation * math.pi * 0.25) +
                  (i * 0.5),
            ) *
                duneHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
