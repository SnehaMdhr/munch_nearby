import 'package:munch_nearby/features/profile/data/models/profile_api_model.dart';
import 'package:munch_nearby/features/profile/data/models/profile_hive_model.dart';

abstract interface class IProfileLocalDatasource {
  Future<ProfileHiveModel?> getUserById(String userId);
  Future<ProfileHiveModel?> updateProfile(ProfileHiveModel model);
  Future<String?> uploadProfileImage(String userId, String imagePath);
}

abstract interface class IProfileRemoteDatasource {
  Future<ProfileApiModel?> getUserById(String userId);
  Future<ProfileApiModel?> updateProfile(
    String userId,
    Map<String, dynamic> data,
  );
  Future<String?> uploadProfileImage(String userId, String imagePath);
}
