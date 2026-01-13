import 'package:cloud_firestore/cloud_firestore.dart';

enum RiskLevel {
  low,
  moderate,
  high,
}

class RiskState {
  final String districtId;
  final double centerLat;
  final double centerLng;
  final double currentRadius;
  final double? predictedRadius;
  final RiskLevel currentRisk;
  final RiskLevel? predictedRisk;
  final int? predictionWindow;
  final DateTime updatedAt;

  RiskState({
    required this.districtId,
    required this.centerLat,
    required this.centerLng,
    required this.currentRadius,
    required this.currentRisk,
    required this.updatedAt,
    this.predictedRadius,
    this.predictedRisk,
    this.predictionWindow,
  });

  factory RiskState.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return RiskState(
      districtId: doc.id,
      centerLat: (data['centerLat'] as num).toDouble(),
      centerLng: (data['centerLng'] as num).toDouble(),
      currentRadius: (data['currentRadius'] as num).toDouble(),
      predictedRadius: data['predictedRadius'] != null
          ? (data['predictedRadius'] as num).toDouble()
          : null,
      currentRisk: _parseRisk(data['currentRisk']),
      predictedRisk: data['predictedRisk'] != null
          ? _parseRisk(data['predictedRisk'])
          : null,
      predictionWindow: data['predictionWindow'],
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static RiskLevel _parseRisk(String value) {
    switch (value) {
      case 'LOW':
        return RiskLevel.low;
      case 'MODERATE':
        return RiskLevel.moderate;
      case 'HIGH':
        return RiskLevel.high;
      default:
        throw Exception('Unknown risk level: $value');
    }
  }
}
