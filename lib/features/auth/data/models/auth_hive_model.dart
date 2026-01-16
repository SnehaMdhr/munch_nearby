import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/hive_table_constant.dart';
import '../../domain/entities/auth_entity.dart';
part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  // @HiveField(3)
  // final String role;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? username;

  @HiveField(5)
  final String? profilePicture;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    // required this.role,
    this.password,
    this.username,
    this.profilePicture,
  }) : userId = userId ?? const Uuid().v4();

  /// Entity → Hive
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      // role: entity.role,
      password: entity.password,
      username: entity.username,
      profilePicture: entity.profilePicture,
    );
  }

  /// Hive → Entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      // role: role,
      password: password,
      username: username,
      profilePicture: profilePicture,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
