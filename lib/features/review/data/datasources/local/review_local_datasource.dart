import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/data/datasources/review_datasource.dart';
import 'package:munch_nearby/features/review/data/models/review_hive_model.dart';
import '../../../../../core/services/hive/hive_service.dart';


final reviewLocalDatasourceProvider = Provider<IReviewLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ReviewLocalDatasource(hiveService: hiveService);
});

class ReviewLocalDatasource implements IReviewLocalDatasource {
  final HiveService _hiveService;

  ReviewLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<void> saveReview(ReviewHiveModel model) async {
    await _hiveService.saveReview(model);
  }

  @override
  Future<void> cacheReviews(List<ReviewHiveModel> models) async {
    await _hiveService.cacheReviews(models);
  }

  @override
  Future<List<ReviewHiveModel>> getReviewsByRestaurant(String restaurantId) async {
    return _hiveService.getReviewsByRestaurant(restaurantId);
  }

  @override
  Future<List<ReviewHiveModel>> getReviewsByCustomer(String customerId) async {
    return _hiveService.getReviewsByCustomer(customerId);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _hiveService.deleteReview(reviewId);
  }

  @override
  Future<void> clearReviews() async {
    await _hiveService.clearReviews();
  }
}