import '../../domain/entities/issue_entity.dart';
import '../../enums.dart';

class IssueModel {
  final String id;
  final String title;
  final String? description;
  final String reporterId;
  final String geometryType;
  final String? geometry;
  final double? latitude;
  final double? longitude;
  final int confidence;
  final bool active;
  final String? status;
  final String? createdAt;

  const IssueModel({
    required this.id,
    required this.title,
    this.description,
    required this.reporterId,
    required this.geometryType,
    this.geometry,
    this.latitude,
    this.longitude,
    required this.confidence,
    required this.active,
    this.status,
    this.createdAt,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) => IssueModel(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        reporterId: (json['reporter_id'] as String?) ?? '',
        geometryType: (json['geometry_type'] as String?) ?? 'point',
        geometry: json['geometry'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        confidence: (json['confidence'] as int?) ?? 0,
        active: (json['active'] as bool?) ?? true,
        status: json['status'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'reporter_id': reporterId,
        'geometry_type': geometryType,
        'geometry': geometry,
        'latitude': latitude,
        'longitude': longitude,
        'confidence': confidence,
        'active': active,
        'status': status,
        'created_at': createdAt,
      };

  IssueEntity toEntity() => IssueEntity(
        id: id,
        title: title,
        description: description,
        reporterId: reporterId,
        geometryType: _parseGeometryType(geometryType),
        geometry: geometry,
        latitude: latitude,
        longitude: longitude,
        confidence: confidence,
        active: active,
        status: status,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  static GeometryType _parseGeometryType(String raw) {
    switch (raw.toLowerCase()) {
      case 'polygon':
        return GeometryType.polygon;
      case 'polyline':
        return GeometryType.polyline;
      default:
        return GeometryType.point;
    }
  }
}
