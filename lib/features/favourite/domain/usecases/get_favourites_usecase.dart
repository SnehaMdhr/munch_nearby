import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/favourite_repository.dart';
import '../entities/favourite_entity.dart';
import '../repositories/favourite_repository.dart';

final getFavouritesUsecaseProvider =
    Provider<GetFavouritesUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return GetFavouritesUsecase(repository);
});

class GetFavouritesUsecase
    implements UsecaseWithoutParams<List<FavouriteEntity>> {

  final IFavouriteRepository _repository;

  GetFavouritesUsecase(this._repository);

  @override
  Future<Either<Failure, List<FavouriteEntity>>> call() {
    return _repository.getFavourites();
  }
}