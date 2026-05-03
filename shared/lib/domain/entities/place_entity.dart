import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final bool active;
  final bool isFeatured;
  final String? imageUrl;
  final String? address;
  final String? phone;
  final String? website;
  final String? hours;
  final DateTime? createdAt;

  const PlaceEntity({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.latitude,
    this.longitude,
    required this.active,
    required this.isFeatured,
    this.imageUrl,
    this.address,
    this.phone,
    this.website,
    this.hours,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, categoryId, active, latitude, longitude];
}
