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

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // 🔵 User location (nullable)
  LatLng? _userLocation;

  // 🔒 Ensures camera moves only once
  bool _hasMovedCamera = false;

  // 🇮🇳 Fallback center (when location denied)
  static final LatLng indiaCenter = LatLng(
    20.5937,
    78.9629,
  );

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  /// 📍 Fetch user location (non-blocking)
  Future<void> _loadUserLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();

    if (position == null) {
      // Location denied / unavailable → do nothing
      return;
    }

    final userLatLng = LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _userLocation = userLatLng;
    });

    // Move camera to user only once
    if (!_hasMovedCamera) {
      _mapController.move(userLatLng, 13);
      _hasMovedCamera = true;
    }
  }

  /// 🔍 Open search dialog and move map
  Future<void> _openSearchDialog() async {
    final controller = TextEditingController();

    final place = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search location'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter city / area name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Search'),
            ),
          ],
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
    } catch (_) {
      // Fail silently (no crash, no error spam)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Risk Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchDialog,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: indiaCenter,
          initialZoom: 5,

          // 🔎 Explicit zoom limits
          minZoom: 3,
          maxZoom: 18,

          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.drag |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          // 🗺️ OpenStreetMap tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.hydrasense',
          ),

          // 🔵 User location marker
          if (_userLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _userLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
