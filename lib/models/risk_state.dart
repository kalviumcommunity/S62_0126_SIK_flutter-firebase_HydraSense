import 'package:cloud_firestore/cloud_firestore.dart';

class RiskState {
  final String districtId;

  final double centerLat;
  final double centerLng;

  final double currentRadius;
  final double? predictedRadius;

  final String currentRisk;
  final String? predictedRisk;

  final int? predictionWindow;
  final DateTime updatedAt;

  RiskState({
    required this.districtId,
    required this.centerLat,
    required this.centerLng,
    required this.currentRadius,
    this.predictedRadius,
    required this.currentRisk,
    this.predictedRisk,
    this.predictionWindow,
    required this.updatedAt,
  });

  factory RiskState.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RiskState(
      districtId: data['districtId'] as String,

      centerLat: (data['centerLat'] as num).toDouble(),
      centerLng: (data['centerLng'] as num).toDouble(),

      currentRadius: (data['currentRadius'] as num).toDouble(),
      predictedRadius: data['predictedRadius'] != null
          ? (data['predictedRadius'] as num).toDouble()
          : null,

      currentRisk: data['currentRisk'] as String,
      predictedRisk: data['predictedRisk'] as String?,

      predictionWindow: data['predictionWindow'] as int?,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
