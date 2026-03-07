import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/auth/domain/repositories/auth_repository.dart';
import 'package:munch_nearby/features/auth/domain/usecases/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ResetPasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ResetPasswordUsecase(authRepository: mockRepository);
  });

  const tParams = ResetPasswordParams(
    otp: '123456',
    newPassword: 'newPass123',
    confirmPassword: 'newPass123',
    email: 'test@example.com',
  );

  group('ResetPasswordUsecase', () {
    test('should return true on successful password reset', () async {
      when(
        () => mockRepository.resetPassword(
          otp: tParams.otp,
          newPassword: tParams.newPassword,
          confirmPassword: tParams.confirmPassword,
          email: tParams.email!,
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(
        () => mockRepository.resetPassword(
          otp: tParams.otp,
          newPassword: tParams.newPassword,
          confirmPassword: tParams.confirmPassword,
          email: tParams.email!,
        ),
      ).called(1);
    });

    test('should return ApiFailure when reset fails', () async {
      const tFailure = ApiFailure(message: 'Invalid OTP');
      when(
        () => mockRepository.resetPassword(
          otp: any(named: 'otp'),
          newPassword: any(named: 'newPassword'),
          confirmPassword: any(named: 'confirmPassword'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.resetPassword(
          otp: any(named: 'otp'),
          newPassword: any(named: 'newPassword'),
          confirmPassword: any(named: 'confirmPassword'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  group('ResetPasswordParams', () {
    test('should have correct props for equality', () {
      const params1 = ResetPasswordParams(
        otp: '123456',
        newPassword: 'pass',
        confirmPassword: 'pass',
        email: 'test@example.com',
      );
      const params2 = ResetPasswordParams(
        otp: '123456',
        newPassword: 'pass',
        confirmPassword: 'pass',
        email: 'test@example.com',
      );

      expect(params1, equals(params2));
    });

    test('should not be equal when fields differ', () {
      const params1 = ResetPasswordParams(
        otp: '123456',
        newPassword: 'pass',
        confirmPassword: 'pass',
      );
      const params2 = ResetPasswordParams(
        otp: '654321',
        newPassword: 'pass',
        confirmPassword: 'pass',
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
