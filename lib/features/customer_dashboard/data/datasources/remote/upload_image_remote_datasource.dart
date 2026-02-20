import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/token_service.dart';
import 'package:munch_nearby/features/customer_dashboard/data/datasources/upload_image_datasource.dart';

final uploadImageRemoteDatasourceProvider =
    Provider<IUploadImageRemoteDatasource>((ref) {
  return UploadImageRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class UploadImageRemoteDatasource implements IUploadImageRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  UploadImageRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  @override
  Future<String> uploadImage(File image) async {
    final fileName = image.path.split("/").last;
    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final token = _tokenService.getToken();
    final cleanedToken = token
        ?.trim()
        .replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');

    try {
      final response = await _apiClient.put(
        ApiEndpoints.uploadImage,
        data: formData,
        options: Options(
          headers: {
            if (cleanedToken != null && cleanedToken.isNotEmpty)
              "Authorization": "Bearer $cleanedToken",
          },
        ),
      );

      final photoName = _extractUploadedPhotoName(response.data);
      if (photoName != null && photoName.isNotEmpty) {
        return photoName;
      }

      if (_isSuccessResponse(response.data)) {
        return '';
      }

      throw Exception('Failed to upload image.');
    } on DioException catch (e) {
      final responseBody = e.response?.data?.toString() ?? '';

      if (responseBody.contains('ENOENT')) {
        throw Exception(
          'Upload folder is missing on backend. Please create the backend uploads directory.',
        );
      }

      final apiMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] as String?)
          : null;

      throw Exception(apiMessage ?? 'Failed to upload image.');
    }
  }

  String? _extractUploadedPhotoName(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final rawSuccess = data['success'];
    if (rawSuccess is String && rawSuccess.isNotEmpty) {
      return rawSuccess;
    }

    final topLevelProfilePicture = data['profilePicture'];
    if (topLevelProfilePicture is String && topLevelProfilePicture.isNotEmpty) {
      return topLevelProfilePicture.split('/').last;
    }

    final topLevelFileName = data['fileName'];
    if (topLevelFileName is String && topLevelFileName.isNotEmpty) {
      return topLevelFileName;
    }

    final topLevelImage = data['image'];
    if (topLevelImage is String && topLevelImage.isNotEmpty) {
      return topLevelImage.split('/').last;
    }

    final bodyData = data['data'];
    if (bodyData is Map<String, dynamic>) {
      final profilePicture = bodyData['profilePicture'];
      if (profilePicture is String && profilePicture.isNotEmpty) {
        return profilePicture.split('/').last;
      }

      final fileName = bodyData['fileName'];
      if (fileName is String && fileName.isNotEmpty) {
        return fileName;
      }

      final image = bodyData['image'];
      if (image is String && image.isNotEmpty) {
        return image.split('/').last;
      }

      final user = bodyData['user'];
      if (user is Map<String, dynamic>) {
        final userProfilePicture = user['profilePicture'];
        if (userProfilePicture is String && userProfilePicture.isNotEmpty) {
          return userProfilePicture.split('/').last;
        }
      }
    }

    return null;
  }

  bool _isSuccessResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    final success = data['success'];
    if (success is bool) return success;
    if (success is String) return success.toLowerCase() == 'true';
    return false;
  }
}