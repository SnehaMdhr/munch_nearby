import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/menu/domain/usecases/get_menu_by_restaurant_usecase.dart';
import '../state/menu_state.dart';

final menuViewModelProvider =
    NotifierProvider<MenuViewModel, MenuState>(
  () => MenuViewModel(),
);

class MenuViewModel extends Notifier<MenuState> {

  late final GetMenuByRestaurantUsecase _getMenuUsecase;

  @override
  MenuState build() {
    _getMenuUsecase = ref.read(getMenuByRestaurantUsecaseProvider);
    return const MenuState();
  }

  Future<void> fetchMenus(String restaurantId) async {
    state = state.copyWith(status: MenuStatus.loading);

    final params =
        GetMenuByRestaurantParams(restaurantId: restaurantId);

    final result = await _getMenuUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        );
      },
      (menus) {
        state = state.copyWith(
          status: MenuStatus.loaded,
          menus: menus,
        );
      },
    );
  }
}