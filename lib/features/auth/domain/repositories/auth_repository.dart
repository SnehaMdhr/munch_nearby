import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, AuthEntity>> loginWithGoogle(String idToken);
  Future<Either<Failure, bool>> requestPasswordReset(String email);
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
  Future<Either<Failure, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
