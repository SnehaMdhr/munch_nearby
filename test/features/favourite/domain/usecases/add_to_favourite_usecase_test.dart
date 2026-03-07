import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/add_to_favourite_usecase.dart';

class MockFavouriteRepository extends Mock implements IFavouriteRepository {}

void main() {
  late AddToFavouriteUsecase usecase;
  late MockFavouriteRepository mockRepository;

  setUp(() {
    mockRepository = MockFavouriteRepository();
    usecase = AddToFavouriteUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const FavouriteEntity(customerId: '', restaurantId: ''),
    );
  });

  const tEntity = FavouriteEntity(
    customerId: 'customer-1',
    restaurantId: 'restaurant-1',
  );
  final tParams = AddToFavouriteParams(entity: tEntity);

  group('AddToFavouriteUsecase', () {
    test('should return true on success', () async {
      when(
        () => mockRepository.addToFavourite(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.addToFavourite(tEntity)).called(1);
    });

    test('should return ApiFailure on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to add favourite');
      when(
        () => mockRepository.addToFavourite(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.addToFavourite(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });
}
