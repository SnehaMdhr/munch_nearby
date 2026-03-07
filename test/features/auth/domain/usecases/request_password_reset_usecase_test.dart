import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/request_password_reset_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RequestPasswordResetUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RequestPasswordResetUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tParams = RequestPasswordResetParams(tEmail);

  group('RequestPasswordResetUsecase', () {
    test('should return true on successful password reset request', () async {
      when(
        () => mockRepository.requestPasswordReset(tEmail),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.requestPasswordReset(tEmail)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when request fails', () async {
      const tFailure = ApiFailure(message: 'Email not found');
      when(
        () => mockRepository.requestPasswordReset(tEmail),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.requestPasswordReset(tEmail),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('RequestPasswordResetParams', () {
    test('should have correct props for equality', () {
      const params1 = RequestPasswordResetParams('test@example.com');
      const params2 = RequestPasswordResetParams('test@example.com');

      expect(params1, equals(params2));
    });

    test('should not be equal when email differs', () {
      const params1 = RequestPasswordResetParams('test@example.com');
      const params2 = RequestPasswordResetParams('other@example.com');

      expect(params1, isNot(equals(params2)));
    });
  });
}
