import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/favourite_repository.dart';
import '../repositories/favourite_repository.dart';

class IsFavouriteParams {
  final String restaurantId;

  IsFavouriteParams({required this.restaurantId});
}

final isFavouriteUsecaseProvider =
    Provider<IsFavouriteUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return IsFavouriteUsecase(repository);
});

class IsFavouriteUsecase
    implements UseCaseWithParams<bool, IsFavouriteParams> {

  final IFavouriteRepository _repository;

  IsFavouriteUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(
      IsFavouriteParams params) {

    return _repository.isFavourite(params.restaurantId);
  }
}