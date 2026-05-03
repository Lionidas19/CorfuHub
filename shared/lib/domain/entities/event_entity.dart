import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? placeId;
  final String? organizerId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final double? latitude;
  final double? longitude;
  final bool active;
  final String? imageUrl;
  final DateTime? createdAt;

  const EventEntity({
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

  @override
  List<Object?> get props => [id, title, placeId, startsAt, endsAt, active];
}
