import '../../domain/entities/event_entity.dart';

class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? placeId;
  final String? organizerId;
  final String? startsAt;
  final String? endsAt;
  final double? latitude;
  final double? longitude;
  final bool active;
  final String? imageUrl;
  final String? createdAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    this.placeId,
    this.organizerId,
    this.startsAt,
    this.endsAt,
    this.latitude,
    this.longitude,
    required this.active,
    this.imageUrl,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        placeId: json['place_id'] as String?,
        organizerId: json['organizer_id'] as String?,
        startsAt: json['starts_at'] as String?,
        endsAt: json['ends_at'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        active: (json['active'] as bool?) ?? true,
        imageUrl: json['image_url'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'place_id': placeId,
        'organizer_id': organizerId,
        'starts_at': startsAt,
        'ends_at': endsAt,
        'latitude': latitude,
        'longitude': longitude,
        'active': active,
        'image_url': imageUrl,
        'created_at': createdAt,
      };

  EventEntity toEntity() => EventEntity(
        id: id,
        title: title,
        description: description,
        placeId: placeId,
        organizerId: organizerId,
        startsAt: startsAt != null ? DateTime.tryParse(startsAt!) : null,
        endsAt: endsAt != null ? DateTime.tryParse(endsAt!) : null,
        latitude: latitude,
        longitude: longitude,
        active: active,
        imageUrl: imageUrl,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
