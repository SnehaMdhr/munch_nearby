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
    test('should pass correct email and password to repository', () async {
      when(
        () => mockRepository.login(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await usecase(tParams);

      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });
  });
}
