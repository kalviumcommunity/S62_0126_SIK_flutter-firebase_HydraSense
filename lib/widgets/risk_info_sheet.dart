import 'package:flutter/material.dart';
import '../models/risk_state.dart';
import '../utils/risk_ui_utils.dart';

void showRiskInfoSheet({
  required BuildContext context,
  required RiskState state,
}) {
  final now = DateTime.now();

  final predictionValid =
      state.predictionExpiresAt != null &&
      now.isBefore(state.predictionExpiresAt!);

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
              state.districtId.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _infoRow(
              'Location',
              '${state.centerLat.toStringAsFixed(3)}, '
              '${state.centerLng.toStringAsFixed(3)}',
            ),

            const Divider(height: 24),

            _infoRow('Current Risk', state.currentRisk),
            _infoRow(
              'Meaning',
              getRiskExplanation(state.currentRisk),
            ),

            if (state.confidence != null && state.confidence! >= 0.2)
              _infoRow(
                'Confidence',
                '${(state.confidence! * 100).toStringAsFixed(0)}%',
              ),

            if (state.confidence != null && state.confidence! < 0.2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Limited data available for confidence estimation.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

            if (predictionValid &&
                state.predictedRisk != null &&
                state.predictionWindow != null &&
                state.predictedRadius != null) ...[
              const Divider(height: 24),

              _infoRow('Predicted Risk', state.predictedRisk!),

              _infoRow(
                'Prediction Window',
                'Next ${state.predictionWindow} hours',
              ),

              _infoRow(
                'Possible Spread',
                '${(state.predictedRadius! / 1000).toStringAsFixed(1)} km radius',
              ),

              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  getPredictionExplanation(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],

            const Divider(height: 24),

            _infoRow(
              'Last Updated',
              _formatTime(state.updatedAt),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
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
