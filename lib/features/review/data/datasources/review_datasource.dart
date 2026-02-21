import '../models/review_api_model.dart';
import '../models/review_hive_model.dart';

abstract interface class IReviewRemoteDatasource {
  Future<List<ReviewApiModel>> getRestaurantReviews(String restaurantId);
  Future<List<ReviewApiModel>> getMyReviews();
  Future<ReviewApiModel> createReview(ReviewApiModel model);
  Future<void> updateReview(String reviewId, ReviewApiModel model);
  Future<void> deleteReview(String reviewId);
}

abstract interface class IReviewLocalDatasource {
  Future<void> saveReview(ReviewHiveModel model);
  Future<void> cacheReviews(List<ReviewHiveModel> models);
  Future<List<ReviewHiveModel>> getReviewsByRestaurant(String restaurantId);
  Future<List<ReviewHiveModel>> getReviewsByCustomer(String customerId);
  Future<void> deleteReview(String reviewId);
  Future<void> clearReviews();
}