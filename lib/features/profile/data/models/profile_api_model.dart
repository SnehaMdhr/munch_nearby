import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String? id;
  final String? name;
  final String? email;
  final String? profilePicture;

  ProfileApiModel({this.id, this.name, this.email, this.profilePicture});

  Map<String, dynamic> toJson() {
    return {"name": name, "email": email, "profilePicture": profilePicture};
  }

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      id: json["id"] ?? json["_id"],
      name: json["name"],
      email: json["email"],
      profilePicture: json["profilePicture"]?.toString(),
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: id ?? "",
      name: name,
      email: email,
      profilePicture: profilePicture,
    );
  }

  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      id: entity.userId,
      name: entity.name,
      email: entity.email,
      profilePicture: entity.profilePicture,
    );
  }

  static List<ProfileEntity> toEntityList(List<ProfileApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
