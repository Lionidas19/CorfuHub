import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String placeId;
  final String posterId;
  final bool active;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const JobEntity({
    required this.id,
    required this.title,
    this.description,
    required this.placeId,
    required this.posterId,
    required this.active,
    this.createdAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [id, title, placeId, active];
}
