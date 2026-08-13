import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { online, offline }

final connectivityProvider = StreamProvider<ConnectionStatus>((ref) {
  return Connectivity().onConnectivityChanged.map((result) {
    // connectivity_plus 6.x returns List<ConnectivityResult>
    if (result.contains(ConnectivityResult.none)) {
      return ConnectionStatus.offline;
    }
    return ConnectionStatus.online;
  });
});
