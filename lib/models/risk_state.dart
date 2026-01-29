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
  final double? confidence;
  final DateTime? predictionExpiresAt;

  final DateTime updatedAt;

  final double? rainfallLast24h;
  final double? forecastRain6h;
  final double? forecastRain12h;
  final double? forecastRain24h;
  final double? maxRainProb;
  final double? riverDischarge;

  RiskState({
    required this.districtId,
    required this.centerLat,
    required this.centerLng,
    required this.currentRadius,
    this.predictedRadius,
    required this.currentRisk,
    this.predictedRisk,
    this.predictionWindow,
    this.confidence,
    this.predictionExpiresAt,
    required this.updatedAt,

    this.rainfallLast24h,
    this.forecastRain6h,
    this.forecastRain12h,
    this.forecastRain24h,
    this.maxRainProb,
    this.riverDischarge,
  });

  factory RiskState.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final metrics = data['metrics'] as Map<String, dynamic>?;

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
      confidence: data['confidence'] != null
          ? (data['confidence'] as num).toDouble()
          : null,

      predictionExpiresAt: data['predictionExpiresAt'] != null
          ? (data['predictionExpiresAt'] as Timestamp).toDate()
          : null,

      updatedAt: (data['updatedAt'] as Timestamp).toDate(),

      rainfallLast24h: metrics?['rainfallLast24h']?.toDouble(),
      forecastRain6h: metrics?['forecastRain6h']?.toDouble(),
      forecastRain12h: metrics?['forecastRain12h']?.toDouble(),
      forecastRain24h: metrics?['forecastRain24h']?.toDouble(),
      maxRainProb: metrics?['maxRainProb']?.toDouble(),
      riverDischarge: metrics?['riverDischarge']?.toDouble(),
    );
  }
}
