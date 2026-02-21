import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';

abstract interface class IFavouriteRepository {
  Future<Either<Failure, bool>> addToFavourite(FavouriteEntity entity,);
  Future<Either<Failure, bool>> removeFromFavourite(String restaurantId,);
  Future<Either<Failure, List<FavouriteEntity>>> getFavourites();
  Future<Either<Failure, bool>> isFavourite(String restaurantId,);
  
}