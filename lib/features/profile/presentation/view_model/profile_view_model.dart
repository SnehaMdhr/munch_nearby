import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/entities/profile_entity.dart';

import '../state/profile_state.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUsecase _getProfileUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;

  @override
  ProfileState build() {
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    return const ProfileState();
  }

  Future<void> fetchProfile(String userId) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _getProfileUsecase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (profileEntity) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profile: profileEntity,
        );
      },
    );
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);

    final updatedEntity = ProfileEntity(
      userId: userId,
      name: name,
      email: email,
      profilePicture: profilePicture,
    );

    final result = await _updateProfileUsecase(updatedEntity);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (profileEntity) {
        state = state.copyWith(
          status: ProfileStatus.updated,
          profile: profileEntity,
        );
      },
    );
  }
}
