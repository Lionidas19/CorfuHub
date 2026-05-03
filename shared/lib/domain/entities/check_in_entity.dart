import 'package:equatable/equatable.dart';

class CheckInEntity extends Equatable {
  final String id;
  final String issueId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CheckInEntity({
    required this.id,
    required this.issueId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, issueId, userId];
}
