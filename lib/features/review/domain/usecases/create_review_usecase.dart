import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/review/data/repositories/review_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class CreateReviewParams {
  final ReviewEntity entity;

  CreateReviewParams({required this.entity});
}

final createReviewUsecaseProvider = Provider<CreateReviewUsecase>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return CreateReviewUsecase(repository);
});

class CreateReviewUsecase implements UseCaseWithParams<bool, CreateReviewParams> {
  final IReviewRepository _repository;

  CreateReviewUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(CreateReviewParams params) {
    return _repository.createReview(params.entity);
  }
}