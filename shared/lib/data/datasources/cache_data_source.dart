import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place_model.dart';
import '../models/event_model.dart';
import '../models/issue_model.dart';
import '../models/job_model.dart';
import '../models/user_settings_model.dart';
import '../models/user_model.dart';

/// Simple SharedPreferences-backed cache.
/// Stores serialised JSON lists/maps keyed by constant keys.
///
/// All get methods return null on a cache miss — caller decides fallback.
/// All set methods are best-effort and should never throw.
class CacheDataSource {
  static const _kCurrentUser = 'cache_current_user';
  static const _kUserSettings = 'cache_user_settings';
  static const _kPlaces = 'cache_places';
  static const _kFeaturedPlaces = 'cache_featured_places';
  static const _kEvents = 'cache_events';
  static const _kIssues = 'cache_issues';
  static const _kJobs = 'cache_jobs';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // User
  // ---------------------------------------------------------------------------
  Future<UserModel?> getCurrentUser() async {
    try {
      final raw = (await _prefs).getString(_kCurrentUser);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentUser(UserModel model) async {
    try {
      (await _prefs).setString(_kCurrentUser, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  Future<void> clearCurrentUser() async {
    try {
      (await _prefs).remove(_kCurrentUser);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // User Settings
  // ---------------------------------------------------------------------------
  Future<UserSettingsModel?> getUserSettings() async {
    try {
      final raw = (await _prefs).getString(_kUserSettings);
      if (raw == null) return null;
      return UserSettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserSettings(UserSettingsModel model) async {
    try {
      (await _prefs).setString(_kUserSettings, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Places
  // ---------------------------------------------------------------------------
  Future<List<PlaceModel>?> getPlaces() => _getList(_kPlaces, PlaceModel.fromJson);
  Future<void> savePlaces(List<PlaceModel> models) => _saveList(_kPlaces, models);

  Future<List<PlaceModel>?> getFeaturedPlaces() => _getList(_kFeaturedPlaces, PlaceModel.fromJson);
  Future<void> saveFeaturedPlaces(List<PlaceModel> models) => _saveList(_kFeaturedPlaces, models);

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------
  Future<List<EventModel>?> getEvents() => _getList(_kEvents, EventModel.fromJson);
  Future<void> saveEvents(List<EventModel> models) => _saveList(_kEvents, models);

  // ---------------------------------------------------------------------------
  // Issues
  // ---------------------------------------------------------------------------
  Future<List<IssueModel>?> getIssues() => _getList(_kIssues, IssueModel.fromJson);
  Future<void> saveIssues(List<IssueModel> models) => _saveList(_kIssues, models);

  // ---------------------------------------------------------------------------
  // Jobs
  // ---------------------------------------------------------------------------
  Future<List<JobModel>?> getJobs() => _getList(_kJobs, JobModel.fromJson);
  Future<void> saveJobs(List<JobModel> models) => _saveList(_kJobs, models);

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Future<List<T>?> _getList<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final raw = (await _prefs).getString(key);
      if (raw == null) return null;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveList<T extends Object>(String key, List<T> models) async {
    try {
      // All models expose toJson() via the pattern Map<String,dynamic> toJson()
      final encoded = jsonEncode(models.map((m) => (m as dynamic).toJson()).toList());
      (await _prefs).setString(key, encoded);
    } catch (_) {}
  }

  /// Clear all cached data (e.g. on sign-out).
  Future<void> clearAll() async {
    try {
      final prefs = await _prefs;
      for (final key in [
        _kCurrentUser,
        _kUserSettings,
        _kPlaces,
        _kFeaturedPlaces,
        _kEvents,
        _kIssues,
        _kJobs,
      ]) {
        prefs.remove(key);
      }
    } catch (_) {}
  }
}
