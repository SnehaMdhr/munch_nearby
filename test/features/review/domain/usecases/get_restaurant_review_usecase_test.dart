import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/domain/repositories/review_repository.dart';
import 'package:munch_nearby/features/review/domain/usecases/get_restaurant_review_usecase.dart';

class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late GetRestaurantReviewsUsecase usecase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    usecase = GetRestaurantReviewsUsecase(mockRepository);
  });

  const tRestaurantId = 'restaurant-1';
  const tReviews = [
    ReviewEntity(
      reviewId: 'r1',
      customerId: 'c1',
      restaurantId: tRestaurantId,
      rating: 5,
      comment: 'Excellent!',
    ),
    ReviewEntity(
      reviewId: 'r2',
      customerId: 'c2',
      restaurantId: tRestaurantId,
      rating: 4,
      comment: 'Good food',
    ),
  ];

  group('GetRestaurantReviewsUsecase', () {
    test('should return list of reviews on success', () async {
      when(
        () => mockRepository.getRestaurantReviews(tRestaurantId),
      ).thenAnswer((_) async => const Right(tReviews));

      final result = await usecase(tRestaurantId);

      expect(result, const Right(tReviews));
      verify(
        () => mockRepository.getRestaurantReviews(tRestaurantId),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no reviews', () async {
      when(
        () => mockRepository.getRestaurantReviews(tRestaurantId),
      ).thenAnswer((_) async => const Right(<ReviewEntity>[]));

      final result = await usecase(tRestaurantId);

      expect(result, const Right(<ReviewEntity>[]));
    });
  });
}
