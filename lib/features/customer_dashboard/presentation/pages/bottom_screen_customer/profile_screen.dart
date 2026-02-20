import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/app/routes/app_routes.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:munch_nearby/features/auth/presentation/pages/login_screen.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/customer_dashboard/presentation/state/upload_image_state.dart';
import 'package:munch_nearby/features/customer_dashboard/presentation/view_model/upload_image_viewmodel.dart';
import 'package:munch_nearby/features/customer_dashboard/presentation/widgets/profile_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authViewModelProvider.notifier).fetchCurrentUser(),
    );
    ref.listenManual(uploadImageViewModelProvider, (previous, next) {
      if (!mounted) return;
      if (next.status == UploadImageStatus.loaded) {
        ref.read(authViewModelProvider.notifier).fetchCurrentUser();
      }
      if (next.status == UploadImageStatus.error &&
          next.errorMessage != null &&
          next.errorMessage!.isNotEmpty) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
  }

  Future<bool> _userSangaPermissionMagu(Permission permission) async {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text(
          "Yo feature haru use garna lai permission settings ma janu hola",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _userSangaPermissionMagu(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
      await ref.read(uploadImageViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
    }
  }

  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.addAll(images);
          });
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.add(image);
          });
          await ref.read(uploadImageViewModelProvider.notifier)
              .uploadPhoto(File(image.path));
        }
      }
    } catch (e) {
      debugPrint("Gallery Error $e");
      if (mounted) {
        SnackbarUtils.showError(
          context,
          "Tapai ko gallery access garna payen, kripaya garera camera kholnus ani photo khichnus",
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
                title: const Text("Open Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Open Gallery"),
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
    final authState = ref.watch(authViewModelProvider);
    final userSession = ref.watch(userSessionServiceProvider);
    final uploadState = ref.watch(uploadImageViewModelProvider);

    // Get profile picture URL from auth entity or user session
    String? profilePictureUrl = _normalizeProfileImageUrl(
      authState.authEntity?.profilePicture ??
          userSession.getCurrentUserProfilePicture(),
    );

    // If upload returns photo name, construct uploaded URL immediately
    if (uploadState.status == UploadImageStatus.loaded &&
        uploadState.uploadPhotoName != null &&
        uploadState.uploadPhotoName!.isNotEmpty) {
      profilePictureUrl = _normalizeProfileImageUrl(
        '/uploads/${uploadState.uploadPhotoName}',
      );
    }

    return SizedBox.expand(
      child: Container(
        color: const Color(0xFFFFF6F1),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFFFD6C9),
                      backgroundImage: (profilePictureUrl != null &&
                          profilePictureUrl.isNotEmpty)
                        ? NetworkImage(profilePictureUrl)
                        : null,
                      child: (profilePictureUrl == null ||
                          profilePictureUrl.isEmpty)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickMedia,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFE87A5D),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  authState.authEntity?.name ?? userSession.getCurrentUserName() ?? "User",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.authEntity?.email ?? userSession.getCurrentUserEmail() ?? "user@email.com",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                ProfileItem(icon: Icons.edit, title: "Edit Profile", onTap: () {}),
                ProfileItem(icon: Icons.star_border, title: "My Reviews", onTap: () {}),
                ProfileItem(icon: Icons.settings, title: "Settings", onTap: () {}),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).logout();
                      await ref.read(userSessionServiceProvider).clearSession();
                      if (context.mounted) {
                        AppRoutes.pushReplacement(context, const LoginScreen());
                      }
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text("Logout"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _normalizeProfileImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
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
