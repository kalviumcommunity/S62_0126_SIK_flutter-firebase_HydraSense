import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'welcomescreen.dart';
import 'map_screen.dart';
import 'emergency_screen.dart';
import 'checklist_screen.dart';
import '../state/risk_state_provider.dart';
import '../models/risk_state.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _userReportedFlood = false;

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
      final position = await _locationService.getCurrentLocation()
          .timeout(const Duration(seconds: 5));
      
      if (position != null) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        print("Got real location: ${position.latitude}, ${position.longitude}");
      } else {
        _useDefaultLocation();
      }
    } catch (e) {
      print("Location error: $e");
      _useDefaultLocation();
    }
  }

  void _useDefaultLocation() {
    if (!mounted) return;
    
    setState(() {
      _userLocation = const LatLng(28.7041, 77.1025); // Delhi (LOW risk)
      _isLoading = false;
    });
    
    print("Using default location: Delhi (28.7041, 77.1025)");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Using approximate location. Enable GPS for accuracy."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function to find the closest risk zone to user
  RiskState? _findClosestRiskState(List<RiskState> allRiskStates) {
    if (_userLocation == null || allRiskStates.isEmpty) return null;

    RiskState? closest;
    double? closestDistance;

    for (final riskState in allRiskStates) {
      final distance = const Distance().distance(
        _userLocation!,
        riskState.center,
      );

      if (closestDistance == null || distance < closestDistance) {
        closestDistance = distance;
        closest = riskState;
      }
    }

    // CHANGED: Decreased from 50km to 20km
    if (closestDistance != null && closestDistance < 20000) {
      return closest;
    }

    return null;
  }

  void _reportFlood() {
    setState(() {
      _userReportedFlood = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flood reported! Emergency mode activated.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _clearFloodReport() {
    setState(() {
      _userReportedFlood = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flood report cleared.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          child: Column(
            children: [
              // 🔝 Top App Bar (Custom)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // App Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha:0.15),
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
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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

                // 📊 REAL Flood Risk Card
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final riskState = _findClosestRiskState(riskProvider.riskStates);
                    
                    // Check conditions
                    final bool isApiHighRisk = riskState?.currentRisk.toLowerCase() == 'high';
                    final bool isApiModerateRisk = riskState?.currentRisk.toLowerCase() == 'moderate';
                    final bool hasUserReportedFlood = _userReportedFlood;

                    if (_isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Card(
                          color: Colors.white12,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }

                    if (riskState == null && !hasUserReportedFlood) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: Colors.white.withOpacity(0.12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.white),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'No Flood Data Available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Flood risk data is not available for your current location. Check back later or view the map for nearby areas.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Determine what to display in risk card
                    final String displayRiskLevel;
                    final Color displayRiskColor;
                    final String displayRiskEmoji;

                    if (hasUserReportedFlood) {
                      displayRiskLevel = 'HIGH';
                      displayRiskColor = Colors.red;
                      displayRiskEmoji = '🔴';
                    } else if (riskState != null) {
                      displayRiskLevel = riskState.currentRisk;
                      displayRiskColor = _getRiskColor(riskState.currentRisk);
                      displayRiskEmoji = _getRiskEmoji(riskState.currentRisk);
                    } else {
                      displayRiskLevel = 'UNKNOWN';
                      displayRiskColor = Colors.grey;
                      displayRiskEmoji = '⚪';
                    }

                    String? predictedRiskEmoji;
                    Color? predictedRiskColor;

                    if (riskState?.predictedRisk != null) {
                      predictedRiskColor = _getRiskColor(riskState!.predictedRisk!);
                      predictedRiskEmoji = _getRiskEmoji(riskState.predictedRisk!);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                       Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomeScreen(),
                          ),
                      );

                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: displayRiskColor.withOpacity(0.2),
                          border: Border.all(color: displayRiskColor.withOpacity(0.5), width: 2),
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha:0.15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$displayRiskEmoji Current Flood Risk',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (hasUserReportedFlood) const SizedBox(width: 10),
                                if (hasUserReportedFlood)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.person, size: 12, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'User Reported',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayRiskLevel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: displayRiskColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              riskState != null
                                  ? 'Updated: ${riskState.updatedAt.hour}:${riskState.updatedAt.minute.toString().padLeft(2, '0')}'
                                  : 'User Reported',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),

                            if (riskState?.predictedRisk != null) ...[
                              const SizedBox(height: 20),
                              const Divider(color: Colors.white30),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    '$predictedRiskEmoji Predicted Risk',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (riskState!.predictionWindow != null)
                                    Chip(
                                      label: Text(
                                        'In ${riskState.predictionWindow} hours',
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                      backgroundColor: predictedRiskColor!.withOpacity(0.5),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                riskState.predictedRisk!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: predictedRiskColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Flood risk is likely to change. Stay prepared.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ] else if (riskState != null) ...[
                              const SizedBox(height: 10),
                              const Text(
                                'No significant change predicted.',
                                style: TextStyle(
                                  fontSize: 14,
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

                // 🚨 COMMUNITY FLOOD REPORT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 👋 Welcome Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.85),
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

              const SizedBox(height: 30),

              // 📊 Main Feature Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.report_problem, color: Colors.orange),
                            SizedBox(width: 10),
                            Text(
                              'Community Flood Report',
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
                          'Report flooding in your area if not detected by system',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        if (!_userReportedFlood)
                          GestureDetector(
                            onTap: _reportFlood,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.orange.withOpacity(0.3),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                  SizedBox(width: 10),
                                  Text(
                                    'REPORT FLOOD IN MY AREA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.red.withOpacity(0.2),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.red),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'You reported flooding in your area',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _clearFloodReport,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.green.withOpacity(0.2),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cleaning_services_rounded, color: Colors.green),
                                      SizedBox(width: 10),
                                      Text(
                                        'CLEAR MY REPORT',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔘 EMERGENCY BUTTON SECTION
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final riskState = _findClosestRiskState(riskProvider.riskStates);
                    final bool isApiHighRisk = riskState?.currentRisk.toLowerCase() == 'high';
                    final bool isApiModerateRisk = riskState?.currentRisk.toLowerCase() == 'moderate';
                    final bool isApiLowRisk = riskState?.currentRisk.toLowerCase() == 'low';
                    final bool hasUserReportedFlood = _userReportedFlood;
                    
                    // Show BIG emergency button only for API HIGH risk
                    final bool showBigEmergencyButton = isApiHighRisk;
                    
                    // Show SMALL emergency guide button when:
                    // 1. Risk is HIGH or MODERATE, OR
                    // 2. User reported flood, OR  
                    // 3. No data available
                    final bool showSmallEmergencyButton = 
                        isApiHighRisk || 
                        isApiModerateRisk || 
                        hasUserReportedFlood ||
                        riskState == null;

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
                                  MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                                    Icon(Icons.warning_rounded, color: Colors.white, size: 30),
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

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red.withOpacity(0.2),
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info, color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'HIGH FLOOD RISK DETECTED - Tap emergency button for immediate safety guidance',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // 🗺️ MAP BUTTON
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MapScreen()),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                showBigEmergencyButton ? 'VIEW EMERGENCY MAP' : 'VIEW LIVE FLOOD MAP',
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

                          // 🔴 SMALL EMERGENCY GUIDE BUTTON (hidden when LOW risk)
                          if (showSmallEmergencyButton)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.red.withOpacity(0.15),
                                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: hasUserReportedFlood ? Colors.orange : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Emergency Safety Guide',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: hasUserReportedFlood ? Colors.orange : Colors.red,
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
  Widget _featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.lightBlueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}