import 'package:munch_nearby/features/auth/data/models/auth_api_model.dart';

import '../models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
  Future<AuthHiveModel?> getCurrentUser();
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel?> register(AuthApiModel model);
  Future<AuthApiModel?> login(String email, String password);
  Future<bool> isEmailExists(String email);
  Future<AuthApiModel?> getCurrentUser();
  Future<AuthApiModel?> loginWithGoogle(String idToken);
  Future<bool> requestPasswordReset(String email);
  Future<bool> resetPassword({
    required String otp,
    required String newPassword,
    required String confirmPassword,
    String? email,
  });
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
