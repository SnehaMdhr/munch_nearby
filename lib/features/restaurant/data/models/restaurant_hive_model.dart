import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:munch_nearby/core/constants/hive_table_constant.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';

part 'restaurant_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.restaurantTypeId)
class RestaurantHiveModel extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String? mapLink;

  @HiveField(4)
  final String contactNumber;

  @HiveField(5)
  final String? category;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final String owner;

  RestaurantHiveModel({
    String? id,
    required this.name,
    required this.address,
    this.mapLink,
    required this.contactNumber,
    this.category,
    this.description,
    this.imageUrl,
    required this.owner,
  }) : id = id ?? const Uuid().v4();

  factory RestaurantHiveModel.fromEntity(RestaurantEntity entity) {
    return RestaurantHiveModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      mapLink: entity.mapLink,
      contactNumber: entity.contactNumber,
      category: entity.category,
      description: entity.description,
      imageUrl: entity.imageUrl,
      owner: entity.owner,
    );
  }
  RestaurantEntity toEntity() {
    return RestaurantEntity(
      id: id,
      name: name,
      address: address,
      mapLink: mapLink,
      contactNumber: contactNumber,
      category: category,
      description: description,
      imageUrl: imageUrl,
      owner: owner,
    );
  }
  static List<RestaurantEntity> toEntityList(
      List<RestaurantHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}