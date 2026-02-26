import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:munch_nearby/features/favourite/data/models/favourite_hive_model.dart';
import 'package:munch_nearby/features/menu/data/models/menu_hive_model.dart';
import 'package:munch_nearby/features/profile/data/models/profile_hive_model.dart';
import 'package:munch_nearby/features/review/data/models/review_hive_model.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';
import '../../../features/restaurant/data/models/restaurant_hive_model.dart';
import '../../constants/hive_table_constant.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";
    Hive.init(path);

    _registerAdapter();
    await openBoxes();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.restaurantTypeId)) {
      Hive.registerAdapter(RestaurantHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.menuTypeId)) {
      Hive.registerAdapter(MenuHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.favouriteTypeId)) {
      Hive.registerAdapter(FavouriteHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.reviewTypeId)) {
      Hive.registerAdapter(ReviewHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);

    await Hive.openBox<RestaurantHiveModel>(HiveTableConstant.restaurantTable);

    await Hive.openBox<MenuHiveModel>(HiveTableConstant.menuTable);

    await Hive.openBox<FavouriteHiveModel>(HiveTableConstant.favouriteTable);

    await Hive.openBox<ReviewHiveModel>(HiveTableConstant.reviewTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // USER BOX

  Box<AuthHiveModel> get _authBox {
    if (!Hive.isBoxOpen(HiveTableConstant.userTable)) {
      throw Exception('Hive box ${HiveTableConstant.userTable} is not open');
    }
    return Hive.box<AuthHiveModel>(HiveTableConstant.userTable);
  }

  // RESTAURANT BOX
  Box<RestaurantHiveModel> get _restaurantBox {
    if (!Hive.isBoxOpen(HiveTableConstant.restaurantTable)) {
      throw Exception(
        'Hive box ${HiveTableConstant.restaurantTable} is not open',
      );
    }
    return Hive.box<RestaurantHiveModel>(HiveTableConstant.restaurantTable);
  }

  //Menu box
  Box<MenuHiveModel> get _menuBox {
    if (!Hive.isBoxOpen(HiveTableConstant.menuTable)) {
      throw Exception('Hive box ${HiveTableConstant.menuTable} is not open');
    }
    return Hive.box<MenuHiveModel>(HiveTableConstant.menuTable);
  }

  Box<FavouriteHiveModel> get _favouriteBox {
    if (!Hive.isBoxOpen(HiveTableConstant.favouriteTable)) {
      throw Exception(
        'Hive box ${HiveTableConstant.favouriteTable} is not open',
      );
    }
    return Hive.box<FavouriteHiveModel>(HiveTableConstant.favouriteTable);
  }

  Box<ReviewHiveModel> get _reviewBox {
    if (!Hive.isBoxOpen(HiveTableConstant.reviewTable)) {
      throw Exception('Hive box ${HiveTableConstant.reviewTable} is not open');
    }
    return Hive.box<ReviewHiveModel>(HiveTableConstant.reviewTable);
  }

  // USER QUERIES
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );

    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  ProfileHiveModel _mapAuthToProfile(AuthHiveModel user) {
    return ProfileHiveModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      profilePicture: user.profilePicture,
    );
  }

  // PROFILE QUERIES (uses user_table)
  Future<ProfileHiveModel?> getUserById(String userId) async {
    final user = _authBox.get(userId);
    if (user == null) {
      return null;
    }
    return _mapAuthToProfile(user);
  }

  Future<ProfileHiveModel?> updateProfile(ProfileHiveModel profile) async {
    final existingUser = _authBox.get(profile.userId);
    if (existingUser == null) {
      return null;
    }

    final updatedUser = AuthHiveModel(
      userId: existingUser.userId,
      name: profile.name ?? existingUser.name,
      email: profile.email ?? existingUser.email,
      password: existingUser.password,
      username: existingUser.username,
      profilePicture: profile.profilePicture ?? existingUser.profilePicture,
    );

    await _authBox.put(updatedUser.userId, updatedUser);
    return _mapAuthToProfile(updatedUser);
  }

  Future<String?> uploadProfileImage(String userId, String imagePath) async {
    final existingUser = _authBox.get(userId);
    if (existingUser == null) {
      return null;
    }

    final updatedUser = AuthHiveModel(
      userId: existingUser.userId,
      name: existingUser.name,
      email: existingUser.email,
      password: existingUser.password,
      username: existingUser.username,
      profilePicture: imagePath,
    );

    await _authBox.put(updatedUser.userId, updatedUser);
    return updatedUser.profilePicture;
  }

  // RESTAURANT QUERIES
  Future<void> cacheRestaurants(List<RestaurantHiveModel> restaurants) async {
    await _restaurantBox.clear();

    for (var restaurant in restaurants) {
      await _restaurantBox.put(restaurant.id, restaurant);
    }
  }

  /// Get all restaurants
  List<RestaurantHiveModel> getRestaurants() {
    return _restaurantBox.values.toList();
  }

  /// Clear restaurants
  Future<void> clearRestaurants() async {
    await _restaurantBox.clear();
  }

  /// Get single restaurant by id
  RestaurantHiveModel? getRestaurantById(String id) {
    return _restaurantBox.get(id);
  }

  //Menu Queries

  Future<void> cacheMenus(List<MenuHiveModel> menus) async {
    for (var menu in menus) {
      await _menuBox.put(menu.id, menu);
    }
  }

  List<MenuHiveModel> getMenusByRestaurant(String restaurantId) {
    return _menuBox.values
        .where((menu) => menu.restaurantId == restaurantId)
        .toList();
  }

  Future<void> clearMenus() async {
    await _menuBox.clear();
  }

  // FAVOURITE QUERIES
  Future<void> addToFavourite(FavouriteHiveModel model) async {
    await _favouriteBox.put(model.favouriteId, model);
  }

  Future<void> removeFromFavourite(String restaurantId) async {
    final favourites = _favouriteBox.values
        .where((fav) => fav.restaurantId == restaurantId)
        .toList();

    for (var fav in favourites) {
      await fav.delete();
    }
  }

  List<FavouriteHiveModel> getFavouritesByUser(String customerId) {
    return _favouriteBox.values
        .where((fav) => fav.customerId == customerId)
        .toList();
  }

  bool isFavourite(String customerId, String restaurantId) {
    return _favouriteBox.values.any(
      (fav) => fav.customerId == customerId && fav.restaurantId == restaurantId,
    );
  }

  Future<void> clearFavourites() async {
    await _favouriteBox.clear();
  }

  // REVIEW QUERIES
  Future<void> saveReview(ReviewHiveModel model) async {
    await _reviewBox.put(model.reviewId, model);
  }

  List<ReviewHiveModel> getReviewsByRestaurant(String restaurantId) {
    return _reviewBox.values
        .where((review) => review.restaurantId == restaurantId)
        .toList();
  }

  List<ReviewHiveModel> getReviewsByCustomer(String customerId) {
    return _reviewBox.values
        .where((review) => review.customerId == customerId)
        .toList();
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewBox.delete(reviewId);
  }

  Future<void> cacheReviews(List<ReviewHiveModel> reviews) async {
    for (var review in reviews) {
      await _reviewBox.put(review.reviewId, review);
    }
  }

  Future<void> clearReviews() async {
    await _reviewBox.clear();
  }
}
