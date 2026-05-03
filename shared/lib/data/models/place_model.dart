import '../../domain/entities/place_entity.dart';

class PlaceModel {
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
  final String? createdAt;

  const PlaceModel({
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

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        description: json['description'] as String?,
        categoryId: json['category_id'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        active: (json['active'] as bool?) ?? true,
        isFeatured: (json['is_featured'] as bool?) ?? false,
        imageUrl: json['image_url'] as String?,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
        website: json['website'] as String?,
        hours: json['hours'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category_id': categoryId,
        'latitude': latitude,
        'longitude': longitude,
        'active': active,
        'is_featured': isFeatured,
        'image_url': imageUrl,
        'address': address,
        'phone': phone,
        'website': website,
        'hours': hours,
        'created_at': createdAt,
      };

  PlaceEntity toEntity() => PlaceEntity(
        id: id,
        name: name,
        description: description,
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        active: active,
        isFeatured: isFeatured,
        imageUrl: imageUrl,
        address: address,
        phone: phone,
        website: website,
        hours: hours,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
