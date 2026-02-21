import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/restaurant/domain/usecases/get_restaurants_usecase.dart';
import '../state/restaurant_state.dart';

final restaurantViewModelProvider =
    NotifierProvider<RestaurantViewModel, RestaurantState>(
  () => RestaurantViewModel(),
);

class RestaurantViewModel extends Notifier<RestaurantState> {
  late final GetRestaurantsUseCase _getRestaurantsUseCase;

  @override
  RestaurantState build() {
    _getRestaurantsUseCase = ref.read(getRestaurantsUseCaseProvider);
    return const RestaurantState();
  }

  Future<void> getRestaurants() async {
    state = state.copyWith(
      status: RestaurantStatus.loading,
      errorMessage: null,
    );

    final result = await _getRestaurantsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: RestaurantStatus.error,
          errorMessage: failure.message,
        );
      },
      (restaurants) {
        state = state.copyWith(
          status: RestaurantStatus.loaded,
          restaurants: restaurants,
        );
      },
    );
  }
}