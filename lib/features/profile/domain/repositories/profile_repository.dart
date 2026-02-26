import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getUserById(String userId);
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity entity);
  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    String imagePath,
  );
}
