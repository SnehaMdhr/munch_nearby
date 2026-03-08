import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';
import 'package:munch_nearby/features/menu/domain/repositories/menu_repository.dart';
import 'package:munch_nearby/features/menu/domain/usecases/get_menu_by_restaurant_usecase.dart';

class MockMenuRepository extends Mock implements IMenuRepository {}

void main() {
  late GetMenuByRestaurantUsecase usecase;
  late MockMenuRepository mockRepository;

  setUp(() {
    mockRepository = MockMenuRepository();
    usecase = GetMenuByRestaurantUsecase(mockRepository);
  });

  const tRestaurantId = 'restaurant-1';
  final tParams = GetMenuByRestaurantParams(restaurantId: tRestaurantId);
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

  group('GetMenuByRestaurantUsecase', () {
    test('should return list of menus on success', () async {
      when(
        () => mockRepository.getMenusByRestaurant(tRestaurantId),
      ).thenAnswer((_) async => const Right(tMenus));

      final result = await usecase(tParams);

      expect(result, const Right(tMenus));
      verify(
        () => mockRepository.getMenusByRestaurant(tRestaurantId),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no menus found', () async {
      when(
        () => mockRepository.getMenusByRestaurant(tRestaurantId),
      ).thenAnswer((_) async => const Right(<MenuEntity>[]));

      final result = await usecase(tParams);

      expect(result, const Right(<MenuEntity>[]));
    });
  });
}
