import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sw2/utils/risk_ui_utils.dart';
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

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  // 🔴 Dummy flood data
  final LatLng _floodCenter = LatLng(13.0827, 80.2707);
  final double _currentFloodRadius = 5000;
  final double? _predictedFloodRadius = 8000;
  final String _currentRiskLevel = 'HIGH';

  // 🔵 Locations
  LatLng? _userLocation;
  LatLng? _searchedLocation;

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

  /// 📍 Load current user location
  Future<void> _loadUserLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();
    if (position == null) return;

    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocation = latLng;
    });

    if (!_hasMovedCamera) {
      _mapController.move(latLng, 13);
      _hasMovedCamera = true;
    }
  }

  /// 🔎 Open search dialog and zoom + pin
  Future<void> _openSearchDialog() async {
    final result = await showSearchLocationDialog(context);
    if (result == null) return;

    final lat = (result['lat'] as num).toDouble();
    final lon = (result['lon'] as num).toDouble();
    final latLng = LatLng(lat, lon);

    setState(() {
      _searchedLocation = latLng;
    });

    _mapController.move(latLng, 15);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🗺️ MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: indiaCenter,
              initialZoom: 5,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hydrasense',
              ),

              FloodZonesLayer(
                center: _floodCenter,
                currentRadius: _currentFloodRadius,
                predictedRadius: _predictedFloodRadius,
                color: getRiskColor(_currentRiskLevel),
              ),

              /// 📍 MARKERS
              MarkerLayer(
                markers: [
                  // Flood center marker
                  Marker(
                    point: _floodCenter,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: _onFloodZoneTap,
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                  // User location marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 60,
                      height: 60,
                      child: UserLocationMarker(
                        location: _userLocation!,
                        pulseAnimation: _pulseController,
                      ),
                    ),

                  // 🔴 Searched location marker
                  if (_searchedLocation != null)
                    Marker(
                      point: _searchedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          /// 🔝 APP BAR
          MapAppBar(
            onSearchTap: _openSearchDialog,
            onMyLocationTap: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 13);
              }
            },
          ),

          /// ⚠️ RISK PANEL
          if (_showRiskPanel)
            RiskPanel(
              riskLevel: _currentRiskLevel,
              riskColor: getRiskColor(_currentRiskLevel),
              riskIcon: getRiskIcon(_currentRiskLevel),
              onClose: () {
                setState(() => _showRiskPanel = false);
              },
            ),

          if (!_showRiskPanel)
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() => _showRiskPanel = true);
                },
                backgroundColor: getRiskColor(_currentRiskLevel),
                child:
                    const Icon(Icons.info_outline, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
