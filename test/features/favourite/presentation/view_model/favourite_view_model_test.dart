import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/add_to_favourite_usecase.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/get_favourites_usecase.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/is_favourite_usecase.dart';
import 'package:munch_nearby/features/favourite/domain/usecases/remove_from_favourite_usecase.dart';
import 'package:munch_nearby/features/favourite/presentation/state/favourite_state.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';

class MockAddToFavouriteUsecase extends Mock implements AddToFavouriteUsecase {}

class MockRemoveFromFavouriteUsecase extends Mock
    implements RemoveFromFavouriteUsecase {}

class MockGetFavouritesUsecase extends Mock implements GetFavouritesUsecase {}

class MockIsFavouriteUsecase extends Mock implements IsFavouriteUsecase {}

void main() {
  late MockAddToFavouriteUsecase mockAddToFavouriteUsecase;
  late MockRemoveFromFavouriteUsecase mockRemoveFromFavouriteUsecase;
  late MockGetFavouritesUsecase mockGetFavouritesUsecase;
  late MockIsFavouriteUsecase mockIsFavouriteUsecase;
  late ProviderContainer container;

  setUp(() {
    mockAddToFavouriteUsecase = MockAddToFavouriteUsecase();
    mockRemoveFromFavouriteUsecase = MockRemoveFromFavouriteUsecase();
    mockGetFavouritesUsecase = MockGetFavouritesUsecase();
    mockIsFavouriteUsecase = MockIsFavouriteUsecase();

    // stub loadFavourites called in build() via Future.microtask
    when(
      () => mockGetFavouritesUsecase(),
    ).thenAnswer((_) async => const Right(<FavouriteEntity>[]));

    container = ProviderContainer(
      overrides: [
        addToFavouriteUsecaseProvider.overrideWithValue(
          mockAddToFavouriteUsecase,
        ),
        removeFromFavouriteUsecaseProvider.overrideWithValue(
          mockRemoveFromFavouriteUsecase,
        ),
        getFavouritesUsecaseProvider.overrideWithValue(
          mockGetFavouritesUsecase,
        ),
        isFavouriteUsecaseProvider.overrideWithValue(mockIsFavouriteUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(
      AddToFavouriteParams(
        entity: const FavouriteEntity(customerId: '', restaurantId: ''),
      ),
    );
    registerFallbackValue(RemoveFromFavouriteParams(restaurantId: ''));
    registerFallbackValue(IsFavouriteParams(restaurantId: ''));
  });

  FavouriteState getState() => container.read(favouriteViewModelProvider);
  FavouriteViewModel getNotifier() =>
      container.read(favouriteViewModelProvider.notifier);

  group('FavouriteViewModel - initial state', () {
    test('should have initial state', () {
      final state = getState();

      expect(state.status, FavouriteStatus.initial);
      expect(state.favourites, isEmpty);
      expect(state.isFavourite, false);
      expect(state.errorMessage, isNull);
    });
  });

  group('FavouriteViewModel - loadFavourites', () {
    const tFavourites = [
      FavouriteEntity(customerId: 'c1', restaurantId: 'r1'),
      FavouriteEntity(customerId: 'c1', restaurantId: 'r2'),
    ];

    test('should emit loaded status with favourites on success', () async {
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Right(tFavourites));

      await getNotifier().loadFavourites();

      final state = getState();
      expect(state.status, FavouriteStatus.loaded);
      expect(state.favourites, tFavourites);
    });

    test('should emit error status on failure', () async {
      const tFailure = ApiFailure(message: 'Failed to load');
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().loadFavourites();

      final state = getState();
      expect(state.status, FavouriteStatus.error);
      expect(state.errorMessage, 'Failed to load');
    });
  });

  group('FavouriteViewModel - addToFavourite', () {
    const tEntity = FavouriteEntity(customerId: 'c1', restaurantId: 'r1');

    test('should optimistically add and set status to added', () async {
      when(
        () => mockAddToFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Right([tEntity]));

      await getNotifier().addToFavourite(tEntity);

      final state = getState();
      expect(state.isFavourite, true);
      verify(() => mockAddToFavouriteUsecase(any())).called(1);
    });

    test('should revert on API failure', () async {
      const tFailure = ApiFailure(message: 'Add failed');
      when(
        () => mockAddToFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().addToFavourite(tEntity);

      final state = getState();
      expect(state.status, FavouriteStatus.error);
      expect(state.errorMessage, 'Add failed');
    });
  });

  group('FavouriteViewModel - removeFromFavourite', () {
    test('should optimistically remove and set status to removed', () async {
      when(
        () => mockRemoveFromFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Right(<FavouriteEntity>[]));

      await getNotifier().removeFromFavourite('r1');

      final state = getState();
      expect(state.isFavourite, false);
      verify(() => mockRemoveFromFavouriteUsecase(any())).called(1);
    });

    test('should revert on API failure', () async {
      const tFailure = ApiFailure(message: 'Remove failed');
      when(
        () => mockRemoveFromFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().removeFromFavourite('r1');

      final state = getState();
      expect(state.status, FavouriteStatus.error);
      expect(state.errorMessage, 'Remove failed');
    });
  });

  group('FavouriteViewModel - checkIsFavourite', () {
    test(
      'should set isFavourite to true when restaurant is favourite',
      () async {
        when(
          () => mockIsFavouriteUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        await getNotifier().checkIsFavourite('r1');

        final state = getState();
        expect(state.isFavourite, true);
      },
    );

    test(
      'should set isFavourite to false when restaurant is not favourite',
      () async {
        when(
          () => mockIsFavouriteUsecase(any()),
        ).thenAnswer((_) async => const Right(false));

        await getNotifier().checkIsFavourite('r1');

        final state = getState();
        expect(state.isFavourite, false);
      },
    );

    test('should emit error on failure', () async {
      const tFailure = ApiFailure(message: 'Check failed');
      when(
        () => mockIsFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      await getNotifier().checkIsFavourite('r1');

      final state = getState();
      expect(state.status, FavouriteStatus.error);
      expect(state.errorMessage, 'Check failed');
    });
  });

  group('FavouriteViewModel - isRestaurantFavourite', () {
    test('should return true when restaurant is in favourites list', () async {
      const tFavourites = [
        FavouriteEntity(customerId: 'c1', restaurantId: 'r1'),
      ];
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Right(tFavourites));

      await getNotifier().loadFavourites();

      expect(getNotifier().isRestaurantFavourite('r1'), true);
    });

    test(
      'should return false when restaurant is not in favourites list',
      () async {
        when(
          () => mockGetFavouritesUsecase(),
        ).thenAnswer((_) async => const Right(<FavouriteEntity>[]));

        await getNotifier().loadFavourites();

        expect(getNotifier().isRestaurantFavourite('r1'), false);
      },
    );
  });

  group('FavouriteViewModel - toggleFavourite', () {
    const tEntity = FavouriteEntity(customerId: 'c1', restaurantId: 'r1');

    test('should call addToFavourite when not currently favourite', () async {
      when(
        () => mockAddToFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Right(<FavouriteEntity>[]));

      // ensure empty list
      await getNotifier().loadFavourites();
      await getNotifier().toggleFavourite(tEntity);

      verify(() => mockAddToFavouriteUsecase(any())).called(1);
    });

    test('should call removeFromFavourite when currently favourite', () async {
      const tFavourites = [tEntity];
      when(
        () => mockGetFavouritesUsecase(),
      ).thenAnswer((_) async => const Right(tFavourites));
      when(
        () => mockRemoveFromFavouriteUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await getNotifier().loadFavourites();
      await getNotifier().toggleFavourite(tEntity);

      verify(() => mockRemoveFromFavouriteUsecase(any())).called(1);
    });
  });
}
