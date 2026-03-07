import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: mockRepository);
  });

  group('LogoutUsecase', () {
    test('should return true on successful logout', () async {
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase();

      expect(result, const Right(true));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when logout fails', () async {
      const tFailure = ApiFailure(message: 'Logout failed');
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });

    test('should return LocalDatabaseFailure on local error', () async {
      const tFailure = LocalDatabaseFailure();
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });
  });
}
