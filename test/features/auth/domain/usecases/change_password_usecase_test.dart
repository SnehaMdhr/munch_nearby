import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/change_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ChangePasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ChangePasswordUsecase(authRepository: mockRepository);
  });

  const tParams = ChangePasswordParams(
    oldPassword: 'oldPass123',
    newPassword: 'newPass456',
    confirmPassword: 'newPass456',
  );

  group('ChangePasswordUsecase', () {
    test('should return true on successful password change', () async {
      when(
        () => mockRepository.changePassword(
          oldPassword: tParams.oldPassword,
          newPassword: tParams.newPassword,
          confirmPassword: tParams.confirmPassword,
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(
        () => mockRepository.changePassword(
          oldPassword: tParams.oldPassword,
          newPassword: tParams.newPassword,
          confirmPassword: tParams.confirmPassword,
        ),
      ).called(1);
    });

    test('should return ApiFailure when password change fails', () async {
      const tFailure = ApiFailure(message: 'Old password is incorrect');
      when(
        () => mockRepository.changePassword(
          oldPassword: any(named: 'oldPassword'),
          newPassword: any(named: 'newPassword'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.changePassword(
          oldPassword: any(named: 'oldPassword'),
          newPassword: any(named: 'newPassword'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('ChangePasswordParams', () {
    test('should have correct props for equality', () {
      const params1 = ChangePasswordParams(
        oldPassword: 'old',
        newPassword: 'new',
        confirmPassword: 'new',
      );
      const params2 = ChangePasswordParams(
        oldPassword: 'old',
        newPassword: 'new',
        confirmPassword: 'new',
      );

      expect(params1, equals(params2));
    });

    test('should not be equal when fields differ', () {
      const params1 = ChangePasswordParams(
        oldPassword: 'old',
        newPassword: 'new',
        confirmPassword: 'new',
      );
      const params2 = ChangePasswordParams(
        oldPassword: 'different',
        newPassword: 'new',
        confirmPassword: 'new',
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
