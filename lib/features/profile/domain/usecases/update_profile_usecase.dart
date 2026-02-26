import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/profile/data/repositories/profile_repository.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';
import 'package:munch_nearby/features/profile/domain/repositories/profile_repository.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return UpdateProfileUsecase(repository);
});

class UpdateProfileUsecase
    implements UseCaseWithParams<ProfileEntity, ProfileEntity> {
  final IProfileRepository _repository;

  UpdateProfileUsecase(this._repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(ProfileEntity params) {
    return _repository.updateProfile(params);
  }
}
