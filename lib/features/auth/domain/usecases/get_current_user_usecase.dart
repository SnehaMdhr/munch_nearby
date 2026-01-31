import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/auth/data/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

class GetCurrentUserUsecase implements UsecaseWithoutParams {
  final IAuthRepository _authRepository;
  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, dynamic>> call() {
    return _authRepository.getCurrentUser();
  }
}
