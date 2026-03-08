import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/domain/repositories/review_repository.dart';
import 'package:munch_nearby/features/review/domain/usecases/update_review_usecase.dart';

class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late UpdateReviewUsecase usecase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    usecase = UpdateReviewUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const ReviewEntity(
        customerId: '',
        restaurantId: '',
        rating: 0,
        comment: '',
      ),
    );
  });

  const tReviewId = 'review-1';
  const tReview = ReviewEntity(
    reviewId: tReviewId,
    customerId: 'customer-1',
    restaurantId: 'restaurant-1',
    rating: 4,
    comment: 'Updated review',
  );
  final tParams = UpdateReviewParams(reviewId: tReviewId, entity: tReview);

  group('UpdateReviewUsecase', () {
    test('should return true on successful update', () async {
      when(
        () => mockRepository.updateReview(any(), any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.updateReview(tReviewId, tReview)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
