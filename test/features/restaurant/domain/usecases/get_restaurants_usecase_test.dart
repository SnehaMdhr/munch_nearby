import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:munch_nearby/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:munch_nearby/features/restaurant/domain/usecases/get_restaurants_usecase.dart';

class MockRestaurantRepository extends Mock implements IRestaurantRepository {}

void main() {
  late GetRestaurantsUseCase usecase;
  late MockRestaurantRepository mockRepository;

  setUp(() {
    mockRepository = MockRestaurantRepository();
    usecase = GetRestaurantsUseCase(repository: mockRepository);
  });

  final tRestaurants = [
    RestaurantEntity(
      id: 'r1',
      name: 'Restaurant 1',
      address: '123 Main St',
      contactNumber: '1234567890',
      owner: 'owner-1',
    ),
    RestaurantEntity(
      id: 'r2',
      name: 'Restaurant 2',
      address: '456 Oak Ave',
      contactNumber: '0987654321',
      owner: 'owner-2',
    ),
  ];

  group('GetRestaurantsUseCase', () {
    test('should return list of restaurants on success', () async {
      when(
        () => mockRepository.getAllRestaurants(),
      ).thenAnswer((_) async => Right(tRestaurants));

      final result = await usecase();

      expect(result, Right(tRestaurants));
      verify(() => mockRepository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no restaurants', () async {
      when(
        () => mockRepository.getAllRestaurants(),
      ).thenAnswer((_) async => const Right(<RestaurantEntity>[]));

      final result = await usecase();

      expect(result, const Right(<RestaurantEntity>[]));
    });
  });
}
