import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/data/repositories/review_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class UpdateReviewParams {
  final String reviewId;
  final ReviewEntity entity;

  UpdateReviewParams({required this.reviewId, required this.entity});
}

final updateReviewUsecaseProvider = Provider<UpdateReviewUsecase>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return UpdateReviewUsecase(repository);
});

class UpdateReviewUsecase implements UseCaseWithParams<bool, UpdateReviewParams> {
  final IReviewRepository _repository;

  UpdateReviewUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(UpdateReviewParams params) {
    return _repository.updateReview(params.reviewId, params.entity);
  }
}