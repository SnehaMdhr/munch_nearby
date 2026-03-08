import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/restaurant/data/repositories/restaurant_repository.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:munch_nearby/features/restaurant/domain/repositories/restaurant_repository.dart';

final getRestaurantsUseCaseProvider =
    Provider<GetRestaurantsUseCase>((ref) {
  final repository = ref.read(restaurantRepositoryProvider);
  return GetRestaurantsUseCase(repository: repository);
});

class GetRestaurantsUseCase implements UsecaseWithoutParams {
  final IRestaurantRepository _repository;

  GetRestaurantsUseCase({required IRestaurantRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<RestaurantEntity>>> call() {
    return _repository.getAllRestaurants();
  }
}