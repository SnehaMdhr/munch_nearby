import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/favourite_repository.dart';
import '../entities/favourite_entity.dart';
import '../repositories/favourite_repository.dart';

class AddToFavouriteParams {
  final FavouriteEntity entity;

  AddToFavouriteParams({required this.entity});
}

final addToFavouriteUsecaseProvider =
    Provider<AddToFavouriteUsecase>((ref) {
  final repository = ref.read(favouriteRepositoryProvider);
  return AddToFavouriteUsecase(repository);
});

class AddToFavouriteUsecase
    implements UseCaseWithParams<bool, AddToFavouriteParams> {

  final IFavouriteRepository _repository;

  AddToFavouriteUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(
      AddToFavouriteParams params) {

    return _repository.addToFavourite(params.entity);
  }
}