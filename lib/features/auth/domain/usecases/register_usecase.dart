import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {

  final String name;
  final String email;
  final UserRole role;
  final String? username;
  final String password;

  RegisterUsecaseParams({
    required this.name,
    required this.email,
    required this.role,
    required this.username,
    required this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [name,email,role,username,password];
}
final registerUsecaseProvider = Provider<RegisterUsecase>((ref){
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});
class RegisterUsecase implements UseCaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;
  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository =authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
        name: params.name,
        email: params.email,
        role: params.role,
        username: params.username,
        password: params.password);
    return _authRepository.register(entity);
  }
}