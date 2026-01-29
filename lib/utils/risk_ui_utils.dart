import 'dart:math' as math;
import 'package:flutter/material.dart';


Color getRiskColor(String riskLevel) {
  switch (riskLevel) {
    case 'LOW':
      return const Color(0xFF34C759);
    case 'MODERATE':
      return const Color(0xFFFF9500);
    case 'HIGH':
      return const Color(0xFFFF3B30);
    default:
      return const Color(0xFF8E8E93);
  }
}

Color getRiskGradientStart(String riskLevel) {
  return getRiskColor(riskLevel).withValues(alpha: 0.35);
}

Color getRiskGradientEnd(String riskLevel) {
  return getRiskColor(riskLevel).withValues(alpha: 0.08);
}


IconData getRiskIcon(String riskLevel) {
  switch (riskLevel) {
    case 'LOW':
      return Icons.check_circle_rounded;
    case 'MODERATE':
      return Icons.warning_amber_rounded;
    case 'HIGH':
      return Icons.error_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}

String getRiskExplanation(String riskLevel) {
  switch (riskLevel) {
    case 'LOW':
      return 'No active flooding detected. Conditions are stable.';
    case 'MODERATE':
      return 'Flooding is possible in low-lying areas. Stay alert.';
    case 'HIGH':
      return 'Severe flood conditions detected. Avoid affected areas.';
    default:
      return 'Risk level cannot be determined at this time.';
  }
}

String getPredictionExplanation() {
  return 'This is a projection based on forecast rain and may change as conditions update.';
}

/// --------------------
/// PREMIUM ANIMATED ICON
/// --------------------

class AnimatedRiskIcon extends StatefulWidget {
  final String riskLevel;
  final double size;

  const AnimatedRiskIcon({
    super.key,
    required this.riskLevel,
    this.size = 28,
  });

  @override
  State<AnimatedRiskIcon> createState() => _AnimatedRiskIconState();
}

class _AnimatedRiskIconState extends State<AnimatedRiskIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isHigh => widget.riskLevel == 'HIGH';
  bool get _isModerate => widget.riskLevel == 'MODERATE';

  @override
  Widget build(BuildContext context) {
    final baseColor = getRiskColor(widget.riskLevel);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final pulse = 0.9 + (math.sin(_controller.value * 2 * math.pi) * 0.1);
        final glowOpacity = _isHigh
            ? 0.45
            : _isModerate
                ? 0.25
                : 0.12;

        return Transform.scale(
          scale: _isHigh ? pulse : 1.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔴 Glow halo
              Container(
                width: widget.size * 2.2,
                height: widget.size * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withValues(alpha: glowOpacity),
                      baseColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              // 🟢 Icon
              Icon(
                getRiskIcon(widget.riskLevel),
                size: widget.size,
                color: baseColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
