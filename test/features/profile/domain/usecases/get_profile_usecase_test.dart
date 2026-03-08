import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';
import 'package:munch_nearby/features/profile/domain/repositories/profile_repository.dart';
import 'package:munch_nearby/features/profile/domain/usecases/get_profile_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late GetProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetProfileUsecase(mockRepository);
  });

  const tUserId = 'user-1';
  const tProfile = ProfileEntity(
    userId: tUserId,
    name: 'Test User',
    email: 'test@example.com',
    profilePicture: 'profile.jpg',
  );

  group('GetProfileUsecase', () {
    test('should return ProfileEntity on success', () async {
      when(
        () => mockRepository.getUserById(tUserId),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await usecase(tUserId);

      expect(result, const Right(tProfile));
      verify(() => mockRepository.getUserById(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
