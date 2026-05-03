import '../../domain/entities/job_entity.dart';

class JobModel {
  final String id;
  final String title;
  final String? description;
  final String placeId;
  final String posterId;
  final bool active;
  final String? createdAt;
  final String? expiresAt;

  const JobModel({
    required this.id,
    required this.title,
    this.description,
    required this.placeId,
    required this.posterId,
    required this.active,
    this.createdAt,
    this.expiresAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        placeId: (json['place_id'] as String?) ?? '',
        posterId: (json['poster_id'] as String?) ?? '',
        active: (json['active'] as bool?) ?? true,
        createdAt: json['created_at'] as String?,
        expiresAt: json['expires_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'place_id': placeId,
        'poster_id': posterId,
        'active': active,
        'created_at': createdAt,
        'expires_at': expiresAt,
      };

  JobEntity toEntity() => JobEntity(
        id: id,
        title: title,
        description: description,
        placeId: placeId,
        posterId: posterId,
        active: active,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
        expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
      );
}
