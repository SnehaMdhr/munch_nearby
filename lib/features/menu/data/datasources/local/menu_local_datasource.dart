import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/hive/hive_service.dart';
import '../../models/menu_hive_model.dart';
import '../menu_datasource.dart';

final menuLocalDatasourceProvider =
    Provider<IMenuLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return MenuLocalDatasource(hiveService);
});

class MenuLocalDatasource implements IMenuLocalDatasource {

  final HiveService _hiveService;

  MenuLocalDatasource(this._hiveService);

  @override
  Future<void> cacheMenus(
      List<MenuHiveModel> menus) async {

    try {
      await _hiveService.cacheMenus(menus);
    } catch (_) {}
  }

  @override
  Future<List<MenuHiveModel>> getMenusByRestaurant(
      String restaurantId) async {

    try {
      final menus =
          _hiveService.getMenusByRestaurant(restaurantId);
      return menus;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> clearMenus() async {
    try {
      await _hiveService.clearMenus();
    } catch (_) {}
  }
}