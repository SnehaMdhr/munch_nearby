import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:munch_nearby/features/profile/data/datasources/profile_datasource.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../models/profile_api_model.dart';

final profileRemoteDatasourceProvider = Provider<IProfileRemoteDatasource>((
  ref,
) {
  return ProfileRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ProfileRemoteDatasource implements IProfileRemoteDatasource {
  final ApiClient _apiClient;
  static const String _uploadFieldName = 'image';

  ProfileRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ProfileApiModel?> getUserById(String userId) async {
    final response = await _apiClient.get("${ApiEndpoints.getCurrentUser}");

    if (response.data["success"] == true) {
      return ProfileApiModel.fromJson(response.data["data"]);
    }

    return null;
  }

  @override
  Future<ProfileApiModel?> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    Response response;
    try {
      response = await _apiClient.put(ApiEndpoints.updateProfile, data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      response = await _apiClient.put(
        "${ApiEndpoints.updateProfile}/$userId",
        data: data,
      );
    }

    if (response.data["success"] == true) {
      return ProfileApiModel.fromJson(response.data["data"]);
    }

    return null;
  }

  @override
  Future<String?> uploadProfileImage(String userId, String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return null;
      }

      final fileName = File(imagePath).uri.pathSegments.isNotEmpty
          ? File(imagePath).uri.pathSegments.last
          : imagePath.split(RegExp(r'[\\/]')).last;

      final formData = FormData.fromMap({
        _uploadFieldName: await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
      );

      if (response.data["success"] == true) {
        final data = response.data;

        if (data["profilePicture"] != null) {
          return data["profilePicture"];
        }

        if (data["data"] != null && data["data"]["profilePicture"] != null) {
          return data["data"]["profilePicture"];
        }
      }

      return null;
    } on DioException catch (e) {
      final responseBody = e.response?.data?.toString() ?? '';
      if (responseBody.contains('ENOENT')) {
        throw Exception(
          'Image upload failed on backend: uploads directory/file path is missing (ENOENT).',
        );
      }

      final statusCode = e.response?.statusCode;
      final compactBody = responseBody.length > 220
          ? '${responseBody.substring(0, 220)}...'
          : responseBody;
      throw Exception(
        'Failed to upload image${statusCode != null ? ' (HTTP $statusCode)' : ''}${compactBody.isNotEmpty ? ': $compactBody' : ''}.',
      );
    }
  }
}
