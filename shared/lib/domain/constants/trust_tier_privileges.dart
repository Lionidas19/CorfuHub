import '../enums/trust_tier.dart';

/// Defines privileges and rate limits for each trust tier
class TrustTierPrivileges {
  final TrustTier tier;
  final int dailyIssueReports;
  final int dailyCheckIns;
  final int weeklyPlaceSubmissions;
  final int editWindowMinutes;
  final int maxSavedPlaces;
  final bool canSubmitEvents;
  final bool canSubmitPolygonIssues;
  final bool canSubmitPolylineIssues;
  final bool canFlagContent;
  final bool canSuggestMerges;
  final bool instantEventPosts;
  final double notificationRadiusKm;
  final String badgeEmoji;

  const TrustTierPrivileges({
    required this.tier,
    required this.dailyIssueReports,
    required this.dailyCheckIns,
    required this.weeklyPlaceSubmissions,
    required this.editWindowMinutes,
    required this.maxSavedPlaces,
    required this.canSubmitEvents,
    required this.canSubmitPolygonIssues,
    required this.canSubmitPolylineIssues,
    required this.canFlagContent,
    required this.canSuggestMerges,
    required this.instantEventPosts,
    required this.notificationRadiusKm,
    required this.badgeEmoji,
  });

  /// Get privileges for a specific tier
  static TrustTierPrivileges forTier(TrustTier tier) {
    return _tierPrivileges[tier]!;
  }

  /// Get next tier (null if already at max)
  TrustTier? get nextTier {
    final currentIndex = TrustTier.values.indexOf(tier);
    if (currentIndex >= TrustTier.values.length - 1) return null;
    return TrustTier.values[currentIndex + 1];
  }

  /// Get requirements to advance to next tier
  String? get advancementRequirements {
    switch (tier) {
      case TrustTier.newcomer:
        return '~10 quality interactions (reports, check-ins, approved submissions)';
      case TrustTier.contributor:
        return '~50 quality interactions + active for 2+ weeks';
      case TrustTier.regular:
        return '~200 quality interactions + no violations + 2+ months active';
      case TrustTier.trusted:
        return 'Top 5% of users + manual promotion consideration';
      case TrustTier.steward:
        return null; // Already at max
    }
  }

  static const Map<TrustTier, TrustTierPrivileges> _tierPrivileges = {
    TrustTier.newcomer: TrustTierPrivileges(
      tier: TrustTier.newcomer,
      dailyIssueReports: 3,
      dailyCheckIns: 5,
      weeklyPlaceSubmissions: 1,
      editWindowMinutes: 0,
      maxSavedPlaces: 5,
      canSubmitEvents: false,
      canSubmitPolygonIssues: false,
      canSubmitPolylineIssues: false,
      canFlagContent: false,
      canSuggestMerges: false,
      instantEventPosts: false,
      notificationRadiusKm: 2.0,
      badgeEmoji: '🔵',
    ),
    TrustTier.contributor: TrustTierPrivileges(
      tier: TrustTier.contributor,
      dailyIssueReports: 5,
      dailyCheckIns: 10,
      weeklyPlaceSubmissions: 2,
      editWindowMinutes: 10,
      maxSavedPlaces: 10,
      canSubmitEvents: true,
      canSubmitPolygonIssues: false,
      canSubmitPolylineIssues: false,
      canFlagContent: false,
      canSuggestMerges: false,
      instantEventPosts: false,
      notificationRadiusKm: 2.0,
      badgeEmoji: '🟢',
    ),
    TrustTier.regular: TrustTierPrivileges(
      tier: TrustTier.regular,
      dailyIssueReports: 10,
      dailyCheckIns: 20,
      weeklyPlaceSubmissions: 5,
      editWindowMinutes: 60,
      maxSavedPlaces: 25,
      canSubmitEvents: true,
      canSubmitPolygonIssues: false,
      canSubmitPolylineIssues: false,
      canFlagContent: false,
      canSuggestMerges: false,
      instantEventPosts: true,
      notificationRadiusKm: 3.0,
      badgeEmoji: '🟡',
    ),
    TrustTier.trusted: TrustTierPrivileges(
      tier: TrustTier.trusted,
      dailyIssueReports: 20,
      dailyCheckIns: 40,
      weeklyPlaceSubmissions: 10,
      editWindowMinutes: 1440, // 24 hours
      maxSavedPlaces: 999,
      canSubmitEvents: true,
      canSubmitPolygonIssues: true,
      canSubmitPolylineIssues: false,
      canFlagContent: true,
      canSuggestMerges: true,
      instantEventPosts: true,
      notificationRadiusKm: 5.0,
      badgeEmoji: '🟠',
    ),
    TrustTier.steward: TrustTierPrivileges(
      tier: TrustTier.steward,
      dailyIssueReports: 50,
      dailyCheckIns: 100,
      weeklyPlaceSubmissions: 20,
      editWindowMinutes: -1, // Unlimited
      maxSavedPlaces: 999,
      canSubmitEvents: true,
      canSubmitPolygonIssues: true,
      canSubmitPolylineIssues: true,
      canFlagContent: true,
      canSuggestMerges: true,
      instantEventPosts: true,
      notificationRadiusKm: 10.0,
      badgeEmoji: '🔴',
    ),
  };
}
