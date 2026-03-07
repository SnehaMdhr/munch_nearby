import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const AuthEntity(name: '', email: ''));
  });

  final tParams = RegisterUsecaseParams(
    name: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
    password: 'password123',
    confirmPassword: 'password123',
  );

  group('RegisterUsecase', () {
    test('should return true on successful registration', () async {
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
    });

    test(
      'should pass correct entity with params values to repository',
      () async {
        AuthEntity? capturedEntity;
        when(() => mockRepository.register(any())).thenAnswer((
          invocation,
        ) async {
          capturedEntity = invocation.positionalArguments[0] as AuthEntity;
          return const Right(true);
        });

        await usecase(tParams);

        expect(capturedEntity?.name, tParams.name);
        expect(capturedEntity?.email, tParams.email);
        expect(capturedEntity?.username, tParams.username);
        expect(capturedEntity?.password, tParams.password);
        expect(capturedEntity?.confirmPassword, tParams.confirmPassword);
      },
    );

    test('should return ApiFailure when registration fails', () async {
      const tFailure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('RegisterUsecaseParams', () {
    test('should have correct props for equality', () {
      final params1 = RegisterUsecaseParams(
        name: 'Test',
        email: 'test@example.com',
        username: 'testuser',
        password: 'pass',
        confirmPassword: 'pass',
      );
      final params2 = RegisterUsecaseParams(
        name: 'Test',
        email: 'test@example.com',
        username: 'testuser',
        password: 'pass',
        confirmPassword: 'pass',
      );

      expect(params1, equals(params2));
    });

    test('should not be equal when fields differ', () {
      final params1 = RegisterUsecaseParams(
        name: 'Test',
        email: 'test@example.com',
        username: 'testuser',
        password: 'pass',
        confirmPassword: 'pass',
      );
      final params2 = RegisterUsecaseParams(
        name: 'Other',
        email: 'test@example.com',
        username: 'testuser',
        password: 'pass',
        confirmPassword: 'pass',
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
