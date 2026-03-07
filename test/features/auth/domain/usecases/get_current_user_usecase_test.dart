import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/entities/auth_entity.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(authRepository: mockRepository);
  });

  const tAuthEntity = AuthEntity(
    userId: 'user-123',
    name: 'Test User',
    email: 'test@example.com',
  );

  group('GetCurrentUserUsecase', () {
    test('should return current user on success', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase();

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when fetching user fails', () async {
      const tFailure = ApiFailure(message: 'Unauthorized');
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });
  });
}
