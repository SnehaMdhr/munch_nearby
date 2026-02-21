import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/hive_table_constant.dart';
import '../../domain/entities/favourite_entity.dart';

part 'favourite_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.favouriteTypeId)
class FavouriteHiveModel extends HiveObject {

  @HiveField(0)
  final String favouriteId;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String restaurantId;

  FavouriteHiveModel({
    String? favouriteId,
    required this.customerId,
    required this.restaurantId,
  }) : favouriteId = favouriteId ?? const Uuid().v4();

  factory FavouriteHiveModel.fromEntity(FavouriteEntity entity) {
    return FavouriteHiveModel(
      favouriteId: entity.favouriteId,
      customerId: entity.customerId,
      restaurantId: entity.restaurantId,
    );
  }

  FavouriteEntity toEntity() {
    return FavouriteEntity(
      favouriteId: favouriteId,
      customerId: customerId,
      restaurantId: restaurantId,
    );
  }

  static List<FavouriteEntity> toEntityList(
      List<FavouriteHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}