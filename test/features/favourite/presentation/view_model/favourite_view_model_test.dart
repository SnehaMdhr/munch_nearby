import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
  });

  group('FavouriteViewModel - addToFavourite', () {
    const tEntity = FavouriteEntity(customerId: 'c1', restaurantId: 'r1');

    test('should add and set status to added', () async {
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
  });
}
