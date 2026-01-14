import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

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
    final controller = TextEditingController();

    final place = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Search Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter city or area name',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

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
              // Flood risk zone with pulse effect
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _floodCenter,
                    radius: _currentFloodRadius,
                    useRadiusInMeter: true,
                    color: _getFloodColor().withOpacity(0.25),
                    borderColor: _getFloodColor(),
                    borderStrokeWidth: 2,
                  ),
                  if (_predictedFloodRadius != null &&
                    _predictedFloodRadius > _currentFloodRadius)
                    CircleMarker(
                      point: _floodCenter,
                      radius: _predictedFloodRadius,
                      useRadiusInMeter: true,
                      color: _getFloodColor().withOpacity(0.15),
                      borderStrokeWidth: 1,
                      borderColor: _getFloodColor().withOpacity(0.4),
                    ),
                ],
              ),
              // User location marker
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse effect
                              Container(
                                width: 60 * (1 + _pulseController.value * 0.5),
                                height: 60 * (1 + _pulseController.value * 0.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(
                                    0.3 * (1 - _pulseController.value),
                                  ),
                                ),
                              ),
                              // User marker
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
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

          // Modern App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Title with icon
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_damage,
                          color: Colors.blue.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'HydraSense',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Search button
                  _buildActionButton(
                    icon: Icons.search,
                    onTap: _openSearchDialog,
                  ),
                  const SizedBox(width: 8),
                  // My location button
                  _buildActionButton(
                    icon: Icons.my_location,
                    onTap: () {
                      if (_userLocation != null) {
                        _mapController.move(_userLocation!, 13);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Risk Level Panel
          if (_showRiskPanel)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getFloodColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getRiskIcon(),
                            color: _getFloodColor(),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_currentRiskLevel RISK',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getFloodColor(),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chennai Area',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showRiskPanel = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}