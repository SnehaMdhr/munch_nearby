import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/hive/hive_service.dart';
import '../../models/favourite_hive_model.dart';
import '../favourite_datasource.dart';

final favouriteLocalDatasourceProvider =
    Provider<FavouriteLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return FavouriteLocalDatasource(hiveService: hiveService);
});

class FavouriteLocalDatasource implements IFavouriteLocalDatasource {
  final HiveService _hiveService;

  FavouriteLocalDatasource({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  @override
  Future<void> addToFavourite(FavouriteHiveModel model) async {
    await _hiveService.addToFavourite(model);
  }

  @override
  Future<void> removeFromFavourite(String restaurantId) async {
    await _hiveService.removeFromFavourite(restaurantId);
  }

  @override
  Future<List<FavouriteHiveModel>> getFavouritesByUser(
      String customerId) async {
    return _hiveService.getFavouritesByUser(customerId);
  }

  @override
  Future<void> clearFavourites() async {
    await _hiveService.clearFavourites();
  }

  Future<bool> isFavourite(
      String customerId,
      String restaurantId,
  ) async {
    return _hiveService.isFavourite(customerId, restaurantId);
  }
}