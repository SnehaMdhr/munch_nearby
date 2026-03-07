import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/token_service.dart';
import 'package:munch_nearby/features/profile/data/datasources/upload_image_datasource.dart';

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
  static const List<String> _uploadFieldCandidates = ['image'];

  UploadImageRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<String> uploadImage(File image) async {
    if (!await image.exists()) {
      throw Exception(
        'Selected image file does not exist. Please choose it again.',
      );
    }

    final fileName = image.uri.pathSegments.isNotEmpty
        ? image.uri.pathSegments.last
        : image.path.split(RegExp(r'[\\/]')).last;

    final token = _tokenService.getToken();
    final cleanedToken = token?.trim().replaceFirst(
      RegExp(r'^Bearer\s+', caseSensitive: false),
      '',
    );

    DioException? lastError;
    for (final fieldName in _uploadFieldCandidates) {
      try {
        final formData = FormData.fromMap({
          fieldName: await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          ),
        });

        final response = await _apiClient.put(
          ApiEndpoints.updateProfile,
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
        lastError = e;

        // If backend indicates missing file/path, it may be expecting a
        // different multipart key. Retry with the next candidate.
        final responseBody = e.response?.data?.toString() ?? '';
        final hasMoreCandidates = fieldName != _uploadFieldCandidates.last;
        final isLikelyFieldMismatch =
            responseBody.contains('ENOENT') || e.response?.statusCode == 400;

        if (hasMoreCandidates && isLikelyFieldMismatch) {
          continue;
        }

        rethrow;
      }
    }

    if (lastError != null) {
      final e = lastError;
      final responseBody = e.response?.data?.toString() ?? '';
      final apiMessage = _extractApiErrorMessage(e.response?.data);

      if (apiMessage != null && apiMessage.trim().isNotEmpty) {
        throw Exception(apiMessage.trim());
      }

      if (responseBody.contains('ENOENT')) {
        throw Exception('Image upload failed with ENOENT on backend.');
      }

      final statusCode = e.response?.statusCode;
      final compactBody = responseBody.length > 220
          ? '${responseBody.substring(0, 220)}...'
          : responseBody;
      throw Exception(
        'Failed to upload image${statusCode != null ? ' (HTTP $statusCode)' : ''}${compactBody.isNotEmpty ? ': $compactBody' : ''}.',
      );
    }

    throw Exception('Failed to upload image.');
  }

  String? _extractApiErrorMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedMessage = nestedData['message'];
      if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
        return nestedMessage;
      }
      final nestedError = nestedData['error'];
      if (nestedError is String && nestedError.trim().isNotEmpty) {
        return nestedError;
      }
    }

    return null;
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
