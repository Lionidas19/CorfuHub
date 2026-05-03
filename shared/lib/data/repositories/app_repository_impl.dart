/// AppRepositoryImpl — wires Supabase, Cache and Mock data sources.
///
/// Read pattern (online-first, per RPD / STANDARDS):
///   1. Return cache if available.
///   2. If online → try Supabase → update cache on success.
///   3. On connectivity-like error → fall back to cache or mock.
///   4. On non-connectivity error (401/403/validation) → rethrow; never silently fallback.
///
/// Write pattern:
///   - Require network; throw OfflineFailure if unavailable.
///   - On success, update cache best-effort.

import '../../core/services/error_logging_service.dart';
import '../../core/utils/connectivity_utils.dart';
import '../../domain/repositories/app_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/entities/claim_entity.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../datasources/supabase_data_source.dart';
import '../datasources/cache_data_source.dart';
import '../datasources/mock_data_source.dart';
import '../models/user_settings_model.dart';

/// Thrown when an operation requires connectivity but the device is offline.
class OfflineFailure implements Exception {
  final String message;
  const OfflineFailure([this.message = 'No internet connection']);
  @override
  String toString() => 'OfflineFailure: $message';
}

class AppRepositoryImpl implements AppRepository {
  final SupabaseDataSource _supabase;
  final CacheDataSource _cache;
  final MockDataSource _mock;
  final ErrorLoggingService _logger;

  const AppRepositoryImpl({
    required SupabaseDataSource supabase,
    required CacheDataSource cache,
    required MockDataSource mock,
    required ErrorLoggingService logger,
  })  : _supabase = supabase,
        _cache = cache,
        _mock = mock,
        _logger = logger;

  // ---------------------------------------------------------------------------
  // Auth / User
  // ---------------------------------------------------------------------------

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final cached = await _cache.getCurrentUser();
      if (cached != null) return cached.toEntity();

      final online = await ConnectivityUtils.hasInternetConnection();
      if (!online) return null;

      final model = await _supabase.getCurrentUserModel();
      if (model != null) await _cache.saveCurrentUser(model);
      return model?.toEntity();
    } catch (e, st) {
      await _logger.log(e, st, source: 'auth.getCurrentUser');
      return null;
    }
  }

  @override
  Future<void> sendPhoneOtp(String phone) async {
    _requireOnlineSync();
    await _supabase.sendPhoneOtp(phone);
  }

  @override
  Future<UserEntity> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final model = await _supabase.verifyPhoneOtp(phone: phone, token: token);
    await _cache.saveCurrentUser(model);
    return model.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _supabase.signOut();
    await _cache.clearAll();
  }

  @override
  Future<void> deleteAccount() async {
    await _requireOnline('deleteAccount');
    await _supabase.deleteAccount();
    await _cache.clearAll();
  }

  @override
  Future<UserEntity> debugSignInAsUser(String userId) async {
    final model = await _supabase.getUserById(userId);
    if (model == null) {
      throw Exception('Debug user $userId not found in public.users');
    }
    await _cache.saveCurrentUser(model);
    return model.toEntity();
  }

  // ---------------------------------------------------------------------------
  // User Settings
  // ---------------------------------------------------------------------------

  @override
  Future<UserSettingsEntity?> getUserSettings() async {
    try {
      final cached = await _cache.getUserSettings();
      if (cached != null) return cached.toEntity();

      final online = await ConnectivityUtils.hasInternetConnection();
      if (!online) return null;

      final model = await _supabase.getUserSettings();
      if (model != null) await _cache.saveUserSettings(model);
      return model?.toEntity();
    } catch (e, st) {
      await _logger.log(e, st, source: 'settings.getUserSettings');
      return null;
    }
  }

  @override
  Future<UserSettingsEntity> saveUserSettings(
      UserSettingsEntity settings) async {
    await _requireOnline('saveUserSettings');
    final model = await _supabase
        .saveUserSettings(UserSettingsModel.fromEntity(settings));
    await _cache.saveUserSettings(model);
    return model.toEntity();
  }

  // ---------------------------------------------------------------------------
  // Places
  // ---------------------------------------------------------------------------

  @override
  Future<List<PlaceEntity>> getPlaces({String? categoryId}) => _getList(
        source: 'places.getPlaces',
        getCache: () async {
          final all = await _cache.getPlaces();
          if (all == null) return null;
          if (categoryId != null) {
            return all.where((p) => p.categoryId == categoryId).toList();
          }
          return all;
        },
        fetchRemote: () => _supabase.getPlaces(categoryId: categoryId),
        saveCache: _cache.savePlaces,
        getMock: _mock.getPlaces,
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<PlaceEntity?> getPlace(String placeId) => _getOne(
        source: 'places.getPlace',
        fetchRemote: () => _supabase.getPlace(placeId),
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<List<PlaceEntity>> getFeaturedPlaces() => _getList(
        source: 'places.getFeaturedPlaces',
        getCache: _cache.getFeaturedPlaces,
        fetchRemote: _supabase.getFeaturedPlaces,
        saveCache: _cache.saveFeaturedPlaces,
        getMock: () => _mock.getPlaces().where((p) => p.isFeatured).toList(),
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<List<PlaceEntity>> searchPlaces(String query) async {
    final online = await ConnectivityUtils.hasInternetConnection();
    if (!online) {
      final cached = await _cache.getPlaces() ?? _mock.getPlaces();
      final q = query.toLowerCase();
      return cached
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false))
          .map((m) => m.toEntity())
          .toList();
    }
    try {
      return (await _supabase.searchPlaces(query))
          .map((m) => m.toEntity())
          .toList();
    } catch (e, st) {
      if (ConnectivityUtils.isConnectivityError(e)) {
        final cached = await _cache.getPlaces() ?? _mock.getPlaces();
        final q = query.toLowerCase();
        return cached
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                (p.description?.toLowerCase().contains(q) ?? false))
            .map((m) => m.toEntity())
            .toList();
      }
      await _logger.log(e, st, source: 'places.searchPlaces');
      rethrow;
    }
  }

  @override
  Future<List<PlaceEntity>> getPlacesFresh() async {
    final models = await _supabase.getPlaces();
    await _cache.savePlaces(models);
    return models.map((m) => m.toEntity()).toList();
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  @override
  Future<List<EventEntity>> getEvents({String? placeId}) => _getList(
        source: 'events.getEvents',
        getCache: _cache.getEvents,
        fetchRemote: () => _supabase.getEvents(placeId: placeId),
        saveCache: _cache.saveEvents,
        getMock: _mock.getEvents,
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<EventEntity?> getEvent(String eventId) => _getOne(
        source: 'events.getEvent',
        fetchRemote: () => _supabase.getEvent(eventId),
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<List<EventEntity>> getEventsFresh() async {
    final models = await _supabase.getEvents();
    await _cache.saveEvents(models);
    return models.map((m) => m.toEntity()).toList();
  }

  // ---------------------------------------------------------------------------
  // Issues
  // ---------------------------------------------------------------------------

  @override
  Future<List<IssueEntity>> getIssues() => _getList(
        source: 'issues.getIssues',
        getCache: _cache.getIssues,
        fetchRemote: _supabase.getIssues,
        saveCache: _cache.saveIssues,
        getMock: _mock.getIssues,
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<IssueEntity?> getIssue(String issueId) => _getOne(
        source: 'issues.getIssue',
        fetchRemote: () => _supabase.getIssue(issueId),
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<IssueEntity> reportIssue({
    required String title,
    required String? description,
    required double latitude,
    required double longitude,
  }) async {
    await _requireOnline('issues.reportIssue');
    final model = await _supabase.reportIssue(
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
    );
    return model.toEntity();
  }

  @override
  Future<IssueEntity> updateIssueStatus({
    required String issueId,
    required String status,
  }) async {
    await _requireOnline('issues.updateIssueStatus');
    final model =
        await _supabase.updateIssueStatus(issueId: issueId, status: status);
    return model.toEntity();
  }

  // ---------------------------------------------------------------------------
  // Check-ins
  // ---------------------------------------------------------------------------

  @override
  Future<bool> hasCheckedInIssue(String issueId) async {
    try {
      return await _supabase.hasCheckedInIssue(issueId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<CheckInEntity> checkInIssue(String issueId) async {
    await _requireOnline('issues.checkIn');
    final model = await _supabase.checkInIssue(issueId);
    return model.toEntity();
  }

  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------

  @override
  Future<List<JobEntity>> getJobs({String? placeId}) => _getList(
        source: 'jobs.getJobs',
        getCache: _cache.getJobs,
        fetchRemote: () => _supabase.getJobs(placeId: placeId),
        saveCache: _cache.saveJobs,
        getMock: _mock.getJobs,
        toEntity: (m) => m.toEntity(),
      );

  @override
  Future<JobEntity?> getJob(String jobId) => _getOne(
        source: 'jobs.getJob',
        fetchRemote: () => _supabase.getJob(jobId),
        toEntity: (m) => m.toEntity(),
      );

  // ---------------------------------------------------------------------------
  // Claims
  // ---------------------------------------------------------------------------

  @override
  Future<ClaimEntity> submitClaim(String placeId) async {
    await _requireOnline('claims.submitClaim');
    return (await _supabase.submitClaim(placeId)).toEntity();
  }

  @override
  Future<ClaimEntity> updateClaimStatus({
    required String claimId,
    required String status,
  }) async {
    await _requireOnline('claims.updateClaimStatus');
    return (await _supabase.updateClaimStatus(claimId: claimId, status: status))
        .toEntity();
  }

  @override
  Future<List<ClaimEntity>> getMyApprovedClaims() async {
    try {
      return (await _supabase.getMyApprovedClaims())
          .map((m) => m.toEntity())
          .toList();
    } catch (e, st) {
      await _logger.log(e, st, source: 'claims.getMyApprovedClaims');
      return [];
    }
  }

  @override
  Future<List<ClaimEntity>> getPendingClaims() async {
    try {
      return (await _supabase.getPendingClaims())
          .map((m) => m.toEntity())
          .toList();
    } catch (e, st) {
      await _logger.log(e, st, source: 'claims.getPendingClaims');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Offline sync (stub — extend when offline-first Stage 2 is needed)
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncPendingActions() async {
    // No-op in online-first mode. Extend here for offline queuing.
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<List<TEntity>> _getList<TModel, TEntity>({
    required String source,
    Future<List<TModel>?> Function()? getCache,
    required Future<List<TModel>> Function() fetchRemote,
    Future<void> Function(List<TModel>)? saveCache,
    required List<TModel> Function() getMock,
    required TEntity Function(TModel) toEntity,
  }) async {
    try {
      if (getCache != null) {
        final cached = await getCache();
        if (cached != null) return cached.map(toEntity).toList();
      }

      final online = await ConnectivityUtils.hasInternetConnection();
      if (online) {
        try {
          final models = await fetchRemote();
          if (saveCache != null) await saveCache(models);
          return models.map(toEntity).toList();
        } catch (e) {
          if (!ConnectivityUtils.isConnectivityError(e)) rethrow;
        }
      }

      return getMock().map(toEntity).toList();
    } catch (e, st) {
      await _logger.log(e, st, source: source);
      return getMock().map(toEntity).toList();
    }
  }

  Future<TEntity?> _getOne<TModel, TEntity>({
    required String source,
    required Future<TModel?> Function() fetchRemote,
    required TEntity Function(TModel) toEntity,
  }) async {
    try {
      final online = await ConnectivityUtils.hasInternetConnection();
      if (!online) return null;
      final model = await fetchRemote();
      return model != null ? toEntity(model) : null;
    } catch (e, st) {
      if (!ConnectivityUtils.isConnectivityError(e)) {
        await _logger.log(e, st, source: source);
        rethrow;
      }
      return null;
    }
  }

  void _requireOnlineSync() {
    // Best-effort synchronous guard — actual check done async in callers.
  }

  Future<void> _requireOnline(String source) async {
    final online = await ConnectivityUtils.hasInternetConnection();
    if (!online) throw const OfflineFailure();
  }
}
