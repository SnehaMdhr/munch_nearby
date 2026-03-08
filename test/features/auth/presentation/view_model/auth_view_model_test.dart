import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';
import 'package:munch_nearby/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:munch_nearby/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:munch_nearby/features/auth/domain/usecases/login_usecase.dart';
import 'package:munch_nearby/features/auth/domain/usecases/logout_usecase.dart';
import 'package:munch_nearby/features/auth/domain/usecases/register_usecase.dart';
import 'package:munch_nearby/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:munch_nearby/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:munch_nearby/features/auth/presentation/state/auth_state.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/core/services/storage/token_service.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class MockChangePasswordUsecase extends Mock implements ChangePasswordUsecase {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockRequestPasswordResetUsecase mockRequestPasswordResetUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late MockChangePasswordUsecase mockChangePasswordUsecase;
  late MockTokenService mockTokenService;
  late ProviderContainer container;

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockRequestPasswordResetUsecase = MockRequestPasswordResetUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
    mockChangePasswordUsecase = MockChangePasswordUsecase();
    mockTokenService = MockTokenService();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        requestPasswordResetUsecaseProvider.overrideWithValue(
          mockRequestPasswordResetUsecase,
        ),
        resetPasswordUsecaseProvider.overrideWithValue(
          mockResetPasswordUsecase,
        ),
        changePasswordUsecaseProvider.overrideWithValue(
          mockChangePasswordUsecase,
        ),
        tokenServiceProvider.overrideWithValue(mockTokenService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(
      RegisterUsecaseParams(
        name: '',
        email: '',
        username: '',
        password: '',
        confirmPassword: '',
      ),
    );
    registerFallbackValue(const LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(
      const ChangePasswordParams(
        oldPassword: '',
        newPassword: '',
        confirmPassword: '',
      ),
    );
  });

  AuthState getState() => container.read(authViewModelProvider);
  AuthViewModel getNotifier() => container.read(authViewModelProvider.notifier);

  group('AuthViewModel - register', () {
    test('should emit registered status on successful registration', () async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await getNotifier().register(
        name: 'Test',
        email: 'test@example.com',
        username: 'testuser',
        password: 'pass123',
        confirmPassword: 'pass123',
      );

      final state = getState();
      expect(state.status, AuthStatus.registered);
    });

    test('should emit error status on registration failure', () async {
      const tFailure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().register(
        name: 'Test',
        email: 'test@example.com',
        username: 'testuser',
        password: 'pass123',
        confirmPassword: 'pass123',
      );

      final state = getState();
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email already exists');
    });
  });

  group('AuthViewModel - login', () {
    const tAuthEntity = AuthEntity(name: 'Test', email: 'test@example.com');

    test('should emit authenticated status on successful login', () async {
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await getNotifier().login(email: 'test@example.com', password: 'pass123');

      final state = getState();
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity, tAuthEntity);
    });
  });

  group('AuthViewModel - logout', () {
    test('should emit unauthenticated status on successful logout', () async {
      when(
        () => mockLogoutUsecase(),
      ).thenAnswer((_) async => const Right(true));

      await getNotifier().logout();

      final state = getState();
      expect(state.status, AuthStatus.unauthenticated);
    });
  });

  group('AuthViewModel - fetchCurrentUser', () {
    const tAuthEntity = AuthEntity(
      userId: 'user-1',
      name: 'Test',
      email: 'test@example.com',
    );

    test(
      'should emit authenticated status when token exists and user fetched',
      () async {
        when(() => mockTokenService.getToken()).thenReturn('valid-token');
        when(
          () => mockGetCurrentUserUsecase(),
        ).thenAnswer((_) async => const Right(tAuthEntity));

        await getNotifier().fetchCurrentUser();

        final state = getState();
        expect(state.status, AuthStatus.authenticated);
        expect(state.authEntity, tAuthEntity);
      },
    );

    test('should not call usecase when token is null', () async {
      when(() => mockTokenService.getToken()).thenReturn(null);

      await getNotifier().fetchCurrentUser();

      verifyNever(() => mockGetCurrentUserUsecase());
    });

    test('should not call usecase when token is empty', () async {
      when(() => mockTokenService.getToken()).thenReturn('   ');

      await getNotifier().fetchCurrentUser();

      verifyNever(() => mockGetCurrentUserUsecase());
    });
  });

  group('AuthViewModel - changePassword', () {
    test('should emit passwordChanged on success', () async {
      when(
        () => mockChangePasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await getNotifier().changePassword(
        oldPassword: 'old',
        newPassword: 'new',
        confirmPassword: 'new',
      );

      final state = getState();
      expect(state.status, AuthStatus.passwordChanged);
    });
  });
}
