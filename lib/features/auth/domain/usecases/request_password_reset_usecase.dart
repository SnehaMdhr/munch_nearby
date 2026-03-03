import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/auth/data/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetParams extends Equatable {
  final String email;
  const RequestPasswordResetParams(this.email);

  @override
  List<Object?> get props => [email];
}

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return RequestPasswordResetUsecase(authRepository: authRepository);
    });

class RequestPasswordResetUsecase
    implements UseCaseWithParams<bool, RequestPasswordResetParams> {
  final IAuthRepository _authRepository;
  RequestPasswordResetUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RequestPasswordResetParams params) {
    return _authRepository.requestPasswordReset(params.email);
  }
}
