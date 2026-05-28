enum ConnectivityStatus { online, offline }

abstract class ConnectivityService {
  Future<ConnectivityStatus> currentStatus();

  Stream<ConnectivityStatus> get statusStream;
}
