import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/domain/repositories/review_repository.dart';
import 'package:munch_nearby/features/review/domain/usecases/get_my_review_usecase.dart';

class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late GetMyReviewsUsecase usecase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    usecase = GetMyReviewsUsecase(mockRepository);
  });

  const tReviews = [
    ReviewEntity(
      reviewId: 'r1',
      customerId: 'c1',
      restaurantId: 'rest-1',
      rating: 5,
      comment: 'Great!',
    ),
    ReviewEntity(
      reviewId: 'r2',
      customerId: 'c1',
      restaurantId: 'rest-2',
      rating: 3,
      comment: 'Average',
    ),
  ];

  group('GetMyReviewsUsecase', () {
    test('should return list of user reviews on success', () async {
      when(
        () => mockRepository.getMyReviews(),
      ).thenAnswer((_) async => const Right(tReviews));

      final result = await usecase();

      expect(result, const Right(tReviews));
      verify(() => mockRepository.getMyReviews()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no reviews', () async {
      when(
        () => mockRepository.getMyReviews(),
      ).thenAnswer((_) async => const Right(<ReviewEntity>[]));

      final result = await usecase();

      expect(result, const Right(<ReviewEntity>[]));
    });

    test('should return ApiFailure on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to fetch reviews');
      when(
        () => mockRepository.getMyReviews(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.getMyReviews(),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase();

      expect(result, const Left(tFailure));
    });
  });
}
