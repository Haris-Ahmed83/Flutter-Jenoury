import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStatusController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    checkConnection();
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    final connected = !results.contains(ConnectivityResult.none);
    _isConnected = connected;
    _connectionStatusController.add(connected);
    return connected;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = !results.contains(ConnectivityResult.none);
    _isConnected = connected;
    _connectionStatusController.add(connected);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
