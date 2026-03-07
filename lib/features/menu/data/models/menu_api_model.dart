import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';

class MenuApiModel {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final bool isAvailable;
  final String restaurant;
  final String? imageUrl;

  MenuApiModel({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.restaurant,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "price": price,
      "category": category,
      "isAvailable": isAvailable,
      "restaurant": restaurant,
      "imageUrl": imageUrl,
    };
  }

  factory MenuApiModel.fromJson(Map<String, dynamic> json) {
    return MenuApiModel(
      id: json["id"] as String? ?? json["_id"] as String?,
      name: json["name"] as String? ?? "",
      description: json["description"] as String?,
      price: (json["price"] as num?)?.toDouble() ?? 0.0,
      category: json["category"] as String? ?? "",
      isAvailable: json["isAvailable"] as bool? ?? true,
      restaurant: json["restaurant"] as String? ?? "",
      imageUrl: json["imageUrl"] as String?,
    );
  }

  MenuEntity toEntity() {
    return MenuEntity(
      id: id ?? "",
      name: name,
      description: description,
      price: price,
      category: category,
      isAvailable: isAvailable,
      restaurantId: restaurant,
      imageUrl: imageUrl,
    );
  }

  factory MenuApiModel.fromEntity(MenuEntity entity) {
    return MenuApiModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      category: entity.category,
      isAvailable: entity.isAvailable,
      restaurant: entity.restaurantId,
      imageUrl: entity.imageUrl,
    );
  }

  static List<MenuEntity> toEntityList(List<MenuApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
