import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, name, email, phone, profileImage];
}
