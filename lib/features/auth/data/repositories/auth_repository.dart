import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/auth_hive_model.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref){
  return AuthRepository(authDatasource: ref.read(authLocalDatasourceProvider));
});
class AuthRepository implements IAuthRepository{

  final IAuthDatasource _authDatasource;
  AuthRepository({required IAuthDatasource authDatasource})
      :_authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final user = await _authDatasource.login(email, password);

      if (user != null) {
        return Right(user.toEntity());
      }

      return Left(
        LocalDatabaseFailure(message: "Invalid email or password"),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      return Left(
        LocalDatabaseFailure(message: msg),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async{
    try{
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if(result){
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Failed to register user"));
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}


