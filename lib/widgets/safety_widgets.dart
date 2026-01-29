import 'package:flutter/material.dart';
import '../services/safety_service.dart';

class SafetyAlertBanner extends StatefulWidget {
  final SafetyCheckResult safetyResult;
  final VoidCallback? onTap;

  const SafetyAlertBanner({
    super.key,
    required this.safetyResult,
    this.onTap,
  });

  @override
  State<SafetyAlertBanner> createState() => _SafetyAlertBannerState();
}

class _SafetyAlertBannerState extends State<SafetyAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.02), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 50),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDanger =
        widget.safetyResult.status == SafetyStatus.inDangerZone;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDanger
                  ? const [
                      Color(0xFFFF3B30),
                      Color(0xFFFF2D55),
                    ]
                  : const [
                      Color(0xFFFF9500),
                      Color(0xFFFFCC00),
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (isDanger
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFFFF9500))
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDanger ? Icons.warning_amber : Icons.info,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDanger ? '🚨 CRITICAL ALERT' : '⚠️ ADVISORY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'FLOOD ALERT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.safetyResult.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SafetyStatusIndicator extends StatelessWidget {
  final SafetyCheckResult safetyResult;

  const SafetyStatusIndicator({
    super.key,
    required this.safetyResult,
  });

  @override
  Widget build(BuildContext context) {
    late final Color statusColor;
    late final IconData statusIcon;
    late final String statusText;
    late final String statusSubtitle;

    switch (safetyResult.status) {
      case SafetyStatus.locationDisabled:
        statusColor = const Color(0xFF8E8E93);
        statusIcon = Icons.location_off_outlined;
        statusText = 'LOCATION UNAVAILABLE';
        statusSubtitle = 'Enable location services for safety alerts';
        break;

      case SafetyStatus.inDangerZone:
        statusColor = const Color(0xFFFF3B30);
        statusIcon = Icons.warning_outlined;
        statusText = 'FLOOD RISK DETECTED';
        statusSubtitle =
            safetyResult.userDistrict ?? 'You are in an active flood zone';
        break;

      case SafetyStatus.moderate:
        statusColor = const Color(0xFFFF9500);
        statusIcon = Icons.info_outline;
        statusText = 'MODERATE RISK AREA';
        statusSubtitle =
            safetyResult.userDistrict ?? 'Stay alert and monitor updates';
        break;

      case SafetyStatus.safe:
        statusColor = const Color(0xFF34C759);
        statusIcon = Icons.check_circle_outline;
        statusText = 'YOU ARE SAFE';
        statusSubtitle =
            safetyResult.userDistrict ?? 'No flood risks detected';
        break;

      case SafetyStatus.unknown:
        statusColor = const Color(0xFF5AC8FA);
        statusIcon = Icons.help_outline;
        statusText = 'STATUS UNKNOWN';
        statusSubtitle = 'Checking safety information...';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.15),
                  statusColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
