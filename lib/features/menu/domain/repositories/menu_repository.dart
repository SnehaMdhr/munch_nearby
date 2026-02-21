
import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';

abstract class IMenuRepository {
  Future<Either<Failure, List<MenuEntity>>>getMenusByRestaurant(String restaurantId);
}