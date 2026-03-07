import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_button.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_text_form_field.dart';
import 'package:munch_nearby/features/profile/presentation/state/upload_image_state.dart';
import 'package:munch_nearby/features/profile/presentation/view_model/upload_image_viewmodel.dart';
import 'package:munch_nearby/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/profile_state.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedMedia = [];
  final List<ProviderSubscription<dynamic>> _subscriptions = [];

  late final TextEditingController nameController;
  late final TextEditingController emailController;

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

    final profile = ref.read(profileViewModelProvider).profile;
    nameController = TextEditingController(text: profile?.name ?? '');
    emailController = TextEditingController(text: profile?.email ?? '');

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

      if (next.profile != null && previous?.profile != next.profile) {
        nameController.text = next.profile?.name ?? '';
        emailController.text = next.profile?.email ?? '';
      }

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

      if (next.status == ProfileStatus.updated) {
        SnackbarUtils.showSuccess(context, 'Profile Updated!');
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
    _subscriptions.add(profileSubscription);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    super.dispose();
  }

  Future<bool> _askPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Yo feature haru use garna lai permission settings ma janu hola',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _askPermission(Permission.camera);
    if (!mounted || !hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (!mounted) return;
    if (photo != null) {
      setState(() {
        _selectedMedia
          ..clear()
          ..add(photo);
      });
      await ref
          .read(uploadImageViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (!mounted) return;
      if (image != null) {
        setState(() {
          _selectedMedia
            ..clear()
            ..add(image);
        });
        await ref
            .read(uploadImageViewModelProvider.notifier)
            .uploadPhoto(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Tapai ko gallery access garna payen, kripaya garera camera kholnus ani photo khichnus',
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Open Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Open Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final uploadState = ref.watch(uploadImageViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final userSession = ref.watch(userSessionServiceProvider);
    final notifier = ref.read(profileViewModelProvider.notifier);

    final String? normalizedProfilePicture = _normalizeProfileImageUrl(
      state.profile?.profilePicture ??
          authState.authEntity?.imageUrl ??
          userSession.getCurrentUserProfilePicture(),
    );

    final String? uploadedImageUrl =
        (uploadState.status == UploadImageStatus.loaded &&
            uploadState.uploadPhotoName != null &&
            uploadState.uploadPhotoName!.isNotEmpty)
        ? _normalizeProfileImageUrl(uploadState.uploadPhotoName)
        : null;

    final File? selectedLocalImage = _selectedMedia.isNotEmpty
        ? File(_selectedMedia.first.path)
        : null;

    final ImageProvider? avatarImage = selectedLocalImage != null
        ? FileImage(selectedLocalImage)
        : (uploadedImageUrl != null
              ? NetworkImage(uploadedImageUrl)
              : (normalizedProfilePicture != null
                    ? NetworkImage(normalizedProfilePicture)
                    : null));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (!mounted) return;
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Update Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: "PlusJakarta Bold"),
        ),
      ),
      body:
          state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.updating
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFFFD6C9),
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickMedia,
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFE87A5D),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    MyTextFormField(
                      controller: nameController,
                      label: 'Name',
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onChanged: (String value) {},
                    ),
                    const SizedBox(height: 10),
                    MyTextFormField(
                      controller: emailController,
                      label: 'Email',
                      readOnly: true,
                      onChanged: (String value) {},
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        text: "Update Profile",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final userId = state.profile?.userId;

                            if (userId == null || userId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User profile not loaded'),
                                ),
                              );
                              Navigator.pop(context);
                              return;
                            }

                            await notifier.updateProfile(
                              userId: userId,
                              name: nameController.text,
                              email: state.profile?.email,
                              profilePicture: state.profile?.profilePicture,
                            );
                          }
                        },
                      ),
                    ),
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
