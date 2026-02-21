import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';

abstract interface class IReviewRepository {
  Future<Either<Failure, bool>> createReview(ReviewEntity entity);
  Future<Either<Failure, List<ReviewEntity>>> getRestaurantReviews(String restaurantId);
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews();
  Future<Either<Failure, bool>> updateReview(String reviewId, ReviewEntity entity);
  Future<Either<Failure, bool>> deleteReview(String reviewId);
}