import 'package:equatable/equatable.dart';
import '../../enums.dart';

class UserEntity extends Equatable {
  final String id;
  final RoleEnum role;
  final String? email;
  final String? phone;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.role,
    this.email,
    this.phone,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, role, email, phone, createdAt];
}
