import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/auth/data/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String otp;
  final String newPassword;
  final String confirmPassword;
  final String? email;
  const ResetPasswordParams({
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
    this.email,
  });

  @override
  List<Object?> get props => [otp, newPassword, confirmPassword, email];
}

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ResetPasswordUsecase(authRepository: authRepository);
});

class ResetPasswordUsecase
    implements UseCaseWithParams<bool, ResetPasswordParams> {
  final IAuthRepository _authRepository;
  ResetPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(
      otp: params.otp,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
      email: params.email as String,
    );
  }
}
