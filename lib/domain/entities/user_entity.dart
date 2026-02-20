import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String role;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.role,
    this.phone,
    required this.createdAt,
    this.lastLoginAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isClient => role == 'client';

  @override
  List<Object?> get props => [id, name, email, photoUrl, role, phone, createdAt, lastLoginAt];
}
