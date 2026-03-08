import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
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
  final List? openingHours;

  RestaurantEntity({
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
    this.openingHours,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    mapLink,
    contactNumber,
    category,
    description,
    imageUrl,
    owner,
    latitude,
    longitude,
    openingHours,
  ];
}
