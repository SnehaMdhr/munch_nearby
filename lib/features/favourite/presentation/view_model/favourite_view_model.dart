import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/add_to_favourite_usecase.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/remove_from_favourite_usecase.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/get_favourites_usecase.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/is_favourite_usecase.dart';
import '../../domain/entities/favourite_entity.dart';
import '../state/favourite_state.dart';

final favouriteViewModelProvider =
    NotifierProvider<FavouriteViewModel, FavouriteState>(
  () => FavouriteViewModel(),
);

class FavouriteViewModel extends Notifier<FavouriteState> {
  late final AddToFavouriteUsecase _addToFavouriteUsecase;
  late final RemoveFromFavouriteUsecase _removeFromFavouriteUsecase;
  late final GetFavouritesUsecase _getFavouritesUsecase;
  late final IsFavouriteUsecase _isFavouriteUsecase;

  @override
  FavouriteState build() {
    _addToFavouriteUsecase = ref.read(addToFavouriteUsecaseProvider);
    _removeFromFavouriteUsecase =
        ref.read(removeFromFavouriteUsecaseProvider);
    _getFavouritesUsecase =
        ref.read(getFavouritesUsecaseProvider);
    _isFavouriteUsecase =
        ref.read(isFavouriteUsecaseProvider);

    Future.microtask(() => loadFavourites());

    // 3. Return initial state
    return const FavouriteState();
  }

  Future<void> loadFavourites() async {
    state = state.copyWith(status: FavouriteStatus.loading);

    final result = await _getFavouritesUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: FavouriteStatus.error,
        errorMessage: failure.message,
      ),
      (favourites) => state = state.copyWith(
        status: FavouriteStatus.loaded,
        favourites: favourites,
      ),
    );
  }

  Future<void> addToFavourite(FavouriteEntity entity) async {
    final alreadyExists = state.favourites.any(
      (item) => item.restaurantId == entity.restaurantId,
    );

    final previousFavourites = state.favourites;
    final optimisticFavourites = alreadyExists
        ? previousFavourites
        : [...previousFavourites, entity];

    state = state.copyWith(
      status: FavouriteStatus.added,
      favourites: optimisticFavourites,
      isFavourite: true,
    );

    final params = AddToFavouriteParams(entity: entity);
    final result = await _addToFavouriteUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: FavouriteStatus.error,
        favourites: previousFavourites,
        isFavourite: previousFavourites.any(
          (item) => item.restaurantId == entity.restaurantId,
        ),
        errorMessage: failure.message,
      ),
      (success) async {
        if (success) {
          Future.microtask(() => loadFavourites());
        }
      },
    );
  }

  Future<void> removeFromFavourite(String restaurantId) async {
    final previousFavourites = state.favourites;

    final optimisticFavourites = previousFavourites
        .where((item) => item.restaurantId != restaurantId)
        .toList();

    state = state.copyWith(
      status: FavouriteStatus.removed,
      favourites: optimisticFavourites,
      isFavourite: false,
    );

    final params =
        RemoveFromFavouriteParams(restaurantId: restaurantId);

    final result = await _removeFromFavouriteUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: FavouriteStatus.error,
        favourites: previousFavourites,
        isFavourite: previousFavourites.any(
          (item) => item.restaurantId == restaurantId,
        ),
        errorMessage: failure.message,
      ),
      (success) async {
        if (success) {
          Future.microtask(() => loadFavourites());
        }
      },
    );
  }

  Future<void> checkIsFavourite(String restaurantId) async {
    final params =
        IsFavouriteParams(restaurantId: restaurantId);

    final result = await _isFavouriteUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: FavouriteStatus.error,
        errorMessage: failure.message,
      ),
      (isFav) => state = state.copyWith(
        isFavourite: isFav,
      ),
    );
  }

  bool isRestaurantFavourite(String restaurantId) {
    return state.favourites.any(
      (item) => item.restaurantId == restaurantId,
    );
  }

  Future<void> toggleFavourite(FavouriteEntity entity) async {
    final isCurrentlyFav = state.favourites.any(
      (e) => e.restaurantId == entity.restaurantId,
    );

    if (isCurrentlyFav) {
      await removeFromFavourite(entity.restaurantId);
    } else {
      await addToFavourite(entity);
    }
  }
    
}