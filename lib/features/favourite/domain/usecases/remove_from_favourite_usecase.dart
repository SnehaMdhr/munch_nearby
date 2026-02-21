import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/favourite_repository.dart';
import '../repositories/favourite_repository.dart';

class RemoveFromFavouriteParams {
  final String restaurantId;

  RemoveFromFavouriteParams({required this.restaurantId});
}

final removeFromFavouriteUsecaseProvider =
    Provider<RemoveFromFavouriteUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return RemoveFromFavouriteUsecase(repository);
});

class RemoveFromFavouriteUsecase
    implements UseCaseWithParams<bool, RemoveFromFavouriteParams> {

  final IFavouriteRepository _repository;

  RemoveFromFavouriteUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(
      RemoveFromFavouriteParams params) {

    return _repository
        .removeFromFavourite(params.restaurantId);
  }
}