import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/services/hive/hive_service.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref){
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthLocalDatasource{
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService =hiveService;

  @override
  Future<bool> isEmailExists(String email) {
    try{
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password)async {
    try{
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    }catch(e){
      return Future.value(null);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async{
    try{
      await _hiveService.registerUser(model);
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }

}