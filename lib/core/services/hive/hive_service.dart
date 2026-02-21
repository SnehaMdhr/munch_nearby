import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
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
  }
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(
        HiveTableConstant.userTable);

    await Hive.openBox<RestaurantHiveModel>(
        HiveTableConstant.restaurantTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // =====================================================
  // USER BOX
  // =====================================================
  Box<AuthHiveModel> get _authBox {
    if (!Hive.isBoxOpen(HiveTableConstant.userTable)) {
      throw Exception(
          'Hive box ${HiveTableConstant.userTable} is not open');
    }
    return Hive.box<AuthHiveModel>(
        HiveTableConstant.userTable);
  }

  // =====================================================
  // RESTAURANT BOX
  // =====================================================
  Box<RestaurantHiveModel> get _restaurantBox {
    if (!Hive.isBoxOpen(HiveTableConstant.restaurantTable)) {
      throw Exception(
          'Hive box ${HiveTableConstant.restaurantTable} is not open');
    }
    return Hive.box<RestaurantHiveModel>(
        HiveTableConstant.restaurantTable);
  }

  // =====================================================
  // USER QUERIES
  // =====================================================
  Future<AuthHiveModel> registerUser(
      AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(
      String email,
      String password) async {

    final users = _authBox.values.where(
          (user) =>
      user.email == email &&
          user.password == password,
    );

    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  bool isEmailExists(String email) {
    final users =
    _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // =====================================================
  // RESTAURANT QUERIES
  // =====================================================

  /// Save all restaurants (replace old)
  Future<void> cacheRestaurants(
      List<RestaurantHiveModel> restaurants) async {

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
}