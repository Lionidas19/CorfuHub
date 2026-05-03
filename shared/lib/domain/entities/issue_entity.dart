import 'package:equatable/equatable.dart';
import '../../enums.dart';

class IssueEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String reporterId;
  final GeometryType geometryType;
  /// GeoJSON string for point/polygon/polyline
  final String? geometry;
  final double? latitude;
  final double? longitude;
  /// Confidence score (0–100) derived from check-in count
  final int confidence;
  final bool active;
  final String? status;
  final DateTime? createdAt;

  const IssueEntity({
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

  @override
  List<Object?> get props => [id, title, reporterId, geometryType, active];
}
