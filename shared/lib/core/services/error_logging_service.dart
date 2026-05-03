import 'package:supabase_flutter/supabase_flutter.dart';
import '../../enums.dart';

/// Wraps the Supabase `log_error(...)` SECURITY DEFINER RPC so that error
/// writes bypass RLS.
///
/// Falls back to a no-op if the RPC call itself fails (never throws).
class ErrorLoggingService {
  final SupabaseClient _client;
  final String sourceProject;

  const ErrorLoggingService({
    required SupabaseClient client,
    required this.sourceProject,
  }) : _client = client;

  /// Log an error to the DB via the `public.log_error` RPC.
  ///
  /// - [source]: feature / screen label (e.g. `'places.list'`)
  /// - [message]: short human-readable message
  /// - [stack]: optional stack trace string
  /// - [context]: extra key-value data (feature, fallback outcome, platform…)
  /// - [severity]: defaults to `error`
  /// - [occurredOffline]: set `true` when the event occurred without connectivity
  /// - [occurredAtClient]: timestamp of the original failure — useful for offline queue flush
  Future<void> log(
    Object error,
    StackTrace? stackTrace, {
    required String source,
    Map<String, dynamic> context = const {},
    LogSeverity severity = LogSeverity.error,
    bool occurredOffline = false,
    DateTime? occurredAtClient,
  }) async {
    try {
      final ctx = {
        ...context,
        'source_project': sourceProject,
      };
      await _client.rpc('log_error', params: {
        'p_source': source,
        'p_severity': severity.dbValue,
        'p_message': error.toString(),
        'p_stack': stackTrace?.toString(),
        'p_context': ctx,
        'p_occurred_offline': occurredOffline,
        'p_occurred_at_client': occurredAtClient?.toIso8601String(),
      });
    } catch (_) {
      // Never let logging break the caller.
    }
  }
}
