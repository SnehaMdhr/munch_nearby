import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/is_favourite_usecase.dart';

class MockFavouriteRepository extends Mock implements IFavouriteRepository {}

void main() {
  late IsFavouriteUsecase usecase;
  late MockFavouriteRepository mockRepository;

  setUp(() {
    mockRepository = MockFavouriteRepository();
    usecase = IsFavouriteUsecase(mockRepository);
  });

  const tRestaurantId = 'restaurant-1';
  final tParams = IsFavouriteParams(restaurantId: tRestaurantId);

  group('IsFavouriteUsecase', () {
    test('should return true when restaurant is favourite', () async {
      when(
        () => mockRepository.isFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.isFavourite(tRestaurantId)).called(1);
    });

    test('should return false when restaurant is not favourite', () async {
      when(
        () => mockRepository.isFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Right(false));

      final result = await usecase(tParams);

      expect(result, const Right(false));
    });

    test('should return ApiFailure on failure', () async {
      const tFailure = ApiFailure(message: 'Check failed');
      when(
        () => mockRepository.isFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.isFavourite(tRestaurantId),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(tParams);

      expect(result, const Left(tFailure));
    });
  });
}
