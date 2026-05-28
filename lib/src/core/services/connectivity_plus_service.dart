import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<ConnectivityStatus> currentStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _toStatus(results);
  }

  @override
  Stream<ConnectivityStatus> get statusStream => _connectivity
      .onConnectivityChanged
      .map(_toStatus);

  ConnectivityStatus _toStatus(List<ConnectivityResult> results) {
    final hasNetwork = results.any((r) =>
        r != ConnectivityResult.none && r != ConnectivityResult.bluetooth);
    return hasNetwork ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }
}
