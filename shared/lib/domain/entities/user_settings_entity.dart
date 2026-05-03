import 'package:equatable/equatable.dart';

class UserSettingsEntity extends Equatable {
  final String userId;
  /// Home pin coordinates (private — never publicly exposed)
  final double? homePinLat;
  final double? homePinLng;
  final double? homePinRadius;
  /// Saved place IDs (private list)
  final List<String> savedPlaceIds;
  /// Notification settings
  final bool notificationsEnabled;
  final bool severityOnlyMode;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const UserSettingsEntity({
    required this.userId,
    this.homePinLat,
    this.homePinLng,
    this.homePinRadius,
    this.savedPlaceIds = const [],
    this.notificationsEnabled = true,
    this.severityOnlyMode = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  @override
  List<Object?> get props => [userId, homePinLat, homePinLng, notificationsEnabled];
}
