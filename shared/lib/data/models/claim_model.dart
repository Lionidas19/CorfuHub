import '../../domain/entities/claim_entity.dart';
import '../../enums.dart';

class ClaimModel {
  final String id;
  final String placeId;
  final String ownerUserId;
  final String status;
  final String createdAt;
  final String? approvedAt;

  const ClaimModel({
    required this.id,
    required this.placeId,
    required this.ownerUserId,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) => ClaimModel(
        id: json['id'] as String,
        placeId: (json['place_id'] as String?) ?? '',
        ownerUserId: (json['owner_user_id'] as String?) ?? '',
        status: (json['status'] as String?) ?? 'pending',
        createdAt: (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
        approvedAt: json['approved_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'place_id': placeId,
        'owner_user_id': ownerUserId,
        'status': status,
        'created_at': createdAt,
        'approved_at': approvedAt,
      };

  ClaimEntity toEntity() => ClaimEntity(
        id: id,
        placeId: placeId,
        ownerUserId: ownerUserId,
        status: ClaimStatus.fromString(status),
        createdAt: DateTime.parse(createdAt),
        approvedAt: approvedAt != null ? DateTime.tryParse(approvedAt!) : null,
      );
}
