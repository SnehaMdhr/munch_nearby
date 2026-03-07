import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/domain/usecases/create_review_usecase.dart';
import 'package:munch_nearby/features/review/domain/usecases/delete_review_usecase.dart';
import 'package:munch_nearby/features/review/domain/usecases/get_restaurant_review_usecase.dart';
import 'package:munch_nearby/features/review/domain/usecases/update_review_usecase.dart';
import 'package:munch_nearby/features/review/presentation/state/review_state.dart';
import 'package:munch_nearby/features/review/presentation/view_model/review_view_model.dart';

class MockCreateReviewUsecase extends Mock implements CreateReviewUsecase {}

class MockGetRestaurantReviewsUsecase extends Mock
    implements GetRestaurantReviewsUsecase {}

class MockUpdateReviewUsecase extends Mock implements UpdateReviewUsecase {}

class MockDeleteReviewUsecase extends Mock implements DeleteReviewUsecase {}

void main() {
  late MockCreateReviewUsecase mockCreateReviewUsecase;
  late MockGetRestaurantReviewsUsecase mockGetRestaurantReviewsUsecase;
  late MockUpdateReviewUsecase mockUpdateReviewUsecase;
  late MockDeleteReviewUsecase mockDeleteReviewUsecase;
  late ProviderContainer container;

  setUp(() {
    mockCreateReviewUsecase = MockCreateReviewUsecase();
    mockGetRestaurantReviewsUsecase = MockGetRestaurantReviewsUsecase();
    mockUpdateReviewUsecase = MockUpdateReviewUsecase();
    mockDeleteReviewUsecase = MockDeleteReviewUsecase();

    container = ProviderContainer(
      overrides: [
        createReviewUsecaseProvider.overrideWithValue(mockCreateReviewUsecase),
        getRestaurantReviewsUsecaseProvider.overrideWithValue(
          mockGetRestaurantReviewsUsecase,
        ),
        updateReviewUsecaseProvider.overrideWithValue(mockUpdateReviewUsecase),
        deleteReviewUsecaseProvider.overrideWithValue(mockDeleteReviewUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(
      CreateReviewParams(
        entity: const ReviewEntity(
          customerId: '',
          restaurantId: '',
          rating: 0,
          comment: '',
        ),
      ),
    );
    registerFallbackValue(
      UpdateReviewParams(
        reviewId: '',
        entity: const ReviewEntity(
          customerId: '',
          restaurantId: '',
          rating: 0,
          comment: '',
        ),
      ),
    );
  });

  ReviewState getState() => container.read(reviewViewModelProvider);
  ReviewViewModel getNotifier() =>
      container.read(reviewViewModelProvider.notifier);

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

  group('ReviewViewModel - initial state', () {
    test('should have initial state', () {
      final state = getState();

      expect(state.status, ReviewStatus.initial);
      expect(state.reviews, isEmpty);
      expect(state.errorMessage, isNull);
    });
  });

  group('ReviewViewModel - loadRestaurantReviews', () {
    test('should emit loaded status with reviews on success', () async {
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Right(tReviews));

      await getNotifier().loadRestaurantReviews(tRestaurantId);

      final state = getState();
      expect(state.status, ReviewStatus.loaded);
      expect(state.reviews, tReviews);
      expect(state.reviews.length, 2);
    });

    test('should emit loaded with empty list when no reviews', () async {
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Right(<ReviewEntity>[]));

      await getNotifier().loadRestaurantReviews(tRestaurantId);

      final state = getState();
      expect(state.status, ReviewStatus.loaded);
      expect(state.reviews, isEmpty);
    });

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to fetch reviews');
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().loadRestaurantReviews(tRestaurantId);

      final state = getState();
      expect(state.status, ReviewStatus.error);
      expect(state.errorMessage, 'Failed to fetch reviews');
    });

    test('should emit error on network failure', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().loadRestaurantReviews(tRestaurantId);

      final state = getState();
      expect(state.status, ReviewStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });
  });

  group('ReviewViewModel - addReview', () {
    const tReview = ReviewEntity(
      customerId: 'c1',
      restaurantId: tRestaurantId,
      rating: 5,
      comment: 'Great!',
    );

    test('should call create usecase and reload reviews on success', () async {
      when(
        () => mockCreateReviewUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Right(tReviews));

      await getNotifier().addReview(tReview);
      // loadRestaurantReviews is called fire-and-forget after success
      await Future.delayed(Duration.zero);

      final state = getState();
      expect(state.status, ReviewStatus.loaded);
      expect(state.reviews, tReviews);
      verify(() => mockCreateReviewUsecase(any())).called(1);
      verify(() => mockGetRestaurantReviewsUsecase(tRestaurantId)).called(1);
    });

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to create review');
      when(
        () => mockCreateReviewUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().addReview(tReview);

      final state = getState();
      expect(state.status, ReviewStatus.error);
      expect(state.errorMessage, 'Failed to create review');
    });
  });

  group('ReviewViewModel - updateReview', () {
    const tReview = ReviewEntity(
      reviewId: 'r1',
      customerId: 'c1',
      restaurantId: tRestaurantId,
      rating: 4,
      comment: 'Updated review',
    );

    test('should call update usecase and reload reviews on success', () async {
      when(
        () => mockUpdateReviewUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Right(tReviews));

      await getNotifier().updateReview('r1', tReview);
      // loadRestaurantReviews is called fire-and-forget after success
      await Future.delayed(Duration.zero);

      final state = getState();
      expect(state.status, ReviewStatus.loaded);
      expect(state.reviews, tReviews);
      verify(() => mockUpdateReviewUsecase(any())).called(1);
      verify(() => mockGetRestaurantReviewsUsecase(tRestaurantId)).called(1);
    });

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to update review');
      when(
        () => mockUpdateReviewUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().updateReview('r1', tReview);

      final state = getState();
      expect(state.status, ReviewStatus.error);
      expect(state.errorMessage, 'Failed to update review');
    });
  });

  group('ReviewViewModel - deleteReview', () {
    test('should call delete usecase and reload reviews on success', () async {
      when(
        () => mockDeleteReviewUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetRestaurantReviewsUsecase(tRestaurantId),
      ).thenAnswer((_) async => const Right(<ReviewEntity>[]));

      await getNotifier().deleteReview('r1', tRestaurantId);
      // loadRestaurantReviews is called fire-and-forget after success
      await Future.delayed(Duration.zero);

      final state = getState();
      expect(state.status, ReviewStatus.loaded);
      expect(state.reviews, isEmpty);
      verify(() => mockDeleteReviewUsecase('r1')).called(1);
      verify(() => mockGetRestaurantReviewsUsecase(tRestaurantId)).called(1);
    });

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to delete review');
      when(
        () => mockDeleteReviewUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().deleteReview('r1', tRestaurantId);

      final state = getState();
      expect(state.status, ReviewStatus.error);
      expect(state.errorMessage, 'Failed to delete review');
    });
  });
}
