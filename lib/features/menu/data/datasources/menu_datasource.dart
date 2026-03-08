import '../models/menu_api_model.dart';
import '../models/menu_hive_model.dart';

abstract interface class IMenuRemoteDatasource {
  Future<List<MenuApiModel>> getMenusByRestaurant(String restaurantId);
}

abstract interface class IMenuLocalDatasource {
  Future<void> cacheMenus(List<MenuHiveModel> menus);
  Future<List<MenuHiveModel>> getMenusByRestaurant(String restaurantId);
  Future<void> clearMenus();
}