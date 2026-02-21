import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/features/favourite/data/datasources/favourite_datasource.dart';
import 'package:munch_nearby/features/favourite/data/models/favourite_api_model.dart';

final favouriteRemoteDatasourceProvider =
    Provider<IFavouriteRemoteDatasource>((ref) {
  return FavouriteRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class FavouriteRemoteDatasource implements IFavouriteRemoteDatasource {

  final ApiClient _apiClient;

  FavouriteRemoteDatasource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<List<FavouriteApiModel>> getFavourites() async {
    final response =
        await _apiClient.get(ApiEndpoints.getFavourites);

    if (response.data["success"] == true) {
      final List data = response.data["data"];
      return data
          .map((e) => FavouriteApiModel.fromJson(e))
          .toList();
    }

    return [];
  }

  @override
  Future<FavouriteApiModel> addToFavourite(
      FavouriteApiModel model) async {
    final response = await _apiClient.post(
      "${ApiEndpoints.addFavourites}/${model.restaurantId}", 
      // You can keep data: model.toJson() if your controller still needs the body
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      return FavouriteApiModel.fromJson(data);
    }
    throw Exception("Failed to add favourite");
  }

  @override
Future<void> removeFromFavourite(String restaurantId) async {
  try {
    // Just send the restaurantId directly as the URL parameter
    // matches router.delete("/:restaurantId")
    final response = await _apiClient.delete(
      "${ApiEndpoints.removeFavourites}/$restaurantId",
    );

    if (response.data["success"] != true) {
      throw Exception(response.data["message"] ?? "Failed to remove favourite");
    }
  } catch (e) {
    throw Exception("Error removing favourite: $e");
  }
}
}