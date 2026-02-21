import 'package:equatable/equatable.dart';

class MenuEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final bool isAvailable;
  final String restaurantId;
  const MenuEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.restaurantId,
  });
  
  @override
  List<Object?> get props => [id,name, description, price, category,isAvailable, restaurantId];
}