import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/data/repositories/review_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

final getMyReviewsUsecaseProvider = Provider<GetMyReviewsUsecase>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return GetMyReviewsUsecase(repository);
});

class GetMyReviewsUsecase implements UsecaseWithoutParams<List<ReviewEntity>> {
  final IReviewRepository _repository;

  GetMyReviewsUsecase(this._repository);

  @override
  Future<Either<Failure, List<ReviewEntity>>> call() {
    return _repository.getMyReviews();
  }
}