import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/profile/data/repositories/profile_repository.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';
import 'package:munch_nearby/features/profile/domain/repositories/profile_repository.dart';

final getProfileUsecaseProvider = Provider<GetProfileUsecase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return GetProfileUsecase(repository);
});

class GetProfileUsecase implements UseCaseWithParams<ProfileEntity, String> {
  final IProfileRepository _repository;

  GetProfileUsecase(this._repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(String userId) {
    return _repository.getUserById(userId);
  }
}
