import '../entities/user_entity.dart';
import '../entities/place_entity.dart';
import '../entities/event_entity.dart';
import '../entities/issue_entity.dart';
import '../entities/claim_entity.dart';
import '../entities/job_entity.dart';
import '../entities/check_in_entity.dart';
import '../entities/user_settings_entity.dart';

/// Abstract contract for all CorfuHub data operations.
///
/// Implementations live in `data/repositories/app_repository_impl.dart`.
/// Datasource strategy (Supabase / cache / mock) is wired there.
abstract class AppRepository {
  // ---------------------------------------------------------------------------
  // Auth / User
  // ---------------------------------------------------------------------------

  /// Returns the currently logged-in user's public profile, or null if signed out.
  Future<UserEntity?> getCurrentUser();

  /// Requests phone OTP for sign-in / verification.
  Future<void> sendPhoneOtp(String phone);

  /// Verifies OTP and returns the authenticated user.
  Future<UserEntity> verifyPhoneOtp({required String phone, required String token});

  /// Signs out the current user.
  Future<void> signOut();

  /// Permanently deletes the current user's account (calls server-side RPC).
  Future<void> deleteAccount();

  // ---------------------------------------------------------------------------
  // User Settings (home pin, saved places, notification prefs)
  // ---------------------------------------------------------------------------

  Future<UserSettingsEntity?> getUserSettings();
  Future<UserSettingsEntity> saveUserSettings(UserSettingsEntity settings);

  // ---------------------------------------------------------------------------
  // Places (civic map)
  // ---------------------------------------------------------------------------

  /// All active places; optionally filtered by category.
  Future<List<PlaceEntity>> getPlaces({String? categoryId});

  /// Single place by ID.
  Future<PlaceEntity?> getPlace(String placeId);

  /// Featured places for the map hero section.
  Future<List<PlaceEntity>> getFeaturedPlaces();

  /// Search places by text query.
  Future<List<PlaceEntity>> searchPlaces(String query);

  /// Admin / owner use-case: fetch fresh from Supabase, bypass cache.
  Future<List<PlaceEntity>> getPlacesFresh();

  // ---------------------------------------------------------------------------
  // Events (civic map)
  // ---------------------------------------------------------------------------

  Future<List<EventEntity>> getEvents({String? placeId});
  Future<EventEntity?> getEvent(String eventId);
  Future<List<EventEntity>> getEventsFresh();

  // ---------------------------------------------------------------------------
  // Issues map
  // ---------------------------------------------------------------------------

  Future<List<IssueEntity>> getIssues();
  Future<IssueEntity?> getIssue(String issueId);

  /// Submit a new issue report (requires phone-verified auth).
  Future<IssueEntity> reportIssue({
    required String title,
    required String? description,
    required double latitude,
    required double longitude,
  });

  /// Update issue status (admin only — enforced by RLS).
  Future<IssueEntity> updateIssueStatus({
    required String issueId,
    required String status,
  });

  // ---------------------------------------------------------------------------
  // Check-ins (confidence tracking)
  // ---------------------------------------------------------------------------

  Future<bool> hasCheckedInIssue(String issueId);
  Future<CheckInEntity> checkInIssue(String issueId);

  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------

  Future<List<JobEntity>> getJobs({String? placeId});
  Future<JobEntity?> getJob(String jobId);

  // ---------------------------------------------------------------------------
  // Claims (owner workflow)
  // ---------------------------------------------------------------------------

  /// Submit a claim request for a place.
  Future<ClaimEntity> submitClaim(String placeId);

  /// Admin: approve or reject a pending claim.
  Future<ClaimEntity> updateClaimStatus({
    required String claimId,
    required String status, // 'approved' | 'rejected'
  });

  /// Claims for the current authenticated owner.
  Future<List<ClaimEntity>> getMyApprovedClaims();

  /// Admin: all pending claims.
  Future<List<ClaimEntity>> getPendingClaims();

  // ---------------------------------------------------------------------------
  // Offline sync
  // ---------------------------------------------------------------------------

  /// Flush queued offline mutations to Supabase.
  /// No-op if online queue is empty or user is not authenticated.
  Future<void> syncPendingActions();
}
