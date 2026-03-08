import 'package:hive/hive.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/hive_table_constant.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? profilePicture;

  ProfileHiveModel({String? userId, this.name, this.email, this.profilePicture})
    : userId = userId ?? const Uuid().v4();

  /// Entity → Hive
  factory ProfileHiveModel.fromEntity(ProfileEntity entity) {
    return ProfileHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      profilePicture: entity.profilePicture,
    );
  }

  /// Hive → Entity
  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      name: name,
      email: email,
      profilePicture: profilePicture,
    );
  }

  static List<ProfileEntity> toEntityList(List<ProfileHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
