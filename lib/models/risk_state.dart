import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RiskState {
  final String districtId;

  final LatLng center;

  final double currentRadius;
  final double? predictedRadius;

  final String currentRisk;
  final String? predictedRisk;

  final int? predictionWindow;
  final DateTime updatedAt;

  RiskState({
    required this.districtId,
    required this.center,
    required this.currentRadius,
    required this.currentRisk,
    required this.updatedAt,
    this.predictedRadius,
    this.predictedRisk,
    this.predictionWindow,
  });

  factory RiskState.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RiskState(
      districtId: data['districtId'] as String,

      center: LatLng(
        (data['centerLat'] as num).toDouble(),
        (data['centerLng'] as num).toDouble(),
      ),

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
