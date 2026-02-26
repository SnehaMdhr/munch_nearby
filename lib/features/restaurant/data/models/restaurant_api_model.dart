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
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
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
      if (longitude != null && latitude != null)
        "location": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
    };
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty || normalized == 'null') {
        return null;
      }
      return double.tryParse(normalized);
    }

    if (value is Map<String, dynamic>) {
      final nested = value[r'$numberDouble'] ?? value[r'$numberDecimal'];
      return _parseNullableDouble(nested);
    }

    return double.tryParse(value.toString());
  }

  /// Parse latitude from GeoJSON: { type: "Point", coordinates: [lng, lat] }
  static double? _parseLatFromLocation(dynamic location) {
    if (location is Map<String, dynamic>) {
      final coords = location['coordinates'];
      if (coords is List && coords.length >= 2) {
        return _parseNullableDouble(coords[1]);
      }
    }
    return null;
  }

  /// Parse longitude from GeoJSON: { type: "Point", coordinates: [lng, lat] }
  static double? _parseLngFromLocation(dynamic location) {
    if (location is Map<String, dynamic>) {
      final coords = location['coordinates'];
      if (coords is List && coords.length >= 2) {
        return _parseNullableDouble(coords[0]);
      }
    }
    return null;
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
      latitude: _parseLatFromLocation(json['location']),
      longitude: _parseLngFromLocation(json['location']),
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
      latitude: latitude,
      longitude: longitude,
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
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
  static List<RestaurantEntity> toEntityList(List<RestaurantApiModel> models) {
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
      latitude: latitude,
      longitude: longitude,
    );
  }
}
