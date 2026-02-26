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
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
      );

      if (response.data["success"] == true) {
        final data = response.data;

        // Case 1: profilePicture at top level
        if (data["profilePicture"] != null) {
          return data["profilePicture"];
        }

        // Case 2: nested inside data
        if (data["data"] != null && data["data"]["profilePicture"] != null) {
          return data["data"]["profilePicture"];
        }
      }

      return null;
    } on DioException catch (e) {
      e.response?.data;
      return null;
    }
  }
}
