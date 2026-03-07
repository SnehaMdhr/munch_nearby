import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/app/routes/app_routes.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:munch_nearby/features/auth/presentation/pages/login_screen.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_button.dart';
import 'package:munch_nearby/features/profile/presentation/state/upload_image_state.dart';
import 'package:munch_nearby/features/profile/presentation/view_model/upload_image_viewmodel.dart';
import 'package:munch_nearby/core/widgets/profile_item.dart';
import 'package:munch_nearby/features/profile/presentation/pages/change_password_screen.dart';
import 'package:munch_nearby/features/profile/presentation/pages/update_profile_screen.dart';
import 'package:munch_nearby/features/profile/presentation/state/profile_state.dart';
import 'package:munch_nearby/features/profile/presentation/view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<ProviderSubscription<dynamic>> _subscriptions = [];

  String? _resolveUserId() {
    final authUserId = ref.read(authViewModelProvider).authEntity?.userId;
    final sessionUserId = ref
        .read(userSessionServiceProvider)
        .getCurrentUserId();
    final userId = authUserId ?? sessionUserId;
    if (userId == null || userId.trim().isEmpty) {
      return null;
    }
    return userId;
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    await ref.read(authViewModelProvider.notifier).fetchCurrentUser();

    if (!mounted) return;
    final userId = _resolveUserId();
    if (userId != null) {
      await ref.read(profileViewModelProvider.notifier).fetchProfile(userId);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchProfileData);

    final authSubscription = ref.listenManual(authViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      final previousUserId = previous?.authEntity?.userId;
      final nextUserId = next.authEntity?.userId;
      if (nextUserId != null &&
          nextUserId.isNotEmpty &&
          previousUserId != nextUserId) {
        ref.read(profileViewModelProvider.notifier).fetchProfile(nextUserId);
      }
    });
    _subscriptions.add(authSubscription);

    final uploadSubscription = ref.listenManual(uploadImageViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next.status == UploadImageStatus.loaded) {
        ref.read(authViewModelProvider.notifier).fetchCurrentUser();
        final userId = _resolveUserId();
        if (userId != null) {
          ref.read(profileViewModelProvider.notifier).fetchProfile(userId);
        }
      }
      if (next.status == UploadImageStatus.error &&
          next.errorMessage != null &&
          next.errorMessage!.isNotEmpty) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
    _subscriptions.add(uploadSubscription);

    final profileSubscription = ref.listenManual(profileViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;

      if ((next.status == ProfileStatus.loaded ||
              next.status == ProfileStatus.updated) &&
          next.profile != null) {
        final session = ref.read(userSessionServiceProvider);

        session.saveUserSession(
          userId: next.profile!.userId,
          email: next.profile!.email ?? session.getCurrentUserEmail() ?? '',
          name: next.profile!.name ?? session.getCurrentUserName() ?? '',
          username: session.getCurrentUserUsername(),
          profilePicture: next.profile!.profilePicture,
        );
      }

      if (next.status == ProfileStatus.error &&
          next.errorMessage != null &&
          next.errorMessage!.isNotEmpty) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
    _subscriptions.add(profileSubscription);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final userSession = ref.watch(userSessionServiceProvider);
    final uploadState = ref.watch(uploadImageViewModelProvider);

    final profile = profileState.profile;

    // Get profile picture URL from auth entity or user session
    String? profilePictureUrl = _normalizeProfileImageUrl(
      profile?.profilePicture ??
          authState.authEntity?.imageUrl ??
          userSession.getCurrentUserProfilePicture(),
    );

    // If upload returns photo name, construct uploaded URL immediately
    if (uploadState.status == UploadImageStatus.loaded &&
        uploadState.uploadPhotoName != null &&
        uploadState.uploadPhotoName!.isNotEmpty) {
      profilePictureUrl = _normalizeProfileImageUrl(
        uploadState.uploadPhotoName,
      );
    }

    return SizedBox.expand(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 24),

              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFFFD6C9),
                    child: ClipOval(
                      child:
                          (profilePictureUrl != null &&
                              profilePictureUrl.isNotEmpty)
                          ? Image.network(
                              profilePictureUrl,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  'Profile image load failed: $profilePictureUrl -> $error',
                                );
                                return const Icon(Icons.person, size: 40);
                              },
                            )
                          : const Icon(Icons.person, size: 40),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Text(
                profile?.name ??
                    authState.authEntity?.name ??
                    userSession.getCurrentUserName() ??
                    "User",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.email ??
                    authState.authEntity?.email ??
                    userSession.getCurrentUserEmail() ??
                    "user@email.com",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ProfileItem(
                icon: Icons.edit,
                title: "Edit Profile",
                onTap: () =>
                    AppRoutes.push(context, const UpdateProfileScreen()),
              ),
              ProfileItem(
                icon: Icons.key_rounded,
                title: "Change Password",
                onTap: () =>
                    AppRoutes.push(context, const ChangePasswordScreen()),
              ),
              ProfileItem(
                icon: Icons.star_border,
                title: "My Reviews",
                onTap: () {},
              ),
              ProfileItem(
                icon: Icons.settings,
                title: "Settings",
                onTap: () {},
              ),
              const Spacer(),
              SizedBox(
                child: MyButton(
                  onPressed: () async {
                    await ref.read(authViewModelProvider.notifier).logout();
                    if (!mounted) return;
                    await ref.read(userSessionServiceProvider).clearSession();
                    if (context.mounted) {
                      AppRoutes.pushReplacement(context, const LoginScreen());
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                  text: 'Logout',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String? _normalizeProfileImageUrl(String? rawUrl) {
    if (rawUrl == null ||
        rawUrl.trim().isEmpty ||
        rawUrl.trim().toLowerCase() == 'null') {
      return null;
    }

    final value = rawUrl.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final baseUri = Uri.parse(ApiEndpoints.baseUrl);
    final origin = '${baseUri.scheme}://${baseUri.authority}';

    if (value.startsWith('/')) {
      return '$origin$value';
    }

    if (value.startsWith('uploads/')) {
      return '$origin/$value';
    }

    return '$origin/uploads/$value';
  }
}
