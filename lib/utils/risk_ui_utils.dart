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
