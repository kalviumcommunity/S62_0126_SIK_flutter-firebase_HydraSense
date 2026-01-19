import 'dart:async';
import 'package:flutter/material.dart';
import '../models/risk_state.dart';
import '../services/firestore_service.dart';

class RiskStateProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  RiskStateProvider(this._firestoreService);

  List<RiskState> _riskStates = [];
  List<RiskState> get riskStates => _riskStates;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<RiskState>>? _subscription;
  Timer? _retryTimer;

  bool _started = false;
  int _retryDelay = 2;

  void startListeningAll() {
    if (_started) return;
    _started = true;

    _subscription = _firestoreService.streamAllRiskStates().listen(
      (states) {
        _retryDelay = 2;
        _error = null;
        _isLoading = false;

        if (!_listsAreEqual(_riskStates, states)) {
          _riskStates = states;
          notifyListeners();
        }
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        _scheduleRetry();
        notifyListeners();
      },
    );
  }

  void pauseListening() {
    _subscription?.cancel();
    _subscription = null;
    _retryTimer?.cancel();
    _started = false;
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();

    _retryTimer = Timer(
      Duration(seconds: _retryDelay),
      () {
        _started = false;
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
    _subscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
