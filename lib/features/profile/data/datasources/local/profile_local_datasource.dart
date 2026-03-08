import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/profile/data/datasources/profile_datasource.dart';
import '../../../../../core/services/hive/hive_service.dart';
import '../../models/profile_hive_model.dart';

final profileLocalDatasourceProvider = Provider<IProfileLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return ProfileLocalDatasource(hiveService);
});

class ProfileLocalDatasource implements IProfileLocalDatasource {
  final HiveService _hiveService;

  ProfileLocalDatasource(this._hiveService);

  @override
  Future<ProfileHiveModel?> getUserById(String userId) async {
    return _hiveService.getUserById(userId);
  }

  @override
  Future<ProfileHiveModel?> updateProfile(ProfileHiveModel model) async {
    return _hiveService.updateProfile(model);
  }

  @override
  Future<String?> uploadProfileImage(String userId, String imagePath) async {
    return _hiveService.uploadProfileImage(userId, imagePath);
  }
}
