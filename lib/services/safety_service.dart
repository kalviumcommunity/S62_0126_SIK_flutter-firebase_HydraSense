import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum SafetyStatus {
  safe,
  moderate,
  inDangerZone,
  locationDisabled,
  unknown,
}

class SafetyCheckResult {
  final bool isInDanger;
  final SafetyStatus status;
  final String message;
  final double confidence;
  final String? userDistrict;
  final String? userRisk;
  final String? predictedRisk;
  final int? predictionWindow;
  final double? currentRadius;
  final Map<String, dynamic>? metrics;

  SafetyCheckResult({
    required this.isInDanger,
    required this.status,
    required this.message,
    this.confidence = 0,
    this.userDistrict,
    this.userRisk,
    this.predictedRisk,
    this.predictionWindow,
    this.currentRadius,
    this.metrics,
  });

  factory SafetyCheckResult.fromJson(Map<String, dynamic> json) {
  final statusStr = (json['status'] as String?)?.toUpperCase() ?? 'UNKNOWN';

  SafetyStatus status = SafetyStatus.unknown;
  String? userRisk;

  if (statusStr == 'SAFE' || statusStr == 'LOW') {  // ADD 'LOW' HERE
    status = SafetyStatus.safe;
    userRisk = 'LOW';
  } else if (statusStr == 'MODERATE') {
    status = SafetyStatus.moderate;
    userRisk = 'MODERATE';
  } else if (statusStr == 'HIGH' || statusStr == 'DANGER') {
    status = SafetyStatus.inDangerZone;
    userRisk = 'HIGH';
  }

  final String? districtField = json['nearestDistrict'] ?? json['userDistrict'];
  final userDistrict = (districtField == 'SEARCHED LOCATION' || districtField == null) 
                    ? 'SEARCHED LOCATION' 
                    : districtField;

  // print('🔍 SAFETY SERVICE DEBUG:');
  // print('  Backend nearestDistrict = ${json['nearestDistrict']}');
  // print('  Final userDistrict = $userDistrict');
  // print('  Risk = $userRisk');

  return SafetyCheckResult(
    isInDanger: status == SafetyStatus.inDangerZone,
    status: status,
    message: json['message'] ?? 'Safety status unavailable',
    confidence: (json['confidence'] ?? 0).toDouble(),
    userDistrict: userDistrict,
    userRisk: userRisk,
    predictedRisk: json['predictedRisk'],
    predictionWindow: json['predictionWindow'],
    currentRadius: (json['currentRadius'] as num?)?.toDouble(),
    metrics: json['metrics'] as Map<String, dynamic>?,
  );
}

  factory SafetyCheckResult.locationUnavailable() {
    return SafetyCheckResult(
      isInDanger: false,
      status: SafetyStatus.locationDisabled,
      message: 'Enable location to check safety in your area',
    );
  }

  factory SafetyCheckResult.unknownError() {
    return SafetyCheckResult(
      isInDanger: false,
      status: SafetyStatus.unknown,
      message: 'Unable to check safety right now',
    );
  }
}

class SafetyService {
  static const String _baseUrl =
      'https://s62-0126-sik-flutter-firebase-hydrasense.onrender.com/api';

  static Future<SafetyCheckResult> checkUserSafety(
    LatLng? location,
  ) async {
    if (location == null) {
      return SafetyCheckResult.locationUnavailable();
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/check-user-safety'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lat': location.latitude,
          'lng': location.longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend error');
      }

      final data = jsonDecode(response.body);
      return SafetyCheckResult.fromJson(data);
    } catch (_) {
      return SafetyCheckResult.unknownError();
    }
  }

  static Future<SafetyCheckResult> checkLocationRisk(
    LatLng location,
  ) async {
    try {
      // print('📍 SENDING SEARCH REQUEST for ${location.latitude}, ${location.longitude}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/check-location-risk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lat': location.latitude,
          'lng': location.longitude,
          'radiusKm': 5,
        }),
      );

      // print('📍 SEARCH RESPONSE status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Backend error');
      }

      final data = jsonDecode(response.body);
      // print('📍 SEARCH RESPONSE data: ${data['nearestDistrict']}');
      
      return SafetyCheckResult.fromJson(data);
    } catch (_) {
      return SafetyCheckResult.unknownError();
    }
  }
}