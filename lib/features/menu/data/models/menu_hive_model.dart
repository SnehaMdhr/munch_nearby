import 'package:hive/hive.dart';
import '../../domain/entities/menu_entity.dart';

part 'menu_hive_model.g.dart';

@HiveType(typeId: 2)
class MenuHiveModel extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final bool isAvailable;

  @HiveField(6)
  final String restaurantId;

  MenuHiveModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.restaurantId,
  });

  /// Convert Hive → Entity
  MenuEntity toEntity() {
    return MenuEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      isAvailable: isAvailable,
      restaurantId: restaurantId,
    );
  }

  /// Convert Entity → Hive
  factory MenuHiveModel.fromEntity(MenuEntity entity) {
    return MenuHiveModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      category: entity.category,
      isAvailable: entity.isAvailable,
      restaurantId: entity.restaurantId,
    );
  }

  /// Convert List
  static List<MenuEntity> toEntityList(List<MenuHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}