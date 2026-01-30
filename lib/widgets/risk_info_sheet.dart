import 'package:flutter/material.dart';
import '../models/risk_state.dart';
import '../utils/risk_ui_utils.dart';

void showRiskInfoSheet({
  required BuildContext context,
  required RiskState state,
}) {
  // print('📋 RISK INFO SHEET OPENED:');
  // print('  districtId = ${state.districtId}');
  // print('  currentRisk = ${state.currentRisk}');
  // print('  center = ${state.centerLat}, ${state.centerLng}');

  final now = DateTime.now();
  final predictionValid = state.predictionExpiresAt != null &&
      now.isBefore(state.predictionExpiresAt!);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AnimatedRiskIcon(
                                  riskLevel: state.currentRisk,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.districtId.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoSection(
                              icon: Icons.location_on,
                              title: 'Location',
                              value:
                                  '${state.centerLat.toStringAsFixed(4)}, '
                                  '${state.centerLng.toStringAsFixed(4)}',
                            ),
                            const SizedBox(height: 24),
                            _buildRiskSection(state),
                            if (_hasAnyMetrics(state)) ...[
                              const SizedBox(height: 24),
                              _buildMetricsSection(state),
                            ],
                            if (predictionValid &&
                                state.predictedRisk != null &&
                                state.predictionWindow != null &&
                                state.predictedRadius != null) ...[
                              const SizedBox(height: 24),
                              _buildPredictionSection(state),
                            ],
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              icon: Icons.access_time,
                              title: 'Last Updated',
                              value: _formatTime(state.updatedAt),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _buildInfoSection({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF007AFF), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildRiskSection(RiskState state) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          getRiskGradientStart(state.currentRisk),
          getRiskGradientEnd(state.currentRisk),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: getRiskColor(state.currentRisk).withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getRiskColor(state.currentRisk).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: AnimatedRiskIcon(
                riskLevel: state.currentRisk,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'CURRENT RISK: ${state.currentRisk.toUpperCase()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: getRiskColor(state.currentRisk),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          getRiskExplanation(state.currentRisk),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        if (state.confidence != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confidence Level',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: state.confidence!,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        getRiskColor(state.currentRisk),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(state.confidence! * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: getRiskColor(state.currentRisk),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildMetricsSection(RiskState state) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why is this area at risk?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (state.rainfallLast24h != null)
          _metricTile(
            'Rainfall (last 24 hours)',
            '${state.rainfallLast24h!.toStringAsFixed(1)} mm',
            'Heavy rainfall increases runoff and flooding risk.',
            Icons.grain,
          ),
        if (state.forecastRain6h != null)
          _metricTile(
            'Forecast Rain (next 6 hours)',
            '${state.forecastRain6h!.toStringAsFixed(1)} mm',
            'Upcoming rain can worsen flooding before water recedes.',
            Icons.cloud,
          ),
        if (state.riverDischarge != null)
          _metricTile(
            'River Discharge (flow rate)',
            state.riverDischarge!.toStringAsFixed(1),
            'Higher flow increases chances of river overflow.',
            Icons.water,
          ),
      ],
    ),
  );
}

Widget _metricTile(
  String title,
  String value,
  String explanation,
  IconData icon,
) {
  return Theme(
    data: ThemeData().copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF007AFF)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            explanation,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPredictionSection(RiskState state) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFF9500).withValues(alpha: 0.1),
          const Color(0xFFFF3B30).withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFFF9500).withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _predictionRow(
          'Risk Level',
          state.predictedRisk!.toUpperCase(),
          const Color(0xFFFF3B30),
        ),
        _predictionRow(
          'Time Frame',
          'Next ${state.predictionWindow} hours',
          const Color(0xFF007AFF),
        ),
        _predictionRow(
          'Possible Spread',
          '${(state.predictedRadius! / 1000).toStringAsFixed(1)} km radius',
          const Color(0xFF5856D6),
        ),
      ],
    ),
  );
}

Widget _predictionRow(String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

bool _hasAnyMetrics(RiskState state) {
  return state.rainfallLast24h != null ||
      state.forecastRain6h != null ||
      state.riverDischarge != null;
}
