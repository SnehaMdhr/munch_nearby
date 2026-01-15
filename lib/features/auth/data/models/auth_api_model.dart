import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String name;
  final String email;
  final String role;
  final String? username;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.username,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });


  //toJson
  Map<String, dynamic> toJson(){
    return{
      "name": name,
      "email":email,
      "role": role,
      "username": username,
      "password": password,
      "confirmPassword": confirmPassword,
      "profilePicture":profilePicture,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json["_id"] as String?,
      name: json["name"] as String? ?? "",
      email: json["email"] as String? ?? "",
      role: json["role"] as String? ?? "Customer",
      username: json["username"] as String?,
      profilePicture: json["profilePicture"] as String?,
    );
  }

  //toEntity
  AuthEntity toEntity(){
    return AuthEntity(
      userId: id,
      name: name,
      email: email,
      role: role,
      username: username,
      profilePicture: profilePicture,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity){
    return AuthApiModel(
      name: entity.name,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      profilePicture: entity.profilePicture,
      role: entity.role,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models){
    return models.map((model) => model.toEntity()).toList();
  }

}