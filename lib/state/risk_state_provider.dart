import 'dart:async';
import 'package:flutter/material.dart';
import '../models/risk_state.dart';
import '../services/risk_firestore_service.dart';

class RiskStateProvider extends ChangeNotifier {
  final RiskFirestoreService _firestoreService;
  
  RiskState? _selectedZone;
  RiskState? get selectedZone => _selectedZone;

  RiskState? _demoOverride;
  Timer? _demoTimer;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  
  List<RiskState> _riskStates = [];
  List<RiskState> get riskStates => _riskStates;
  
  RiskState? _searchedRiskState;
  RiskState? get searchedRiskState => _searchedRiskState;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  StreamSubscription<List<RiskState>>? _subscription;
  Timer? _retryTimer;
  
  int _retryDelay = 2;
  bool _isListening = false;

  RiskStateProvider(this._firestoreService);

  bool get isShowingSearch => _searchedRiskState != null;

  RiskState? get displayRiskState {
    if (_searchedRiskState != null) return _searchedRiskState;
    if (_selectedZone != null) return _selectedZone;
    if (_riskStates.isNotEmpty) return _riskStates.first;
    return null;
  }


List<RiskState> get effectiveRiskStates {
  final List<RiskState> base = List<RiskState>.from(_riskStates);

  if (_demoOverride != null) {
    base.add(_demoOverride!);
  }

  return base;
}


  void setDemoRisk(RiskState? demoState) {
  _demoTimer?.cancel();

  _demoOverride = demoState;
  _isDemoMode = demoState != null;
  notifyListeners();

  if (demoState == null) return;

  // Escalate after 30s
  _demoTimer = Timer(const Duration(seconds: 60), () {
    if (_demoOverride == null) return;

    _demoOverride = RiskState(
      districtId: demoState.districtId,
      centerLat: demoState.centerLat,
      centerLng: demoState.centerLng,
      currentRadius: demoState.predictedRadius ?? demoState.currentRadius,
      predictedRadius: null,
      currentRisk: 'HIGH',
      predictedRisk: null,
      predictionWindow: null,
      confidence: demoState.confidence,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  });
}


  void stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;

    _demoOverride = null;
    _isDemoMode = false;
    notifyListeners();
  }





  void selectZone(RiskState zone) {
    _selectedZone = zone;
    notifyListeners();
  }

  void clearSelection() {
    _selectedZone = null;
    notifyListeners();
  }

  void setSearchedRiskState(RiskState? state) {
    _searchedRiskState = state;
    notifyListeners();
  }

  void clearSearch() {
    _searchedRiskState = null;
    notifyListeners();
  }

  void startListeningAll() {
    if (_isListening) return;

    _isListening = true;
    _isLoading = _riskStates.isEmpty;
    notifyListeners();

    _subscription = _firestoreService.streamAllRiskStates().listen(
      (states) {
        _retryDelay = 2;
        _error = null;
        _isLoading = false;

        if (!_listsAreEqual(_riskStates, states)) {
          _riskStates = states;
          
          if (_selectedZone != null) {
            final match = _riskStates.where(
              (s) => s.districtId == _selectedZone!.districtId,
            );
            if (match.isNotEmpty) {
              _selectedZone = match.first;
            }
          }
          
          notifyListeners();
        }
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        _subscription?.cancel();
        _subscription = null;
        _isListening = false;
        _scheduleRetry();
        notifyListeners();
      },
    );
  }

  void pauseListening() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  void _scheduleRetry() {
    if (_retryTimer != null && _retryTimer!.isActive) return;

    _retryTimer = Timer(
      Duration(seconds: _retryDelay),
      () {
        _retryTimer = null;
        _isListening = false;
        startListeningAll();
        _retryDelay = (_retryDelay * 2).clamp(2, 60);
      },
    );
  }

  bool _listsAreEqual(List<RiskState> a, List<RiskState> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}