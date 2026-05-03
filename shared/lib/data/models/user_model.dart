import '../../domain/entities/user_entity.dart';
import '../../enums.dart';

class UserModel {
  final String id;
  final String role;
  final String? trustTier;
  final String? email;
  final String? phone;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.role,
    this.trustTier,
    this.email,
    this.phone,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        role: (json['role'] as String?) ?? 'resident',
        trustTier: json['trust_tier'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'trust_tier': trustTier,
        'email': email,
        'phone': phone,
        'created_at': createdAt,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        role: RoleEnum.fromString(role),
        trustTier: trustTier != null
            ? TrustTier.fromString(trustTier!)
            : TrustTier.newcomer,
        email: email,
        phone: phone,
        createdAt:
            createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      );
}
