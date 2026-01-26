import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/risk_state.dart';
import '../state/risk_state_provider.dart';
import '../services/location_service.dart';

import '../utils/risk_ui_utils.dart';
import '../widgets/flood_zones_layer.dart';
import '../widgets/map_app_bar.dart';
import '../widgets/risk_info_sheet.dart';
import '../widgets/risk_panel.dart';
import '../widgets/search_location_dialog.dart';
import '../widgets/user_location_marker.dart';

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

    setState(() => _userLocation = latLng);

    if (!_hasMovedCamera) {
      _mapController.move(latLng, 13);
      _hasMovedCamera = true;
    }
  }

  void _onFloodZoneTap(RiskState state) {
    final provider = context.read<RiskStateProvider>();

    provider.selectZone(state);

    final center = LatLng(state.centerLat, state.centerLng);

    _mapController.move(
      center,
      _mapController.camera.zoom < 10 ? 10 : _mapController.camera.zoom,
    );

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

    _mapController.move(
      LatLng(place['lat'], place['lon']),
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
              rotation: 0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
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
                  return IgnorePointer(
                    ignoring: true,
                    child: Stack(
                      children: provider.riskStates.map((state) {
                        final bool isSelected =
                            provider.selectedZone?.districtId ==
                                state.districtId;

                        final center =
                            LatLng(state.centerLat, state.centerLng);

                        return FloodZonesLayer(
                          center: center,
                          currentRadius: state.currentRadius,
                          predictedRadius: state.predictedRadius,
                          color: getRiskColor(state.currentRisk),
                          isSelected: isSelected,
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              Consumer<RiskStateProvider>(
                builder: (_, provider, __) {
                  return MarkerLayer(
                    markers: provider.riskStates.map((state) {
                      final center =
                          LatLng(state.centerLat, state.centerLng);

                      return Marker(
                        point: center,
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _onFloodZoneTap(state),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.transparent,
                          ),
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
                onClose: () => setState(() => _showRiskPanel = false),
              );
            },
          ),
        ],
      ),
    );
  }
}
