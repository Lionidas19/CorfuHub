import 'package:equatable/equatable.dart';
import '../../enums.dart';

class ClaimEntity extends Equatable {
  final String id;
  final String placeId;
  final String ownerUserId;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;

  const ClaimEntity({
    required this.id,
    required this.placeId,
    required this.ownerUserId,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  });

  @override
  List<Object?> get props => [id, placeId, ownerUserId, status];
}
