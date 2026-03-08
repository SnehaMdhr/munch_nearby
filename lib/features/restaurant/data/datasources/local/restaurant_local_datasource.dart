import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/hive/hive_service.dart';
import '../../models/restaurant_hive_model.dart';
import '../restaurant_datasource.dart';

final restaurantLocalDatasourceProvider =
    Provider<RestaurantLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);

  return RestaurantLocalDataSourceImpl(
    hiveService: hiveService,
  );
});

class RestaurantLocalDataSourceImpl
    implements RestaurantLocalDataSource {
  final HiveService _hiveService;

  RestaurantLocalDataSourceImpl({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  @override
  Future<List<RestaurantHiveModel>> getRestaurants() async {
    try {
      final restaurants = await _hiveService.getRestaurants();
      return Future.value(restaurants);
    } catch (e) {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheRestaurants(
      List<RestaurantHiveModel> restaurants) async {
    try {
      await _hiveService.cacheRestaurants(restaurants);
    } catch (e) {
      rethrow;
    }
  }
}