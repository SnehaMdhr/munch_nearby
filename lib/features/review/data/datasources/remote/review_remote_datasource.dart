import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/features/review/data/datasources/review_datasource.dart';
import 'package:munch_nearby/features/review/data/models/review_api_model.dart';

final reviewRemoteDatasourceProvider = Provider<IReviewRemoteDatasource>((ref) {
  return ReviewRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ReviewRemoteDatasource implements IReviewRemoteDatasource {
  final ApiClient _apiClient;

  ReviewRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Response<dynamic>> _postWithFallback({
    required List<String> paths,
    dynamic data,
  }) async {
    DioException? last404;

    for (final path in paths) {
      try {
        return await _apiClient.post(path, data: data);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          last404 = e;
          continue;
        }
        rethrow;
      }
    }

    throw last404 ?? Exception("POST endpoint not found");
  }

  Future<Response<dynamic>> _putWithFallback({
    required List<String> paths,
    dynamic data,
  }) async {
    DioException? last404;

    for (final path in paths) {
      try {
        return await _apiClient.put(path, data: data);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          last404 = e;
          continue;
        }
        rethrow;
      }
    }

    throw last404 ?? Exception("PUT endpoint not found");
  }

  Future<Response<dynamic>> _deleteWithFallback({
    required List<String> paths,
  }) async {
    DioException? last404;

    for (final path in paths) {
      try {
        return await _apiClient.delete(path);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          last404 = e;
          continue;
        }
        rethrow;
      }
    }

    throw last404 ?? Exception("DELETE endpoint not found");
  }

  @override
  Future<List<ReviewApiModel>> getRestaurantReviews(String restaurantId) async {
    final response = await _apiClient.get("${ApiEndpoints.getRestaurantReviews}/$restaurantId");
    if (response.data["success"] == true) {
      final List data = response.data["data"];
      return data.map((e) => ReviewApiModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<ReviewApiModel>> getMyReviews() async {
    final response = await _apiClient.get(ApiEndpoints.getOwnerReviews);
    if (response.data["success"] == true) {
      final List data = response.data["data"];
      return data.map((e) => ReviewApiModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<ReviewApiModel> createReview(ReviewApiModel model) async {
    final response = await _postWithFallback(
      paths: [
        ApiEndpoints.createReview,
        '/review',
        '/review/${model.restaurantId}',
        '/review/create/${model.restaurantId}',
      ],
      data: model.toJson(),
    );

    if (response.data["success"] == true) {
      return ReviewApiModel.fromJson(response.data["data"]);
    }
    throw Exception("Failed to create review");
  }

  @override
  Future<void> updateReview(String reviewId, ReviewApiModel model) async {
    final response = await _putWithFallback(
      paths: [
        "${ApiEndpoints.updateReview}/$reviewId",
        '/review/$reviewId',
        '/review/update/$reviewId',
      ],
      data: model.toJson(),
    );
    if (response.data["success"] != true) {
      throw Exception(response.data["message"] ?? "Failed to update review");
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final response = await _deleteWithFallback(
      paths: [
        "${ApiEndpoints.deleteReview}/$reviewId",
        '/review/$reviewId',
        '/review/delete/$reviewId',
      ],
    );
    if (response.data["success"] != true) {
      throw Exception(response.data["message"] ?? "Failed to delete review");
    }
  }
}