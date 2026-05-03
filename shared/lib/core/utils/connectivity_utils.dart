import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Classifies exceptions according to the RPD/STANDARDS connectivity rules.
///
/// Connectivity-like errors → cache fallback ALLOWED
/// Non-connectivity errors → surface error, NO fallback
class ConnectivityUtils {
  ConnectivityUtils._();

  /// Returns `true` if [error] looks like a network / socket / timeout error
  /// and cache fallback is permitted.
  static bool isConnectivityError(Object error) {
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is TlsException) return true;

    final msg = error.toString().toLowerCase();
    if (msg.contains('timeout')) return true;
    if (msg.contains('connection refused')) return true;
    if (msg.contains('network')) return true;
    if (msg.contains('socket')) return true;
    if (msg.contains('no address associated')) return true;
    // Supabase / postgrest can surface connectivity issues as generic strings
    if (msg.contains('failed host lookup')) return true;

    return false;
  }

  /// Convenience method: check actual device connectivity.
  static Future<bool> hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }
}
