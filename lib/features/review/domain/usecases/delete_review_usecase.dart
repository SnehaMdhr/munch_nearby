import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/data/repositories/review_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../repositories/review_repository.dart';

final deleteReviewUsecaseProvider = Provider<DeleteReviewUsecase>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return DeleteReviewUsecase(repository);
});

class DeleteReviewUsecase implements UseCaseWithParams<bool, String> {
  final IReviewRepository _repository;

  DeleteReviewUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(String reviewId) {
    return _repository.deleteReview(reviewId);
  }
}