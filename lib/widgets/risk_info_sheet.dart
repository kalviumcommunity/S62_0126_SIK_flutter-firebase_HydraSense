import 'package:flutter/material.dart';

void showRiskInfoSheet({
  required BuildContext context,
  required String districtName,
  required String currentRisk,
  String? predictedRisk,
  String? predictionWindow,
  required DateTime lastUpdated,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              districtName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _infoRow('Current Risk', currentRisk),

            if (predictedRisk != null)
              _infoRow('Predicted Risk', predictedRisk),

            if (predictionWindow != null)
              _infoRow('Prediction Window', predictionWindow),

            _infoRow(
              'Last Updated',
              _formatTime(lastUpdated),
            ),
          ],
        ),
      );
    },
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
