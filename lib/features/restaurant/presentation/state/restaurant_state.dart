import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant_entity.dart';

enum RestaurantStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
}

class RestaurantState extends Equatable {
  final RestaurantStatus status;
  final List<RestaurantEntity> restaurants;
  final String? errorMessage;

  const RestaurantState({
    this.status = RestaurantStatus.initial,
    this.restaurants = const [],
    this.errorMessage,
  });

  RestaurantState copyWith({
    RestaurantStatus? status,
    List<RestaurantEntity>? restaurants,
    String? errorMessage,
  }) {
    return RestaurantState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, restaurants, errorMessage];
}