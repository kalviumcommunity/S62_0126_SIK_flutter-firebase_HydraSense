import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/risk_state.dart';

class DemoStateProvider extends ChangeNotifier {
  RiskState? _userReportedFlood;
  RiskState? _simulatedPrediction;

  RiskState? get userReportedFlood => _userReportedFlood;
  RiskState? get simulatedPrediction => _simulatedPrediction;

  bool get hasAnyDemo =>
      _userReportedFlood != null || _simulatedPrediction != null;

  void reportUserFlood(LatLng location) {
    print('🧪 DEMO: reportUserFlood at ${location.latitude}, ${location.longitude}');

    _userReportedFlood = RiskState(
      districtId: 'DEMO_USER_REPORT',
      centerLat: location.latitude,
      centerLng: location.longitude,
      currentRadius: 2000, // 2km demo radius
      currentRisk: 'HIGH',
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void simulatePrediction(LatLng location) {
    print('🧪 DEMO: simulatePrediction at ${location.latitude}, ${location.longitude}');

    _simulatedPrediction = RiskState(
      districtId: 'DEMO_PREDICTION',
      centerLat: location.latitude,
      centerLng: location.longitude,
      currentRadius: 2500,
      predictedRadius: 4000,
      currentRisk: 'MODERATE',
      predictedRisk: 'HIGH',
      predictionWindow: 6,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void clearAllDemos() {
    print('🧪 DEMO: clearAllDemos');

    _userReportedFlood = null;
    _simulatedPrediction = null;
    notifyListeners();
  }
}
