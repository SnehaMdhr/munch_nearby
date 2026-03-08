import 'package:equatable/equatable.dart';

class FavouriteEntity extends Equatable {
  final String? favouriteId; 
  final String customerId;
  final String restaurantId;

  const FavouriteEntity({
    this.favouriteId,
    required this.customerId,
    required this.restaurantId,
  });

  @override
  List<Object?> get props => [
        favouriteId,
        customerId,
        restaurantId,
      ];
}