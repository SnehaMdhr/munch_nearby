import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository{
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Future,AuthEntity>> login(String email, String password);
}