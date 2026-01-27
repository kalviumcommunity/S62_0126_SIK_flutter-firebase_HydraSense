import 'package:flutter/material.dart';
import '../services/safety_service.dart';

class SafetyAlertBanner extends StatelessWidget {
  final SafetyCheckResult safetyResult;
  final VoidCallback? onTap;

  const SafetyAlertBanner({
    super.key,
    required this.safetyResult,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDanger = safetyResult.status == SafetyStatus.inDangerZone;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red[50] : Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDanger ? Colors.red : Colors.orange,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isDanger ? Icons.warning_amber : Icons.info,
              color: isDanger ? Colors.red : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDanger
                        ? '🚨 FLOOD ALERT FOR YOUR AREA'
                        : '⚠️ FLOOD ADVISORY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDanger ? Colors.red : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    safetyResult.message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
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

    switch (safetyResult.status) {
      case SafetyStatus.locationDisabled:
        statusColor = Colors.grey;
        statusIcon = Icons.location_off;
        statusText = 'LOCATION UNAVAILABLE';
        break;

      case SafetyStatus.inDangerZone:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusText = 'FLOOD RISK IN YOUR AREA';
        break;

      case SafetyStatus.moderate:
        statusColor = Colors.orange;
        statusIcon = Icons.info;
        statusText = 'MODERATE RISK';
        break;

      case SafetyStatus.safe:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'YOU ARE SAFE';
        break;

      case SafetyStatus.unknown:
        statusColor = Colors.blueGrey;
        statusIcon = Icons.help;
        statusText = 'SAFETY STATUS UNKNOWN';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  safetyResult.userDistrict != null
                      ? 'Location: ${safetyResult.userDistrict}'
                      : safetyResult.message,
                  style: TextStyle(
                    color: statusColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
