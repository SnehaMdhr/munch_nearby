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
    registerFallbackValue(
      const AuthEntity(
        username: 'testuser',
        email: 'test@gmail.com',
        password: 'password123',
        name: 'Test User',
      ),
    );
  });

  const tFirstName = 'Test';
  const tLastName = 'Test';
  const tEmail = 'test@example.com';
  const tUsername = 'testuser';
  const tPassword = 'password123';
  const tPhoneNumber = '1234567890';
  const tConfirmPassword = 'password123';
  const tName = '$tFirstName $tLastName';

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      //arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      //act
      final result = await usecase(
        RegisterUsecaseParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          name: tFirstName + ' ' + tLastName,
        ),
      );

      //assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass AuthEntity with correct values to repository', () async {
      // Arrange
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(
        RegisterUsecaseParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          name: '$tFirstName $tLastName',
        ),
      );

      // Assert
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.username, tUsername);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.confirmPassword, tConfirmPassword);
      expect(capturedEntity?.name, '$tFirstName $tLastName');
    });

    test('should return failure when registration fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        RegisterUsecaseParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          name: '$tFirstName $tLastName',
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure();
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        RegisterUsecaseParams(
          email: tEmail,
          username: tUsername,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          name: tName,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });
  });

  group('RegisterParams', () {
    test('should have correct props with all values', () {
      // Arrange
      final params = RegisterUsecaseParams(
        name: tName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      );
      // Assert
      expect(params.props, [
        tName,
        tEmail,
        tUsername,
        tPassword,
        tConfirmPassword,
      ]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      final params1 = RegisterUsecaseParams(
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        name: tName,
      );
      final params2 = RegisterUsecaseParams(
        email: tEmail,
        username: tUsername,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        name: tName,
      );
      // Assert
      expect(params1, params2);
    });
  });
}
