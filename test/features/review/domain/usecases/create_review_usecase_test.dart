import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/domain/repositories/review_repository.dart';
import 'package:munch_nearby/features/review/domain/usecases/create_review_usecase.dart';

class MockReviewRepository extends Mock implements IReviewRepository {}

void main() {
  late CreateReviewUsecase usecase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    usecase = CreateReviewUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const ReviewEntity(
        customerId: '',
        restaurantId: '',
        rating: 0,
        comment: '',
      ),
    );
  });

  const tReview = ReviewEntity(
    customerId: 'customer-1',
    restaurantId: 'restaurant-1',
    rating: 5,
    comment: 'Great food!',
  );
  final tParams = CreateReviewParams(entity: tReview);

  group('CreateReviewUsecase', () {
    test('should return true on successful review creation', () async {
      when(
        () => mockRepository.createReview(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.createReview(tReview)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
