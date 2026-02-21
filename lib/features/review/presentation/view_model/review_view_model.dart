import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/domain/usecases/get_restaurant_review_usecase.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import '../../domain/usecases/update_review_usecase.dart';
import '../state/review_state.dart';

final reviewViewModelProvider =
    NotifierProvider<ReviewViewModel, ReviewState>(
  () => ReviewViewModel(),
);

class ReviewViewModel extends Notifier<ReviewState> {
  late final CreateReviewUsecase _createReviewUsecase;
  late final GetRestaurantReviewsUsecase _getRestaurantReviewsUsecase;
  late final UpdateReviewUsecase _updateReviewUsecase;
  late final DeleteReviewUsecase _deleteReviewUsecase;

  @override
  ReviewState build() {
    _createReviewUsecase = ref.read(createReviewUsecaseProvider);
    _getRestaurantReviewsUsecase = ref.read(getRestaurantReviewsUsecaseProvider);
    _updateReviewUsecase = ref.read(updateReviewUsecaseProvider);
    _deleteReviewUsecase = ref.read(deleteReviewUsecaseProvider);

    return const ReviewState();
  }

  Future<void> loadRestaurantReviews(String restaurantId) async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _getRestaurantReviewsUsecase(restaurantId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (reviews) => state = state.copyWith(
        status: ReviewStatus.loaded,
        reviews: reviews,
      ),
    );
  }

  Future<void> addReview(ReviewEntity entity) async {
    state = state.copyWith(status: ReviewStatus.submitting);

    final params = CreateReviewParams(entity: entity);
    final result = await _createReviewUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: ReviewStatus.success);
        loadRestaurantReviews(entity.restaurantId);
      },
    );
  }

  Future<void> updateReview(String reviewId, ReviewEntity entity) async {
    state = state.copyWith(status: ReviewStatus.submitting);

    final params = UpdateReviewParams(reviewId: reviewId, entity: entity);
    final result = await _updateReviewUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: ReviewStatus.success);
        loadRestaurantReviews(entity.restaurantId);
      },
    );
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String restaurantId) async {
    state = state.copyWith(status: ReviewStatus.submitting);

    final result = await _deleteReviewUsecase(reviewId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: ReviewStatus.success);
        loadRestaurantReviews(restaurantId);
      },
    );
  }
}