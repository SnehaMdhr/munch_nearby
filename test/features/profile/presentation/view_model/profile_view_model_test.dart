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

  group('ProfileViewModel - initial state', () {
    test('should have initial state', () {
      final state = getState();

      expect(state.status, ProfileStatus.initial);
      expect(state.profile, isNull);
      expect(state.errorMessage, isNull);
    });
  });

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

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'User not found');
      when(
        () => mockGetProfileUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().fetchProfile(tUserId);

      final state = getState();
      expect(state.status, ProfileStatus.error);
      expect(state.errorMessage, 'User not found');
    });

    test('should emit error on network failure', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockGetProfileUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().fetchProfile(tUserId);

      final state = getState();
      expect(state.status, ProfileStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });
  });

  group('ProfileViewModel - updateProfile', () {
    const tUpdatedProfile = ProfileEntity(
      userId: tUserId,
      name: 'Updated Name',
      email: 'updated@example.com',
      profilePicture: 'new_pic.jpg',
    );

    test('should emit updated status with profile on success', () async {
      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));

      await getNotifier().updateProfile(
        userId: tUserId,
        name: 'Updated Name',
        email: 'updated@example.com',
        profilePicture: 'new_pic.jpg',
      );

      final state = getState();
      expect(state.status, ProfileStatus.updated);
      expect(state.profile, tUpdatedProfile);
    });

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'Update failed');
      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().updateProfile(userId: tUserId, name: 'Updated Name');

      final state = getState();
      expect(state.status, ProfileStatus.error);
      expect(state.errorMessage, 'Update failed');
    });

    test('should pass correct entity to usecase', () async {
      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));

      await getNotifier().updateProfile(
        userId: tUserId,
        name: 'Updated Name',
        email: 'updated@example.com',
        profilePicture: 'new_pic.jpg',
      );

      final captured =
          verify(() => mockUpdateProfileUsecase(captureAny())).captured.single
              as ProfileEntity;
      expect(captured.userId, tUserId);
      expect(captured.name, 'Updated Name');
      expect(captured.email, 'updated@example.com');
      expect(captured.profilePicture, 'new_pic.jpg');
    });
  });
}
