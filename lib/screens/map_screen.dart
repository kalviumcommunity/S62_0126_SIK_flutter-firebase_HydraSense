import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/risk_state.dart';
import '../state/risk_state_provider.dart';
import '../services/location_service.dart';
import '../services/safety_service.dart';
import '../widgets/safety_widgets.dart';

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

  void _updateSafetyCheck(List<RiskState> riskStates) async {
    if (_checkingSafety || _userLocation == null) return;

    _checkingSafety = true;

    final result =
        await SafetyService.checkUserSafety(_userLocation, riskStates);

    if (mounted) {
      setState(() => _safetyResult = result);
    }

    _checkingSafety = false;
  }

  void _onFloodZoneTap(RiskState state) {
    context.read<RiskStateProvider>().selectZone(state);

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
      predictionWindow:
          state.predictionWindow != null ? '${state.predictionWindow} hours' : null,
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

  void _goToMyLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 13);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          MapAppBar(
            onSearchTap: _openSearchDialog,
            onMyLocationTap: _goToMyLocation,
          ),
          _buildRiskPanel(),
          if (_safetyResult.isInDanger) _buildSafetyAlert(),
          _buildSafetyStatus(),
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hydrasense',
        ),
        _buildFloodZones(),
        _buildZoneMarkers(),
        if (_userLocation != null)
          UserLocationMarker(
            location: _userLocation!,
            pulseAnimation: _pulseController,
          ),
      ],
    );
  }

  Widget _buildFloodZones() {
    return Consumer<RiskStateProvider>(
      builder: (_, provider, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSafetyCheck(provider.riskStates);
        });

        return IgnorePointer(
          ignoring: true,
          child: Stack(
            children: provider.riskStates.map((state) {
              final isSelected =
                  provider.selectedZone?.districtId == state.districtId;

              return FloodZonesLayer(
                center: LatLng(state.centerLat, state.centerLng),
                currentRadius: state.currentRadius,
                predictedRadius: state.predictedRadius,
                color: getRiskColor(state.currentRisk),
                isSelected: isSelected,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildZoneMarkers() {
    return Consumer<RiskStateProvider>(
      builder: (_, provider, __) {
        return MarkerLayer(
          markers: provider.riskStates.map((state) {
            return Marker(
              point: LatLng(state.centerLat, state.centerLng),
              width: 60,
              height: 60,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onFloodZoneTap(state),
                child: const SizedBox(
                  width: 60,
                  height: 60,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRiskPanel() {
    return Consumer<RiskStateProvider>(
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
    );
  }

  Widget _buildSafetyAlert() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: SafetyAlertBanner(
        safetyResult: _safetyResult,
        onTap: () {
          if (_userLocation != null) {
            _mapController.move(_userLocation!, 13);
          }
        },
      ),
    );
  }

  Widget _buildSafetyStatus() {
    return Positioned(
      bottom: _safetyResult.isInDanger ? 88 : 16,
      left: 16,
      right: 16,
      child: SafetyStatusIndicator(safetyResult: _safetyResult),
    );
  }
}
