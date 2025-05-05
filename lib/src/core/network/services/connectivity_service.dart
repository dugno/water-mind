import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interface for connectivity service
abstract class ConnectivityService {
  /// Check if the device is connected to the internet
  Future<bool> isConnected();
  
  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of ConnectivityService using InternetConnectionChecker
class ConnectivityServiceImpl implements ConnectivityService {
  final InternetConnectionChecker _connectionChecker;

  /// Constructor for ConnectivityServiceImpl
  ConnectivityServiceImpl({InternetConnectionChecker? connectionChecker})
      : _connectionChecker = connectionChecker ?? InternetConnectionChecker();

  @override
  Future<bool> isConnected() async {
    return await _connectionChecker.hasConnection;
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectionChecker.onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
      );
}
