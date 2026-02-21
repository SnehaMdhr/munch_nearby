import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/data/repositories/review_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

final getRestaurantReviewsUsecaseProvider = Provider<GetRestaurantReviewsUsecase>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return GetRestaurantReviewsUsecase(repository);
});

class GetRestaurantReviewsUsecase implements UseCaseWithParams<List<ReviewEntity>, String> {
  final IReviewRepository _repository;

  GetRestaurantReviewsUsecase(this._repository);

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(String restaurantId) {
    return _repository.getRestaurantReviews(restaurantId);
  }
}