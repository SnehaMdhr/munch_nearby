import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
      () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState>{
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase= ref.read(loginUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String role,
    required String username,
    required String password,
    required String confirmPassword,
  })async{
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(Duration(seconds: 2));
    final params = RegisterUsecaseParams(
        name: name,
        email: email,
        role: role,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
    );
    final result = await _registerUsecase(params);
    result.fold(
          (failure){
        state= state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
          (isRegistered){
        if(isRegistered){
          state=state.copyWith(status: AuthStatus.registered);
        }
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  })async{
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(Duration(seconds: 2));
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);

    result.fold(
          (failure){
        state=state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
          (authEntity){
        state=state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

}