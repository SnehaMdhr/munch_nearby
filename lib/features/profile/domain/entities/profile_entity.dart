import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String? name;
  final String? email;
  final String? profilePicture;

  const ProfileEntity({
    required this.userId,
    this.name,
    this.email,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [userId, name, email, profilePicture];
}
