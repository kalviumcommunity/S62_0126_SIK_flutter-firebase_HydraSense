import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'welcomescreen.dart';
import 'map_screen.dart';
import 'emergency_screen.dart';
import '../state/risk_state_provider.dart';
import '../models/risk_state.dart';
import '../services/location_service.dart';
import '../services/safety_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  
  LatLng? _userLocation;
  bool _isLoading = true;
  // ignore: prefer_final_fields
  bool _userReportedFlood = false;
  SafetyCheckResult? _homeSafety;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiskStateProvider>().startListeningAll();
    });
    _getUserLocationAndRisk();
  }

  Future<void> _getUserLocationAndRisk() async {
    try {
      final position = await _locationService
          .getCurrentLocation()
          .timeout(const Duration(seconds: 5));

      if (position != null) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _checkHomeSafety();
      } else {
        _useDefaultLocation();
      }
    } catch (_) {
      _useDefaultLocation();
    }
  }

  Future<void> _checkHomeSafety() async {
    if (_userLocation == null) return;
    final result = await SafetyService.checkUserSafety(_userLocation!);
    if (!mounted) return;
    setState(() => _homeSafety = result);
  }

  void _useDefaultLocation() {
    if (!mounted) return;

    setState(() {
      _userLocation = const LatLng(28.7041, 77.1025);
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHomeSafety();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Using approximate location. Enable GPS for accuracy."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  RiskState? _findClosestRiskState(List<RiskState> allRiskStates) {
    if (_userLocation == null || allRiskStates.isEmpty) return null;

    RiskState? closest;
    double? closestDistance;

    for (final rs in allRiskStates) {
      final distance = const Distance().distance(_userLocation!, rs.center);
      if (closestDistance == null || distance < closestDistance) {
        closestDistance = distance;
        closest = rs;
      }
    }

    if (closestDistance != null && closestDistance < 20000) {
      return closest;
    }
    return null;
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRiskEmoji(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return '🔴';
      case 'moderate':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 6, 70, 100),
              Color.fromARGB(255, 20, 120, 180),
              Color.fromARGB(255, 2, 25, 40),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔝 Top App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'HydraSense',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WelcomeScreen()),
                            (_) => false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 👋 Welcome Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user?.email ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// ================= FLOOD RISK CARD =================
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    // ✅ Compute ONCE
                    final safety = _homeSafety;
                    final riskState =
                      _findClosestRiskState(riskProvider.effectiveRiskStates);
                    

                    // ✅ Initialize with defaults
                    String displayRiskLevel = 'UNKNOWN';
                    Color displayRiskColor = Colors.grey;
                    String displayRiskEmoji = '⚪';
                    String? displayRiskText;

                    if (_isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Card(
                          color: Colors.white12,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }


                    final isDemoMode = riskProvider.isDemoMode;

                // 1️⃣ DEMO MODE — highest priority
                if (isDemoMode && riskState != null) {
                  displayRiskLevel = riskState.currentRisk;
                  displayRiskColor = _getRiskColor(riskState.currentRisk);
                  displayRiskEmoji = _getRiskEmoji(riskState.currentRisk);
                  displayRiskText =
                      'Prediction: Risk may increase in ${riskState.predictionWindow} hours';

                // 2️⃣ REAL SAFETY CHECK
                } else if (safety != null) {
                  final isSafe = !safety.isInDanger;
                  displayRiskLevel = isSafe ? 'LOW' : 'HIGH';
                  displayRiskColor = isSafe ? Colors.green : Colors.red;
                  displayRiskEmoji = isSafe ? '🟢' : '🔴';
                  displayRiskText = safety.message;

                // 3️⃣ FIRESTORE FALLBACK
                } else if (riskState != null) {
                  displayRiskLevel = riskState.currentRisk;
                  displayRiskColor = _getRiskColor(riskState.currentRisk);
                  displayRiskEmoji = _getRiskEmoji(riskState.currentRisk);

                // 4️⃣ TRUE EMPTY STATE (VERY RARE)
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Flood Data Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Flood risk data is not available for your current location.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: displayRiskColor.withOpacity(0.2),
                          border: Border.all(
                              color: displayRiskColor.withOpacity(0.5),
                              width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$displayRiskEmoji Current Flood Risk',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayRiskLevel,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: displayRiskColor,
                              ),
                            ),
                            if (displayRiskText != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                displayRiskText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),


                // 🧪 PREDICTION DEMO
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final isDemoMode = riskProvider.isDemoMode;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.orange.withOpacity(0.12),
                          border: Border.all(color: Colors.orange.withOpacity(0.6)),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.trending_up, color: Colors.orange),
                                SizedBox(width: 10),
                                Text(
                                  'Prediction Demo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'See how HydraSense predicts floods before they happen.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),

                            GestureDetector(
                              onTap: () {
                                final provider = context.read<RiskStateProvider>();

                                if (isDemoMode) {
                                  provider.stopDemo();
                                } else {
                                  final loc = _userLocation;
                                  if (loc == null) return;

                                  provider.setDemoRisk(
                                    RiskState(
                                      districtId: 'DEMO_PREDICTION',
                                      centerLat: loc.latitude,
                                      centerLng: loc.longitude,

                                      // 🌊 CURRENT FLOOD STATE
                                      currentRadius: 2500,
                                      currentRisk: 'MODERATE',

                                      // 🔮 PREDICTION DATA
                                      predictedRadius: 4500,
                                      predictedRisk: 'HIGH',
                                      predictionWindow: 6,
                                      predictionExpiresAt: DateTime.now().add(
                                        const Duration(hours: 6),
                                      ),

                                      // 📊 CONFIDENCE
                                      confidence: 0.82,

                                      // 📈 HARD-CODED DEMO METRICS (THIS IS THE KEY)
                                      rainfallLast24h: 132.5,      // mm
                                      forecastRain6h: 88.0,        // mm
                                      forecastRain12h: 145.0,      // mm
                                      riverDischarge: 920.0,       // cumecs

                                      updatedAt: DateTime.now(),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: isDemoMode
                                        ? [Colors.redAccent, Colors.red]
                                        : [const Color(0xFFFFB347), const Color(0xFFFF8C00)],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isDemoMode ? 'STOP DEMO' : 'SEE HOW PREDICTION WORKS',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                /// ================= EMERGENCY BUTTON =================
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final safety = _homeSafety;
                    final hasUserReportedFlood = _userReportedFlood;
                    final isDemoMode = riskProvider.isDemoMode;

                    final bool isDemoHighRisk =
                        isDemoMode &&
                        riskProvider.effectiveRiskStates.any(
                          (s) => s.currentRisk == 'HIGH',
                        );

                    final bool isApiHighRisk =
                        !isDemoMode && safety != null && safety.isInDanger;

                    final bool showBigEmergencyButton =
                        isApiHighRisk || isDemoHighRisk;

                    // Show small emergency button when:
                    // 1. High risk (API or demo)
                    // 2. User reported flood
                    // 3. No safety data available
                    final bool showSmallEmergencyButton =
                        showBigEmergencyButton ||
                        hasUserReportedFlood ||
                        safety == null;

                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // 🚨 BIG RED EMERGENCY BUTTON (only for API HIGH risk)
                          if (showBigEmergencyButton) ...[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EmergencyScreen()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 24),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Color.fromARGB(255, 180, 0, 0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning_rounded,
                                        color: Colors.white, size: 30),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        'EMERGENCY ACTION REQUIRED',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // 🗺️ MAP BUTTON
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MapScreen()),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 120, 210, 255),
                                    Color.fromARGB(255, 30, 160, 220),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Text(
                                showBigEmergencyButton
                                    ? 'VIEW EMERGENCY MAP'
                                    : 'VIEW LIVE FLOOD MAP',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔴 SMALL EMERGENCY GUIDE BUTTON
                          if (showSmallEmergencyButton)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EmergencyScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.red.withOpacity(0.15),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: hasUserReportedFlood
                                          ? Colors.orange
                                          : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Emergency Safety Guide',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: hasUserReportedFlood
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}