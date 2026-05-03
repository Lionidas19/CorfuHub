import '../../domain/entities/check_in_entity.dart';

class CheckInModel {
  final String id;
  final String issueId;
  final String userId;
  final String createdAt;
  final String? updatedAt;

  const CheckInModel({
    required this.id,
    required this.issueId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) => CheckInModel(
        id: json['id'] as String,
        issueId: (json['issue_id'] as String?) ?? '',
        userId: (json['user_id'] as String?) ?? '',
        createdAt: (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'issue_id': issueId,
        'user_id': userId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  CheckInEntity toEntity() => CheckInEntity(
        id: id,
        issueId: issueId,
        userId: userId,
        createdAt: DateTime.parse(createdAt),
        updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      );
}
