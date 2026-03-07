import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tParams = LoginUsecaseParams(email: tEmail, password: tPassword);
  const tAuthEntity = AuthEntity(name: 'Test User', email: tEmail);

  group('LoginUsecase', () {
    test('should return AuthEntity on successful login', () async {
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase(tParams);

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when login fails', () async {
      const tFailure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should pass correct email and password to repository', () async {
      when(
        () => mockRepository.login(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await usecase(tParams);

      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });
  });

  group('LoginUsecaseParams', () {
    test('should have correct props for equality', () {
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(email: tEmail, password: tPassword);

      expect(params1, equals(params2));
    });

    test('should not be equal when email differs', () {
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(
        email: 'other@example.com',
        password: tPassword,
      );

      expect(params1, isNot(equals(params2)));
    });

    test('should not be equal when password differs', () {
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(email: tEmail, password: 'different');

      expect(params1, isNot(equals(params2)));
    });
  });
}
