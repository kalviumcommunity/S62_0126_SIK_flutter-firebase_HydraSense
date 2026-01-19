import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sw2/models/risk_state.dart';

import 'package:sw2/utils/risk_ui_utils.dart';
import 'package:sw2/widgets/flood_zones_layer.dart';
import 'package:sw2/widgets/map_app_bar.dart';
import 'package:sw2/widgets/risk_info_sheet.dart';
import 'package:sw2/widgets/risk_panel.dart';
import 'package:sw2/widgets/search_location_dialog.dart';
import 'package:sw2/widgets/user_location_marker.dart';

import '../state/risk_state_provider.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiskStateProvider>().startListeningAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<RiskStateProvider>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      provider.pauseListening();
    } else if (state == AppLifecycleState.resumed) {
      provider.startListeningAll();
    }
  }

  Future<void> _loadUserLocation() async {
    final position = await LocationService().getCurrentLocation();
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

  void _onFloodZoneTap(RiskState state) {
    showRiskInfoSheet(
      context: context,
      districtName: state.districtId,
      currentRisk: state.currentRisk,
      predictedRisk: state.predictedRisk,
      predictionWindow: state.predictionWindow != null
          ? '${state.predictionWindow} hours'
          : null,
      lastUpdated: state.updatedAt,
    );
  }

  Future<void> _openSearchDialog() async {
    final place = await showSearchLocationDialog(context);
    if (place == null) return;

    final double lat = place['lat'];
    final double lon = place['lon'];

    _mapController.move(
      LatLng(lat, lon),
      12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hydrasense',
              ),
              Consumer<RiskStateProvider>(
                builder: (_, provider, __) {
                  return Stack(
                    children: provider.riskStates.map((state) {
                      return FloodZonesLayer(
                        center: state.center,
                        currentRadius: state.currentRadius,
                        predictedRadius: state.predictedRadius,
                        color: getRiskColor(state.currentRisk),
                      );
                    }).toList(),
                  );
                },
              ),
              Consumer<RiskStateProvider>(
                builder: (_, provider, __) {
                  return MarkerLayer(
                    markers: provider.riskStates.map((state) {
                      return Marker(
                        point: state.center,
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _onFloodZoneTap(state),
                          child: const SizedBox(),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              if (_userLocation != null)
                UserLocationMarker(
                  location: _userLocation!,
                  pulseAnimation: _pulseController,
                ),
            ],
          ),
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
          Consumer<RiskStateProvider>(
            builder: (_, provider, __) {
              if (!_showRiskPanel || provider.riskStates.isEmpty) {
                return const SizedBox();
              }

              final risk = provider.riskStates.first;

              return RiskPanel(
                title: 'Flood Risk: ${risk.currentRisk.toUpperCase()}',
                subtitle: risk.predictedRisk != null
                    ? 'Predicted to increase in ${risk.predictionWindow} hrs'
                    : 'No immediate escalation predicted',
                riskColor: getRiskColor(risk.currentRisk),
                riskIcon: getRiskIcon(risk.currentRisk),
                onClose: () {
                  setState(() => _showRiskPanel = false);
                },
              );
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
                child: const Icon(Icons.info_outline),
              ),
            ),
        ],
      ),
    );
  }
}
