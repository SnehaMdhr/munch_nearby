import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  restaurantOwner,
}

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final UserRole role;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    role,
    password,
    profilePicture,
  ];
}
