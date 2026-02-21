import '../../domain/entities/restaurant_entity.dart';
import 'restaurant_hive_model.dart';

class RestaurantApiModel {
  final String id;
  final String name;
  final String address;
  final String? mapLink;
  final String contactNumber;
  final String? category;
  final String? description;
  final String? imageUrl;
  final String owner;

  RestaurantApiModel({
    required this.id,
    required this.name,
    required this.address,
    this.mapLink,
    required this.contactNumber,
    this.category,
    this.description,
    this.imageUrl,
    required this.owner,
  });

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "address": address,
      "mapLink": mapLink,
      "contactNumber": contactNumber,
      "category": category,
      "description": description,
      "imageUrl": imageUrl,
      "owner": owner,
    };
  }
  factory RestaurantApiModel.fromJson(Map<String, dynamic> json) {
  return RestaurantApiModel(
    id: json["_id"] is Map
        ? json["_id"]["\$oid"] ?? ""
        : json["_id"]?.toString() ?? "",

    name: json["name"]?.toString() ?? "",
    address: json["address"]?.toString() ?? "",
    mapLink: json["mapLink"]?.toString() ?? "",
    contactNumber: json["contactNumber"]?.toString() ?? "",
    category: json["category"]?.toString() ?? "",
    description: json["description"]?.toString() ?? "",

    imageUrl: json["imageUrl"] is Map
        ? json["imageUrl"]["url"]?.toString()
        : json["imageUrl"]?.toString(),

    owner: json["owner"]?.toString() ?? "",
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

  factory RestaurantApiModel.fromEntity(RestaurantEntity entity) {
    return RestaurantApiModel(
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
  static List<RestaurantEntity> toEntityList(
      List<RestaurantApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
  RestaurantHiveModel toHiveModel() {
    return RestaurantHiveModel(
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
}