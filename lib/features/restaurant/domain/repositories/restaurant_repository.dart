import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';

abstract class IRestaurantRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants();
  Future<Either<Failure, List<RestaurantEntity>>> refreshRestaurants();
}