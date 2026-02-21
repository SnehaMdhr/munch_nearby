
import 'package:munch_nearby/features/restaurant/data/models/restaurant_api_model.dart';
import 'package:munch_nearby/features/restaurant/data/models/restaurant_hive_model.dart';

abstract class RestaurantLocalDataSource {
  Future<List<RestaurantHiveModel>> getRestaurants();
  Future<void> cacheRestaurants(List<RestaurantHiveModel> restaurants);
}


abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantApiModel>> fetchRestaurants();
}