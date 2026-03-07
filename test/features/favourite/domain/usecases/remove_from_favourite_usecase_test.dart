import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/remove_from_favourite_usecase.dart';

class MockFavouriteRepository extends Mock implements IFavouriteRepository {}

void main() {
  late RemoveFromFavouriteUsecase usecase;
  late MockFavouriteRepository mockRepository;

  setUp(() {
    mockRepository = MockFavouriteRepository();
    usecase = RemoveFromFavouriteUsecase(mockRepository);
  });

  const tRestaurantId = 'restaurant-1';
  final tParams = RemoveFromFavouriteParams(restaurantId: tRestaurantId);

  group('RemoveFromFavouriteUsecase', () {
    test('should return true on successful removal', () async {
      when(
        () => mockRepository.removeFromFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.removeFromFavourite(tRestaurantId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to remove favourite');
      when(
        () => mockRepository.removeFromFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.removeFromFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });
}
