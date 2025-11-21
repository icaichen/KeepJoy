import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network Connectivity Service
/// Monitors network state and notifies listeners of changes
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance {
    _instance ??= ConnectivityService._();
    return _instance!;
  }

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = false;
  bool _isWifi = false;
  bool _isMobile = false;

  final _connectivityController = StreamController<bool>.broadcast();

  /// Stream of connectivity changes (true = connected, false = disconnected)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connection state
  bool get isConnected => _isConnected;
  bool get isWifi => _isWifi;
  bool get isMobile => _isMobile;

  /// Initialize and start monitoring
  Future<void> init() async {
    debugPrint('🌐 Initializing connectivity service...');

    // Check initial state
    final result = await _connectivity.checkConnectivity();
    _updateState(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);

    debugPrint('✅ Connectivity service initialized');
    debugPrint(
      '   Connected: $_isConnected, WiFi: $_isWifi, Mobile: $_isMobile',
    );
  }

  void _updateState(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    _isWifi = results.contains(ConnectivityResult.wifi);
    _isMobile = results.contains(ConnectivityResult.mobile);
    _isConnected =
        _isWifi ||
        _isMobile ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn);

    // Notify listeners if connectivity changed
    if (_isConnected != wasConnected) {
      debugPrint(
        '🌐 Connectivity changed: ${_isConnected ? "Online" : "Offline"}',
      );
      _connectivityController.add(_isConnected);
    }
  }

  /// Check if we should sync (based on user preferences)
  /// For now, always allow sync on any connection (as per user config)
  bool get shouldSync => _isConnected;

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
    debugPrint('📴 Connectivity service disposed');
  }
}
