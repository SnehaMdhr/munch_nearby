import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import '../../models/menu_api_model.dart';
import '../menu_datasource.dart';

final menuRemoteDatasourceProvider =
    Provider<IMenuRemoteDatasource>((ref) {
  return MenuRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class MenuRemoteDatasource implements IMenuRemoteDatasource {

  final ApiClient _apiClient;

  MenuRemoteDatasource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<List<MenuApiModel>> getMenusByRestaurant(
      String restaurantId) async {

    final response = await _apiClient.get(
      "${ApiEndpoints.getMenuByRestaurantId}/$restaurantId",
    );

    if (response.data["success"] == true) {
      final List data = response.data["data"];

      return data
          .map((json) =>
              MenuApiModel.fromJson(json))
          .toList();
    }

    return [];
  }
}