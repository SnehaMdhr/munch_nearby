import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:munch_nearby/features/restaurant/domain/usecases/get_restaurants_usecase.dart';
import 'package:munch_nearby/features/restaurant/presentation/state/restaurant_state.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';

class MockGetRestaurantsUseCase extends Mock implements GetRestaurantsUseCase {}

void main() {
  late MockGetRestaurantsUseCase mockGetRestaurantsUseCase;
  late ProviderContainer container;

  setUp(() {
    mockGetRestaurantsUseCase = MockGetRestaurantsUseCase();

    container = ProviderContainer(
      overrides: [
        getRestaurantsUseCaseProvider.overrideWithValue(
          mockGetRestaurantsUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  RestaurantState getState() => container.read(restaurantViewModelProvider);
  RestaurantViewModel getNotifier() =>
      container.read(restaurantViewModelProvider.notifier);

  final tRestaurants = [
    RestaurantEntity(
      id: 'r1',
      name: 'Pizza Palace',
      address: '123 Main St',
      contactNumber: '1234567890',
      owner: 'owner-1',
    ),
    RestaurantEntity(
      id: 'r2',
      name: 'Burger Barn',
      address: '456 Oak Ave',
      contactNumber: '0987654321',
      owner: 'owner-2',
    ),
    RestaurantEntity(
      id: 'r3',
      name: 'Sushi Spot',
      address: '789 Pine Rd',
      contactNumber: '1112223333',
      owner: 'owner-3',
    ),
  ];

  group('RestaurantViewModel - searchRestaurants', () {
    test('should filter restaurants by name', () async {
      when(
        () => mockGetRestaurantsUseCase(),
      ).thenAnswer((_) async => Right(tRestaurants));

      await getNotifier().getRestaurants();
      getNotifier().searchRestaurants('Pizza');

      final state = getState();
      expect(state.restaurants.length, 1);
      expect(state.restaurants.first.name, 'Pizza Palace');
    });

    test('should return all restaurants when query is empty', () async {
      when(
        () => mockGetRestaurantsUseCase(),
      ).thenAnswer((_) async => Right(tRestaurants));

      await getNotifier().getRestaurants();
      getNotifier().searchRestaurants('');

      final state = getState();
      expect(state.restaurants.length, 3);
    });
  });
}
