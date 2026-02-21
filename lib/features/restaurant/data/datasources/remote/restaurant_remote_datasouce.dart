import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/features/restaurant/data/datasources/restaurant_datasource.dart';
import 'package:munch_nearby/features/restaurant/data/models/restaurant_api_model.dart';

final restaurantRemoteDatasourceProvider =
    Provider<RestaurantRemoteDataSource>((ref) {
  return RestaurantRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
  );
});

class RestaurantRemoteDataSourceImpl
    implements RestaurantRemoteDataSource {

  final ApiClient _apiClient;

  RestaurantRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<List<RestaurantApiModel>> fetchRestaurants() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.restaurants,
      );

      final dynamic raw = response.data;
      final List<dynamic> data;

      if (raw is List) {
        data = raw;
      } else if (raw is Map<String, dynamic>) {
        final dynamic nested =
            raw['data'] ?? raw['restaurants'] ?? raw['result'];

        if (nested is List) {
          data = nested;
        } else {
          throw Exception('Invalid restaurants response format');
        }
      } else {
        throw Exception('Invalid restaurants response format');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => RestaurantApiModel.fromJson(json))
          .toList();

    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? message;

      if (responseData is Map<String, dynamic>) {
        final dynamic rawMessage = responseData['message'];

        if (rawMessage is String) {
          message = rawMessage;
        } else if (rawMessage is Map<String, dynamic>) {
          message =
              rawMessage['message']?.toString() ?? rawMessage.toString();
        } else if (rawMessage != null) {
          message = rawMessage.toString();
        }
      }

      throw Exception(
        message ?? "Failed to fetch restaurants",
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}