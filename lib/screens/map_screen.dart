import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sw2/widgets/search_location_marker.dart';

import '../models/risk_state.dart';
import '../state/risk_state_provider.dart';
import '../services/location_service.dart';
import '../services/safety_service.dart';
import '../state/demo_state_provider.dart';

import '../widgets/safety_widgets.dart';
import '../widgets/flood_zones_layer.dart';
import '../widgets/map_app_bar.dart';
import '../widgets/risk_info_sheet.dart';
// import '../widgets/risk_panel.dart';
import '../widgets/search_location_dialog.dart';
import '../widgets/user_location_marker.dart';
import '../widgets/prediction_warning_banner.dart';

import '../utils/risk_ui_utils.dart';
import '../utils/distance_utils.dart';

// Import the EmergencyScreen
import '../screens/emergency_screen.dart';  // Add this import

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final MapController _mapController = MapController();

  late final AnimationController _pulseController;
  late final AnimationController _panelController;
  
  LatLng? _userLocation;
  LatLng? _searchedLocation;
  double? _searchedRiskRadius;
  static const double _safeSearchRadius = 5000;

  bool _hasMovedCamera = false;
  bool _showRiskPanel = true;
  bool _checkingSafety = false;

  SafetyCheckResult _safetyResult = SafetyCheckResult(
    isInDanger: false,
    status: SafetyStatus.locationDisabled,
    message: 'Checking safety status...',
  );

  static final LatLng indiaCenter = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _loadUserLocation();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiskStateProvider>().startListeningAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<RiskStateProvider>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      provider.pauseListening();
      _pulseController.stop();
    } else if (state == AppLifecycleState.resumed) {
      provider.startListeningAll();
      _pulseController.repeat();
    }
  }

  Future<void> _loadUserLocation() async {
    final position = await LocationService().getCurrentLocation();
    if (position == null) return;

    final latLng = LatLng(position.latitude, position.longitude);

    if (!mounted) return;
    setState(() => _userLocation = latLng);

    if (!_hasMovedCamera) {
      _mapController.move(latLng, 13);
      _hasMovedCamera = true;
    }
  }

  void _updateSafetyCheck(List<RiskState> riskStates) async {
    if (_checkingSafety || _userLocation == null) return;

    final provider = context.read<RiskStateProvider>();

    /// 🧪 DEMO MODE — derive safety from demo state
    if (provider.isDemoMode) {
      final demoState = provider.effectiveRiskStates
          .where((s) => s.districtId == 'DEMO_PREDICTION')
          .cast<RiskState?>()
          .firstOrNull;

      if (demoState != null && mounted) {
        final newResult = SafetyCheckResult(
          isInDanger: demoState.currentRisk == 'HIGH',
          status: demoState.currentRisk == 'HIGH'
              ? SafetyStatus.inDangerZone
              : SafetyStatus.moderate,
          message: demoState.currentRisk == 'HIGH'
              ? 'Severe flood risk detected (simulation)'
              : 'Moderate flood risk detected (simulation)',
          userDistrict: 'SIMULATION MODE',
        );
        
        setState(() => _safetyResult = newResult);
      }
      return;
    }
    
    _checkingSafety = true;

    final result = await SafetyService.checkUserSafety(_userLocation);

    if (mounted) {
      setState(() => _safetyResult = result);
    }

    _checkingSafety = false;
  }

  void _onFloodZoneTap(RiskState state) {
    context.read<RiskStateProvider>().clearSearch();
    context.read<RiskStateProvider>().selectZone(state);

    final center = LatLng(state.centerLat, state.centerLng);
    _mapController.move(
      center,
      _mapController.camera.zoom < 10 ? 10 : _mapController.camera.zoom,
    );

    showRiskInfoSheet(context: context, state: state);
  }

  Future<void> _openSearchDialog() async {
    final place = await showSearchLocationDialog(context);
      if (!mounted || place == null) return;

      context.read<RiskStateProvider>().clearSelection();

      final latLng = LatLng(place['lat'], place['lon']);

    setState(() {
      _searchedLocation = latLng;
      _searchedRiskRadius = null;
    });

    final result = await SafetyService.checkLocationRisk(latLng);
    if (!mounted) return;

    setState(() {
      _safetyResult = result;
      _searchedRiskRadius = result.currentRadius;

      if (result.userRisk != null) {
        final searchState = RiskState(
          districtId: result.userDistrict ?? 'SEARCHED LOCATION',
          centerLat: latLng.latitude,
          centerLng: latLng.longitude,
          currentRadius: result.currentRadius ?? _safeSearchRadius,
          currentRisk: result.userRisk!,
          predictedRisk: result.predictedRisk,
          predictionWindow: result.predictionWindow,
          confidence: result.confidence,
          updatedAt: DateTime.now(),
          rainfallLast24h: (result.metrics?['rainfallLast24h'] as num?)?.toDouble(),
          forecastRain6h: (result.metrics?['forecastRain6h'] as num?)?.toDouble(),
          forecastRain12h: (result.metrics?['forecastRain12h'] as num?)?.toDouble(),
          forecastRain24h: (result.metrics?['forecastRain24h'] as num?)?.toDouble(),
          maxRainProb: (result.metrics?['maxRainProb'] as num?)?.toDouble(),
          riverDischarge: (result.metrics?['riverDischarge'] as num?)?.toDouble(),
        );
        
        context.read<RiskStateProvider>().setSearchedRiskState(searchState);
      }
    });

    final zoom = (_searchedRiskRadius != null && _searchedRiskRadius! > 3000)
        ? 11.0
        : 14.0;

    _mapController.move(latLng, zoom);
  }

  void _goToMyLocation() {
    if (_userLocation != null) {
      context.read<RiskStateProvider>().clearSearch();
      _mapController.move(_userLocation!, 13);
    }
  }

  void _toggleRiskPanel() {
    if (_showRiskPanel) {
      _panelController.reverse().then((_) {
        if (mounted) {
          setState(() => _showRiskPanel = false);
        }
      });
    } else {
      setState(() => _showRiskPanel = true);
      _panelController.forward();
    }
  }

  void _openEmergencyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyScreen(),
      ),
    );
  }

  RiskState? _getRelevantPrediction(List<RiskState> states) {
    if (_userLocation == null) return null;

    final now = DateTime.now();

    for (final state in states) {
      if (state.predictedRadius == null ||
          state.predictionExpiresAt == null ||
          now.isAfter(state.predictionExpiresAt!)) {
        continue;
      }

      final center = LatLng(state.centerLat, state.centerLng);
      final d = distanceMeters(_userLocation!, center);

      if (d < state.predictedRadius!) {
        return state;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showEmergencyButton = _safetyResult.status == SafetyStatus.inDangerZone || 
                               _safetyResult.status == SafetyStatus.moderate;

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          MapAppBar(
            onSearchTap: _openSearchDialog,
            onMyLocationTap: _goToMyLocation,
            onRiskPanelToggle: _toggleRiskPanel,
            showPanel: _showRiskPanel,
          ),
          Consumer<RiskStateProvider>(
            builder: (_, provider, _) {
              final prediction = _getRelevantPrediction(provider.riskStates);
              if (prediction == null) return const SizedBox();
              return PredictionWarningBanner(
                message: 'Possible flood expansion near you in ${prediction.predictionWindow} hours',
                onTap: () {
                  context.read<RiskStateProvider>().clearSearch();
                  _mapController.move(
                    LatLng(prediction.centerLat, prediction.centerLng),
                    12,
                  );
                },
              );
            },
          ),
          _buildSafetyStatus(),
          // Emergency button for moderate/high risk
          if (showEmergencyButton) _buildEmergencyButton(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: indiaCenter,
        initialZoom: 5,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        Consumer<RiskStateProvider>(
          builder: (_, provider, _) {
            final searchState = provider.searchedRiskState;
            if (searchState != null) {
              return GestureDetector(
                onTap: () {
                  showRiskInfoSheet(context: context, state: searchState);
                },
                child: FloodZonesLayer(
                  center: LatLng(searchState.centerLat, searchState.centerLng),
                  currentRadius: searchState.currentRadius,
                  predictedRadius: searchState.predictedRadius,
                  color: getRiskColor(searchState.currentRisk),
                  isSelected: true,
                ),
              );
            }
            return const SizedBox();
          },
        ),
        _buildDemoFloodZones(),
        _buildFloodZones(),
        Consumer<RiskStateProvider>(
          builder: (_, provider, _) {
            return _buildZoneMarkers();
          },
        ),
        if (_searchedLocation != null)
          SearchLocationMarker(location: _searchedLocation!),
        if (_userLocation != null)
          UserLocationMarker(
            location: _userLocation!,
            pulseAnimation: _pulseController,
          ),
      ],
    );
  }

  Widget _buildDemoFloodZones() {
  return Consumer<DemoStateProvider>(
    builder: (_, demo, _) {
      final List<Widget> layers = [];

      // User Reported Flood
      if (demo.userReportedFlood != null) {
        final state = demo.userReportedFlood!;
        layers.add(
          GestureDetector(
            onTap: () {
              showRiskInfoSheet(context: context, state: state);
            },
            child: FloodZonesLayer(
              center: LatLng(state.centerLat, state.centerLng),
              currentRadius: state.currentRadius,
              predictedRadius: null,
              color: Colors.redAccent,
              isSelected: true,
            ),
          ),
        );
      }

      // Simulated Prediction
      if (demo.simulatedPrediction != null) {
        final state = demo.simulatedPrediction!;
        layers.add(
          GestureDetector(
            onTap: () {
              showRiskInfoSheet(context: context, state: state);
            },
            child: FloodZonesLayer(
              center: LatLng(state.centerLat, state.centerLng),
              currentRadius: state.currentRadius,
              predictedRadius: state.predictedRadius,
              color: Colors.deepOrange,
              isSelected: true,
            ),
          ),
        );
      }

      return layers.isEmpty ? const SizedBox() : Stack(children: layers);
    },
  );
}



  Widget _buildFloodZones() {
    return Consumer<RiskStateProvider>(
      builder: (_, provider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSafetyCheck(provider.effectiveRiskStates);
        });

        return Stack(
          children: provider.effectiveRiskStates.map((state) {
            final isSelected = provider.selectedZone?.districtId == state.districtId;
            return FloodZonesLayer(
              center: LatLng(state.centerLat, state.centerLng),
              currentRadius: state.currentRadius,
              predictedRadius: state.predictedRadius,
              color: getRiskColor(state.currentRisk),
              isSelected: isSelected,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildZoneMarkers() {
    return Consumer<RiskStateProvider>(
      builder: (_, provider, _) {
        return MarkerLayer(
          markers: provider.riskStates.map((state) {
            return Marker(
              point: LatLng(state.centerLat, state.centerLng),
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: () => _onFloodZoneTap(state),
                child: Icon(
                  getRiskIcon(state.currentRisk),
                  color: getRiskColor(state.currentRisk),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmergencyButton() {
    final isHighRisk = _safetyResult.status == SafetyStatus.inDangerZone;
    final buttonColor = isHighRisk ? Colors.red : Colors.orange;
    final buttonText = isHighRisk ? 'EMERGENCY' : 'SAFETY GUIDE';
    final icon = isHighRisk ? Icons.warning : Icons.security;

    return Positioned(
      top: 100, // Positioned below the navbar
      right: 16,
      child: GestureDetector(
        onTap: _openEmergencyScreen,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                buttonColor,
                buttonColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyStatus() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SafetyStatusIndicator(
        safetyResult: _safetyResult,
      ),
    );
  }
}