import '../../domain/entities/user_settings_entity.dart';

class UserSettingsModel {
  final String userId;
  final double? homePinLat;
  final double? homePinLng;
  final double? homePinRadius;
  final List<String> savedPlaceIds;
  final bool notificationsEnabled;
  final bool severityOnlyMode;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const UserSettingsModel({
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

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) => UserSettingsModel(
        userId: json['user_id'] as String,
        homePinLat: (json['home_pin_lat'] as num?)?.toDouble(),
        homePinLng: (json['home_pin_lng'] as num?)?.toDouble(),
        homePinRadius: (json['home_pin_radius'] as num?)?.toDouble(),
        savedPlaceIds: (json['saved_place_ids'] as List<dynamic>?)
                ?.cast<String>() ??
            const [],
        notificationsEnabled: (json['notifications_enabled'] as bool?) ?? true,
        severityOnlyMode: (json['severity_only_mode'] as bool?) ?? false,
        quietHoursStart: json['quiet_hours_start'] as String?,
        quietHoursEnd: json['quiet_hours_end'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'home_pin_lat': homePinLat,
        'home_pin_lng': homePinLng,
        'home_pin_radius': homePinRadius,
        'saved_place_ids': savedPlaceIds,
        'notifications_enabled': notificationsEnabled,
        'severity_only_mode': severityOnlyMode,
        'quiet_hours_start': quietHoursStart,
        'quiet_hours_end': quietHoursEnd,
      };

  UserSettingsEntity toEntity() => UserSettingsEntity(
        userId: userId,
        homePinLat: homePinLat,
        homePinLng: homePinLng,
        homePinRadius: homePinRadius,
        savedPlaceIds: savedPlaceIds,
        notificationsEnabled: notificationsEnabled,
        severityOnlyMode: severityOnlyMode,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      );

  static UserSettingsModel fromEntity(UserSettingsEntity e) => UserSettingsModel(
        userId: e.userId,
        homePinLat: e.homePinLat,
        homePinLng: e.homePinLng,
        homePinRadius: e.homePinRadius,
        savedPlaceIds: e.savedPlaceIds,
        notificationsEnabled: e.notificationsEnabled,
        severityOnlyMode: e.severityOnlyMode,
        quietHoursStart: e.quietHoursStart,
        quietHoursEnd: e.quietHoursEnd,
      );
}
