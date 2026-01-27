import 'package:flutter/material.dart';

Color getRiskColor(String riskLevel) {
  switch (riskLevel) {
    case 'LOW':
      return Colors.green;
    case 'MODERATE':
      return Colors.orange;
    case 'HIGH':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData getRiskIcon(String riskLevel) {
  switch (riskLevel) {
    case 'LOW':
      return Icons.check_circle;
    case 'MODERATE':
      return Icons.warning_amber_rounded;
    case 'HIGH':
      return Icons.error;
    default:
      return Icons.info;
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
  return 'This is a projection based on forecast rain. It may change as conditions update.';
}
