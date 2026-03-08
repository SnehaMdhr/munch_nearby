import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/profile/domain/entities/profile_entity.dart';
import 'package:munch_nearby/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:munch_nearby/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:munch_nearby/features/profile/presentation/state/profile_state.dart';
import 'package:munch_nearby/features/profile/presentation/view_model/profile_view_model.dart';

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

void main() {
  late MockGetProfileUsecase mockGetProfileUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late ProviderContainer container;

  setUp(() {
    mockGetProfileUsecase = MockGetProfileUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();

    container = ProviderContainer(
      overrides: [
        getProfileUsecaseProvider.overrideWithValue(mockGetProfileUsecase),
        updateProfileUsecaseProvider.overrideWithValue(
          mockUpdateProfileUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(const ProfileEntity(userId: ''));
  });

  ProfileState getState() => container.read(profileViewModelProvider);
  ProfileViewModel getNotifier() =>
      container.read(profileViewModelProvider.notifier);

  const tUserId = 'user-1';
  const tProfile = ProfileEntity(
    userId: tUserId,
    name: 'Test User',
    email: 'test@example.com',
    profilePicture: 'pic.jpg',
  );

  group('ProfileViewModel - fetchProfile', () {
    test('should emit loaded status with profile on success', () async {
      when(
        () => mockGetProfileUsecase(any()),
      ).thenAnswer((_) async => const Right(tProfile));

      await getNotifier().fetchProfile(tUserId);

      final state = getState();
      expect(state.status, ProfileStatus.loaded);
      expect(state.profile, tProfile);
    });
  });
}
