import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../models/event_model.dart';
import '../models/issue_model.dart';
import '../models/claim_model.dart';
import '../models/job_model.dart';
import '../models/check_in_model.dart';
import '../models/user_settings_model.dart';

/// Supabase data source — all queries return Models.
/// The SupabaseClient is injected by the host app; never hard-coded here.
class SupabaseDataSource {
  final SupabaseClient _client;

  const SupabaseDataSource(this._client);

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  Future<void> sendPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<UserModel> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final response = await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
    final uid = response.user?.id;
    if (uid == null) throw Exception('OTP verification returned no user');
    return _fetchUserById(uid);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<UserModel?> getCurrentUserModel() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    return _fetchUserById(uid);
  }

  Future<UserModel> _fetchUserById(String uid) async {
    final row =
        await _client.from('users').select().eq('id', uid).maybeSingle();
    if (row == null) throw Exception('User not found: $uid');
    return UserModel.fromJson(row);
  }

  Future<void> deleteAccount() async {
    await _client.rpc('delete_user_account');
  }

  /// DEBUG ONLY: Fetch user by ID from public.users without auth
  Future<UserModel?> getUserById(String userId) async {
    final row =
        await _client.from('users').select().eq('id', userId).maybeSingle();
    return row != null ? UserModel.fromJson(row) : null;
  }

  // ---------------------------------------------------------------------------
  // User Settings
  // ---------------------------------------------------------------------------

  Future<UserSettingsModel?> getUserSettings() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return row != null ? UserSettingsModel.fromJson(row) : null;
  }

  Future<UserSettingsModel> saveUserSettings(UserSettingsModel model) async {
    final data = await _client
        .from('user_settings')
        .upsert(model.toJson())
        .select()
        .single();
    return UserSettingsModel.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Places
  // ---------------------------------------------------------------------------

  Future<List<PlaceModel>> getPlaces({String? categoryId}) async {
    var query = _client.from('places').select().eq('active', true);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    final data = await query;
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(PlaceModel.fromJson)
        .toList();
  }

  Future<PlaceModel?> getPlace(String placeId) async {
    final row =
        await _client.from('places').select().eq('id', placeId).maybeSingle();
    return row != null ? PlaceModel.fromJson(row) : null;
  }

  Future<List<PlaceModel>> getFeaturedPlaces() async {
    final data = await _client
        .from('places')
        .select()
        .eq('active', true)
        .eq('is_featured', true);
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(PlaceModel.fromJson)
        .toList();
  }

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final q = query.trim();
    final data = await _client
        .from('places')
        .select()
        .eq('active', true)
        .or('name.ilike.%$q%,description.ilike.%$q%');
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(PlaceModel.fromJson)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  Future<List<EventModel>> getEvents({String? placeId}) async {
    var query = _client.from('events').select().eq('active', true);
    if (placeId != null) query = query.eq('place_id', placeId);
    final data = await query;
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(EventModel.fromJson)
        .toList();
  }

  Future<EventModel?> getEvent(String eventId) async {
    final row =
        await _client.from('events').select().eq('id', eventId).maybeSingle();
    return row != null ? EventModel.fromJson(row) : null;
  }

  // ---------------------------------------------------------------------------
  // Issues
  // ---------------------------------------------------------------------------

  Future<List<IssueModel>> getIssues() async {
    final data = await _client.from('issues').select().eq('active', true);
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(IssueModel.fromJson)
        .toList();
  }

  Future<IssueModel?> getIssue(String issueId) async {
    final row =
        await _client.from('issues').select().eq('id', issueId).maybeSingle();
    return row != null ? IssueModel.fromJson(row) : null;
  }

  Future<IssueModel> reportIssue({
    required String title,
    required String? description,
    required double latitude,
    required double longitude,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null)
      throw Exception('Must be authenticated to report an issue');
    final data = await _client
        .from('issues')
        .insert({
          'title': title,
          'description': description,
          'reporter_id': uid,
          'geometry_type': 'point',
          'latitude': latitude,
          'longitude': longitude,
          'confidence': 1,
          'active': true,
        })
        .select()
        .single();
    return IssueModel.fromJson(data);
  }

  Future<IssueModel> updateIssueStatus({
    required String issueId,
    required String status,
  }) async {
    final data = await _client
        .from('issues')
        .update({'status': status})
        .eq('id', issueId)
        .select()
        .single();
    return IssueModel.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Check-ins
  // ---------------------------------------------------------------------------

  Future<bool> hasCheckedInIssue(String issueId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await _client
        .from('check_ins')
        .select('id')
        .eq('issue_id', issueId)
        .eq('user_id', uid)
        .maybeSingle();
    return row != null;
  }

  Future<CheckInModel> checkInIssue(String issueId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Must be authenticated to check in');
    final data = await _client
        .from('check_ins')
        .upsert({'issue_id': issueId, 'user_id': uid})
        .select()
        .single();
    return CheckInModel.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------

  Future<List<JobModel>> getJobs({String? placeId}) async {
    var query = _client.from('jobs').select().eq('active', true);
    if (placeId != null) query = query.eq('place_id', placeId);
    final data = await query;
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList();
  }

  Future<JobModel?> getJob(String jobId) async {
    final row =
        await _client.from('jobs').select().eq('id', jobId).maybeSingle();
    return row != null ? JobModel.fromJson(row) : null;
  }

  // ---------------------------------------------------------------------------
  // Claims
  // ---------------------------------------------------------------------------

  Future<ClaimModel> submitClaim(String placeId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Must be authenticated to submit a claim');
    final data = await _client
        .from('place_claims')
        .insert(
            {'place_id': placeId, 'owner_user_id': uid, 'status': 'pending'})
        .select()
        .single();
    return ClaimModel.fromJson(data);
  }

  Future<ClaimModel> updateClaimStatus({
    required String claimId,
    required String status,
  }) async {
    final patch = <String, dynamic>{'status': status};
    if (status == 'approved')
      patch['approved_at'] = DateTime.now().toIso8601String();
    final data = await _client
        .from('place_claims')
        .update(patch)
        .eq('id', claimId)
        .select()
        .single();
    return ClaimModel.fromJson(data);
  }

  Future<List<ClaimModel>> getMyApprovedClaims() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await _client
        .from('place_claims')
        .select()
        .eq('owner_user_id', uid)
        .eq('status', 'approved');
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(ClaimModel.fromJson)
        .toList();
  }

  Future<List<ClaimModel>> getPendingClaims() async {
    final data =
        await _client.from('place_claims').select().eq('status', 'pending');
    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(ClaimModel.fromJson)
        .toList();
  }
}
