import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream of connectivity result lists from the device.
/// connectivity_plus 6.x emits [List<ConnectivityResult>].
final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// [true] when the device has at least one active network connection.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  return connectivityAsync.when(
    data: (results) => results.any((r) => r != ConnectivityResult.none),
    loading: () => true, // optimistic while loading
    error: (_, __) => true, // optimistic on error
  );
});
