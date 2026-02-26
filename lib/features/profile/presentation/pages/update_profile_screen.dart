import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/profile/presentation/view_model/profile_view_model.dart';
import '../state/profile_state.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;

  File? selectedImage;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(profileViewModelProvider).profile;
    final authUserId = ref.read(authViewModelProvider).authEntity?.userId;
    final sessionUserId = ref
        .read(userSessionServiceProvider)
        .getCurrentUserId();
    final userId = authUserId ?? sessionUserId;

    nameController = TextEditingController(text: profile?.name ?? "");
    emailController = TextEditingController(text: profile?.email ?? "");

    if ((profile == null || profile.userId.isEmpty) &&
        userId != null &&
        userId.isNotEmpty) {
      Future.microtask(() {
        ref.read(profileViewModelProvider.notifier).fetchProfile(userId);
      });
    }
  }

  Future<void> pickImage() async {
    if (_isPickingImage) return;

    _isPickingImage = true;
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null && mounted) {
        setState(() {
          selectedImage = File(picked.path);
        });
      }
    } on PlatformException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image picker is already active")),
      );
    } finally {
      _isPickingImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final notifier = ref.read(profileViewModelProvider.notifier);
    final normalizedProfilePicture = _normalizeProfileImageUrl(
      state.profile?.profilePicture,
    );

    ref.listen(profileViewModelProvider, (previous, next) {
      if (next.profile != null && previous?.profile != next.profile) {
        nameController.text = next.profile?.name ?? "";
        emailController.text = next.profile?.email ?? "";
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.status == ProfileStatus.updated && next.profile != null) {
        final session = ref.read(userSessionServiceProvider);
        final currentUserId =
            session.getCurrentUserId() ?? next.profile!.userId;
        final username = session.getCurrentUserUsername();

        session.saveUserSession(
          userId: currentUserId,
          email: next.profile!.email ?? "",
          name: next.profile!.name ?? "",
          username: username,
          profilePicture: next.profile!.profilePicture,
        );

        ref.read(authViewModelProvider.notifier).fetchCurrentUser();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
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
                    // 🔥 Profile Image
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (normalizedProfilePicture != null
                                      ? NetworkImage(normalizedProfilePicture)
                                      : null)
                                  as ImageProvider?,
                        child:
                            selectedImage == null &&
                                normalizedProfilePicture == null
                            ? const Icon(Icons.camera_alt)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔥 Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),

                    // 🔥 Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 30),

                    // 🔥 Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final userId = state.profile?.userId;
                            if (userId == null || userId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("User profile not loaded"),
                                ),
                              );
                              return;
                            }

                            await notifier.updateProfile(
                              userId: userId,
                              name: nameController.text,
                              email: state.profile?.email,
                              profilePicture: selectedImage?.path,
                            );
                          }
                        },
                        child: const Text("Update Profile"),
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

    final value = rawUrl
        .trim()
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'\s+'), ' ');

    final looksLikeLocalFilePath =
        RegExp(r'^[A-Za-z]:/').hasMatch(value) || value.startsWith('file://');
    if (looksLikeLocalFilePath) {
      return null;
    }

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
