import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/auth/data/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

final changePasswordUsecaseProvider = Provider<ChangePasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ChangePasswordUsecase(authRepository: authRepository);
});

class ChangePasswordUsecase
    implements UseCaseWithParams<bool, ChangePasswordParams> {
  final IAuthRepository _authRepository;
  ChangePasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ChangePasswordParams params) {
    return _authRepository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
