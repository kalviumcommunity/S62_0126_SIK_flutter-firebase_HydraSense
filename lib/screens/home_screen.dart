import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'dart:async';
import 'dart:math';
import 'welcomescreen.dart';
import 'map_screen.dart';
import 'emergency_screen.dart';
import '../state/risk_state_provider.dart';
import '../models/risk_state.dart';
import '../services/location_service.dart';
import '../services/safety_service.dart';
import 'checklist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _userReportedFlood = false;
  SafetyCheckResult? _homeSafety;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiskStateProvider>().startListeningAll();
    });
    _getUserLocationAndRisk();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
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
        return const Color(0xFFFF4757);
      case 'moderate':
        return const Color(0xFFFFA502);
      case 'low':
        return const Color(0xFF2ED573);
      default:
        return const Color(0xFF747D8C);
    }
  }

  String _getRiskEmoji(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return '🌊';
      case 'moderate':
        return '⚠️';
      case 'low':
        return '✅';
      default:
        return '🌤️';
    }
  }

  Widget _buildRiskIcon(String riskLevel, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          _getRiskEmoji(riskLevel),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  Widget _buildAnimatedWave() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 60),
          painter: WavePainter(_waveAnimation.value),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
                border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (hasBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4757),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1E3C),
              Color(0xFF0F2B4A),
              Color(0xFF123258),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 🌊 Top decorative wave
                _buildAnimatedWave(),

                // 👤 App Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0099FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HydraSense',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Flood Intelligence System',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
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
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
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

                // 👋 Welcome Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email?.split('@').first ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF00D4FF).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00D4FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// ================= FLOOD RISK CARD =================
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final safety = _homeSafety;
                    final riskState =
                        _findClosestRiskState(riskProvider.effectiveRiskStates);

                    String displayRiskLevel = 'UNKNOWN';
                    Color displayRiskColor = const Color(0xFF747D8C);
                    String displayRiskEmoji = '🌤️';
                    String? displayRiskText;

                    if (_isLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Color(0xFF00D4FF)),
                            ),
                          ),
                        ),
                      );
                    }

                    final isDemoMode = riskProvider.isDemoMode;

                    if (isDemoMode && riskState != null) {
                      displayRiskLevel = riskState.currentRisk;
                      displayRiskColor = _getRiskColor(riskState.currentRisk);
                      displayRiskEmoji = _getRiskEmoji(riskState.currentRisk);
                      displayRiskText =
                          'Prediction: Risk may increase in ${riskState.predictionWindow} hours';
                    } else if (safety != null) {
                      final isSafe = !safety.isInDanger;
                      displayRiskLevel = isSafe ? 'LOW' : 'HIGH';
                      displayRiskColor = _getRiskColor(displayRiskLevel);
                      displayRiskEmoji = isSafe ? '✅' : '🌊';
                      displayRiskText = safety.message;
                    } else if (riskState != null) {
                      displayRiskLevel = riskState.currentRisk;
                      displayRiskColor = _getRiskColor(riskState.currentRisk);
                      displayRiskEmoji = _getRiskEmoji(riskState.currentRisk);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              displayRiskColor.withOpacity(0.15),
                              displayRiskColor.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(color: displayRiskColor.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: displayRiskColor.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildRiskIcon(displayRiskLevel, displayRiskColor, 48),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FLOOD RISK STATUS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.7),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        displayRiskLevel,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: displayRiskColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (displayRiskText != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: displayRiskColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        displayRiskText,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 🛡️ Safety Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0099FF)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Safety Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // 📋 Emergency Checklist Card
                _buildFeatureCard(
                  icon: Icons.checklist_rounded,
                  iconColor: const Color(0xFF2ED573),
                  backgroundColor: const Color(0xFF1E3A3F),
                  title: 'Emergency Safety Checklist',
                  subtitle: 'Step-by-step guide for flood preparedness',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChecklistScreen()),
                    );
                  },
                  hasBadge: false,
                ),

                // 🧪 Prediction Demo Card
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final isDemoMode = riskProvider.isDemoMode;
                    
                    return _buildFeatureCard(
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFFFFA502),
                      backgroundColor: const Color(0xFF3A2E1E),
                      title: 'Prediction Demo',
                      subtitle: isDemoMode
                          ? 'Demo is active - Tap to stop'
                          : 'See real-time flood predictions',
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
                              currentRadius: 2500,
                              currentRisk: 'MODERATE',
                              predictedRadius: 4500,
                              predictedRisk: 'HIGH',
                              predictionWindow: 6,
                              predictionExpiresAt:
                                  DateTime.now().add(const Duration(hours: 6)),
                              confidence: 0.82,
                              rainfallLast24h: 132.5,
                              forecastRain6h: 88.0,
                              forecastRain12h: 145.0,
                              riverDischarge: 920.0,
                              updatedAt: DateTime.now(),
                            ),
                          );
                        }
                      },
                      hasBadge: isDemoMode,
                    );
                  },
                ),

                // 🗺️ Map Card
                _buildFeatureCard(
                  icon: Icons.map_rounded,
                  iconColor: const Color(0xFF00D4FF),
                  backgroundColor: const Color(0xFF1E2F4A),
                  title: 'Live Flood Map',
                  subtitle: 'Real-time flood zones and risk areas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    );
                  },
                  hasBadge: false,
                ),

                // 🔴 Emergency Guide Card
                _buildFeatureCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFFF4757),
                  backgroundColor: const Color(0xFF4A1E2F),
                  title: 'Emergency Safety Guide',
                  subtitle: 'What to do during flood emergencies',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                    );
                  },
                  hasBadge: true,
                ),

                // 🚨 Emergency Action Button
                Consumer<RiskStateProvider>(
                  builder: (context, riskProvider, _) {
                    final safety = _homeSafety;
                    final isDemoMode = riskProvider.isDemoMode;
                    final isDemoHighRisk = isDemoMode &&
                        riskProvider.effectiveRiskStates.any(
                          (s) => s.currentRisk == 'HIGH',
                        );
                    final isApiHighRisk =
                        !isDemoMode && safety != null && safety.isInDanger;
                    final showBigEmergency = isApiHighRisk || isDemoHighRisk;

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (showBigEmergency)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF4757),
                                    Color(0xFFFF3838),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF4757).withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'EMERGENCY ALERT',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          isDemoMode
                                              ? 'Demo: High flood risk detected'
                                              : 'High flood risk in your area',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),

                          // Quick Actions Row
                          
                          
                                     
                         
                        ],
                      ),
                    );
                  },
                ),

                // 🌊 Bottom decorative wave
                Transform.rotate(
                  angle: 3.14,
                  child: _buildAnimatedWave(),
                ),

                // Bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for wave animation
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    
    for (double i = 0; i < size.width; i++) {
      final y = size.height * 0.5 +
          sin((i * 0.02) + (animationValue * 2 * 3.14)) * 15;
      path.lineTo(i, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}