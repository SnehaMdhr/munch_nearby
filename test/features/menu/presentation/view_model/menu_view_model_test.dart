import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';
import 'package:munch_nearby/features/menu/domain/usecases/get_menu_by_restaurant_usecase.dart';
import 'package:munch_nearby/features/menu/presentation/state/menu_state.dart';
import 'package:munch_nearby/features/menu/presentation/view_model/menu_view_model.dart';

class MockGetMenuByRestaurantUsecase extends Mock
    implements GetMenuByRestaurantUsecase {}

void main() {
  late MockGetMenuByRestaurantUsecase mockGetMenuByRestaurantUsecase;
  late ProviderContainer container;

  setUp(() {
    mockGetMenuByRestaurantUsecase = MockGetMenuByRestaurantUsecase();

    container = ProviderContainer(
      overrides: [
        getMenuByRestaurantUsecaseProvider.overrideWithValue(
          mockGetMenuByRestaurantUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(GetMenuByRestaurantParams(restaurantId: ''));
  });

  MenuState getState() => container.read(menuViewModelProvider);
  MenuViewModel getNotifier() => container.read(menuViewModelProvider.notifier);

  const tRestaurantId = 'restaurant-1';
  const tMenus = [
    MenuEntity(
      id: 'menu-1',
      name: 'Burger',
      price: 9.99,
      category: 'Main Course',
      isAvailable: true,
      restaurantId: tRestaurantId,
    ),
    MenuEntity(
      id: 'menu-2',
      name: 'Fries',
      price: 4.99,
      category: 'Sides',
      isAvailable: true,
      restaurantId: tRestaurantId,
    ),
  ];

  group('MenuViewModel - fetchMenus', () {
    test('should emit loaded status with menus on success', () async {
      when(
        () => mockGetMenuByRestaurantUsecase(any()),
      ).thenAnswer((_) async => const Right(tMenus));

      await getNotifier().fetchMenus(tRestaurantId);

      final state = getState();
      expect(state.status, MenuStatus.loaded);
      expect(state.menus, tMenus);
      expect(state.menus.length, 2);
    });

    test('should emit loaded status with empty list when no menus', () async {
      when(
        () => mockGetMenuByRestaurantUsecase(any()),
      ).thenAnswer((_) async => const Right(<MenuEntity>[]));

      await getNotifier().fetchMenus(tRestaurantId);

      final state = getState();
      expect(state.status, MenuStatus.loaded);
      expect(state.menus, isEmpty);
    });
  });
}
