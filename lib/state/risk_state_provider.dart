import 'dart:async';
import 'package:flutter/material.dart';
import '../models/risk_state.dart';
import '../services/risk_firestore_service.dart';

class RiskStateProvider extends ChangeNotifier {
  final RiskFirestoreService _firestoreService;
  
  RiskState? _selectedZone;
  RiskState? get selectedZone => _selectedZone;
  
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