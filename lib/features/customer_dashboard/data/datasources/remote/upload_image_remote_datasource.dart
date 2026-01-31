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

    final token = await _tokenService.getToken();
  
    final response = await _apiClient.put( 
      ApiEndpoints.uploadImage, 
      data: formData, 
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
    
    return response.data["success"];
  }
}