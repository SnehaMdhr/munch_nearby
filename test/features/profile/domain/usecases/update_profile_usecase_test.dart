import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';
import 'package:munch_nearby/features/profile/domain/repositories/profile_repository.dart';
import 'package:munch_nearby/features/profile/domain/usecases/update_profile_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late UpdateProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdateProfileUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const ProfileEntity(userId: ''));
  });

  const tProfile = ProfileEntity(
    userId: 'user-1',
    name: 'Updated Name',
    email: 'updated@example.com',
  );

  const tUpdatedProfile = ProfileEntity(
    userId: 'user-1',
    name: 'Updated Name',
    email: 'updated@example.com',
    profilePicture: 'pic.jpg',
  );

  group('UpdateProfileUsecase', () {
    test('should return updated ProfileEntity on success', () async {
      when(
        () => mockRepository.updateProfile(any()),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));

      final result = await usecase(tProfile);

      expect(result, const Right(tUpdatedProfile));
      verify(() => mockRepository.updateProfile(tProfile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
