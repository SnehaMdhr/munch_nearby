import '../../domain/entities/favourite_entity.dart';

class FavouriteApiModel {
  final String? favouriteId;
  final String customerId;
  final String restaurantId;

  FavouriteApiModel({
    this.favouriteId,
    required this.customerId,
    required this.restaurantId,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer": customerId,
      "restaurant": restaurantId,
    };
  }

  static String _extractId(dynamic value) {
    if (value is String) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      final nestedId = value['_id'] ?? value['id'];
      if (nestedId is String) {
        return nestedId;
      }
    }

    return '';
  }

  factory FavouriteApiModel.fromJson(Map<String, dynamic> json) {
    return FavouriteApiModel(
      favouriteId: _extractId(json["_id"]).isNotEmpty
          ? _extractId(json["_id"])
          : _extractId(json["id"]),
      customerId: _extractId(json["customer"]).isNotEmpty
          ? _extractId(json["customer"])
          : _extractId(json["customerId"]),
      restaurantId: _extractId(json["restaurant"]).isNotEmpty
          ? _extractId(json["restaurant"])
          : _extractId(json["restaurantId"]),
    );
  }

  FavouriteEntity toEntity() {
    return FavouriteEntity(
      favouriteId: favouriteId,
      customerId: customerId,
      restaurantId: restaurantId,
    );
  }

  factory FavouriteApiModel.fromEntity(FavouriteEntity entity) {
    return FavouriteApiModel(
      favouriteId: entity.favouriteId,
      customerId: entity.customerId,
      restaurantId: entity.restaurantId,
    );
  }

  static List<FavouriteEntity> toEntityList(
      List<FavouriteApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}