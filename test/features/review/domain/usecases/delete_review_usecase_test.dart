import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/review/domain/repositories/review_repository.dart';
import 'package:munch_nearby/features/review/domain/usecases/delete_review_usecase.dart';

class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late DeleteReviewUsecase usecase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    usecase = DeleteReviewUsecase(mockRepository);
  });

  const tReviewId = 'review-1';

  group('DeleteReviewUsecase', () {
    test('should return true on successful deletion', () async {
      when(
        () => mockRepository.deleteReview(tReviewId),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tReviewId);

      expect(result, const Right(true));
      verify(() => mockRepository.deleteReview(tReviewId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
