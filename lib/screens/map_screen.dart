import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sw2/widgets/flood_zones_layer.dart';
import 'package:sw2/widgets/map_app_bar.dart';
import 'package:sw2/widgets/risk_info_sheet.dart';
import 'package:sw2/widgets/risk_panel.dart';
import 'package:sw2/widgets/search_location_dialog.dart';
import 'package:sw2/widgets/user_location_marker.dart';

import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  // 🔴 PHASE 2: Dummy current flood risk (Chennai)
  final LatLng _floodCenter = LatLng(13.0827, 80.2707);
  final double _currentFloodRadius = 5000;
  final double? _predictedFloodRadius = 8000;
  final String _currentRiskLevel = 'HIGH';
  
  // Multiple flood zones for realistic effect
  // ignore: unused_field
  final List<Map<String, dynamic>> _floodZones = [
    {'center': LatLng(13.0827, 80.2707), 'radius': 3000.0, 'severity': 'CRITICAL'},
    {'center': LatLng(13.0927, 80.2807), 'radius': 2000.0, 'severity': 'HIGH'},
    {'center': LatLng(13.0727, 80.2607), 'radius': 2500.0, 'severity': 'HIGH'},
    {'center': LatLng(13.0627, 80.2907), 'radius': 1800.0, 'severity': 'MODERATE'},
  ];

  // 🔵 User location
  LatLng? _userLocation;
  bool _hasMovedCamera = false;
  bool _showRiskPanel = true;
  
  static final LatLng indiaCenter = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadUserLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getFloodColor() {
    switch (_currentRiskLevel) {
      case 'LOW':
        return Colors.green;
      case 'MODERATE':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }
  IconData _getRiskIcon() {
    switch (_currentRiskLevel) {
      case 'LOW':
        return Icons.check_circle;
      case 'MODERATE':
        return Icons.warning_amber_rounded;
      case 'HIGH':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
  void _onFloodZoneTap() {
    showRiskInfoSheet(
      context: context,
      districtName: 'Chennai District',
      currentRisk: _currentRiskLevel,
      predictedRisk:
          _predictedFloodRadius != null ? _currentRiskLevel : null,
      predictionWindow:
          _predictedFloodRadius != null ? 'Next 6–12 hours' : null,
      lastUpdated: DateTime.now(),
    );
  }
  Future<void> _loadUserLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();

    if (position == null) return;

    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocation = userLatLng;
    });

    if (!_hasMovedCamera) {
      _mapController.move(userLatLng, 13);
      _hasMovedCamera = true;
    }
  }
  Future<void> _openSearchDialog() async {
  final place = await showSearchLocationDialog(context);

  if (place == null || place.trim().isEmpty) return;

  try {
    final locations = await locationFromAddress(place);
    if (locations.isEmpty) return;

    final latLng = LatLng(
      locations.first.latitude,
      locations.first.longitude,
    );

    _mapController.move(latLng, 12);
  } catch (_) {}
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: indiaCenter,
              initialZoom: 5,
              minZoom: 3,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hydrasense',
              ),
              FloodZonesLayer(
                center: _floodCenter,
                currentRadius: _currentFloodRadius,
                predictedRadius: _predictedFloodRadius,
                color: _getFloodColor(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _floodCenter,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: _onFloodZoneTap,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
              // User location marker
              if (_userLocation != null)
                UserLocationMarker(
                  location: _userLocation!,
                  pulseAnimation: _pulseController,
              ),
            ],
          ),
          // Top Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          MapAppBar(
            onSearchTap: _openSearchDialog,
            onMyLocationTap: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 13);
              }
            },
          ),
          if (_showRiskPanel)
            RiskPanel(
              riskLevel: _currentRiskLevel,
              riskColor: _getFloodColor(),
              riskIcon: _getRiskIcon(),
              onClose: () {
                setState(() => _showRiskPanel = false);
              },
            ),
          // Floating Action Button - Toggle Risk Panel
          if (!_showRiskPanel)
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showRiskPanel = true;
                  });
                },
                backgroundColor: _getFloodColor(),
                child: const Icon(Icons.info_outline, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}