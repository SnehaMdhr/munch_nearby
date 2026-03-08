import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/menu_repository.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';


class GetMenuByRestaurantParams {
  final String restaurantId;

  GetMenuByRestaurantParams({required this.restaurantId});
}


final getMenuByRestaurantUsecaseProvider =
    Provider<GetMenuByRestaurantUsecase>((ref) {
  final repository = ref.read(menuRepositoryProvider);
  return GetMenuByRestaurantUsecase(repository);
});


class GetMenuByRestaurantUsecase
    implements UseCaseWithParams<List<MenuEntity>, GetMenuByRestaurantParams> {

  final IMenuRepository _repository;

  GetMenuByRestaurantUsecase(this._repository);

  @override
  Future<Either<Failure, List<MenuEntity>>> call(
      GetMenuByRestaurantParams params) {

    return _repository.getMenusByRestaurant(params.restaurantId);
  }
}