import 'package:equatable/equatable.dart';


class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  // final String role;
  final String? password;
  final String? confirmPassword;
  final String? username;
  final String? profilePicture;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    // required this.role,
    this.password,
    this.confirmPassword,
    this.username,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    // role,
    password,
    confirmPassword,
    username,
    profilePicture,
  ];
}
