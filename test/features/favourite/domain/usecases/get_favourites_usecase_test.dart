import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/get_favourites_usecase.dart';

class MockFavouriteRepository extends Mock implements IFavouriteRepository {}

void main() {
  late GetFavouritesUsecase usecase;
  late MockFavouriteRepository mockRepository;

  setUp(() {
    mockRepository = MockFavouriteRepository();
    usecase = GetFavouritesUsecase(mockRepository);
  });

  const tFavourites = [
    FavouriteEntity(customerId: 'c1', restaurantId: 'r1'),
    FavouriteEntity(customerId: 'c1', restaurantId: 'r2'),
  ];

  group('GetFavouritesUsecase', () {
    test('should return list of favourites on success', () async {
      when(
        () => mockRepository.getFavourites(),
      ).thenAnswer((_) async => const Right(tFavourites));

      final result = await usecase();

      expect(result, const Right(tFavourites));
      verify(() => mockRepository.getFavourites()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no favourites', () async {
      when(
        () => mockRepository.getFavourites(),
      ).thenAnswer((_) async => const Right(<FavouriteEntity>[]));

      final result = await usecase();

      expect(result, const Right(<FavouriteEntity>[]));
    });

    test('should return ApiFailure on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to fetch favourites');
      when(
        () => mockRepository.getFavourites(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.getFavourites(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });
  });
}
