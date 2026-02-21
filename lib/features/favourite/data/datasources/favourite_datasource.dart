import '../models/favourite_api_model.dart';
import '../models/favourite_hive_model.dart';

abstract interface class IFavouriteRemoteDatasource {
  Future<List<FavouriteApiModel>> getFavourites();
  Future<FavouriteApiModel> addToFavourite(FavouriteApiModel model);
  Future<void> removeFromFavourite(String favouriteId);
}

abstract interface class IFavouriteLocalDatasource {
  Future<void> addToFavourite(FavouriteHiveModel model);
  Future<void> removeFromFavourite(String restaurantId);
  Future<List<FavouriteHiveModel>> getFavouritesByUser(String customerId);
  Future<bool> isFavourite(String customerId, String restaurantId);
  Future<void> clearFavourites();
}