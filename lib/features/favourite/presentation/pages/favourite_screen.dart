import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:munch_nearby/features/favourite/presentation/widgets/favourite_empty_state.dart';
import 'package:munch_nearby/features/favourite/presentation/widgets/favourite_sort_bar.dart';
import 'package:munch_nearby/features/review/domain/usecases/get_restaurant_review_usecase.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/state/restaurant_state.dart';
import '../widgets/favourite_card.dart';

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  String sortBy = "name"; // name | rating
  Set<String> _ratingLoadedRestaurantIds = const {};
  Map<String, double> _averageRatingsByRestaurantId = const {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitialData);
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    await ref.read(favouriteViewModelProvider.notifier).loadFavourites();

    if (!mounted) return;

    final restaurantState = ref.read(restaurantViewModelProvider);

    if (restaurantState.status == RestaurantStatus.initial ||
        restaurantState.restaurants.isEmpty) {
      await ref.read(restaurantViewModelProvider.notifier).getRestaurants();
    }

    if (!mounted) return;

    final favouriteState = ref.read(favouriteViewModelProvider);
    final restaurantIds = favouriteState.favourites
        .map((fav) => fav.restaurantId)
        .toSet()
        .toList();

    await _loadAverageRatings(restaurantIds);
  }

  Future<void> _loadAverageRatings(List<String> restaurantIds) async {
    final uniqueIds = restaurantIds.toSet();

    if (uniqueIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _ratingLoadedRestaurantIds = const {};
        _averageRatingsByRestaurantId = const {};
      });
      return;
    }

    final getRestaurantReviews = ref.read(getRestaurantReviewsUsecaseProvider);
    final ratings = <String, double>{};

    for (final restaurantId in uniqueIds) {
      final result = await getRestaurantReviews(restaurantId);

      final averageRating = result.fold((_) => 0.0, (reviews) {
        if (reviews.isEmpty) return 0.0;

        final total = reviews.fold<int>(
          0,
          (sum, review) => sum + review.rating,
        );
        return total / reviews.length;
      });

      ratings[restaurantId] = averageRating;
    }

    if (!mounted) return;

    setState(() {
      _ratingLoadedRestaurantIds = uniqueIds;
      _averageRatingsByRestaurantId = ratings;
    });
  }

  bool _sameIds(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final id in a) {
      if (!b.contains(id)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final favouriteState = ref.watch(favouriteViewModelProvider);
    final restaurantState = ref.watch(restaurantViewModelProvider);

    final favRestaurants = restaurantState.restaurants.where((res) {
      return favouriteState.favourites.any((fav) => fav.restaurantId == res.id);
    }).toList();

    final favRestaurantIds = favRestaurants
        .map((restaurant) => restaurant.id)
        .toSet();
    if (!_sameIds(favRestaurantIds, _ratingLoadedRestaurantIds)) {
      Future.microtask(() => _loadAverageRatings(favRestaurantIds.toList()));
    }

    // SORT LOGIC (does not change your filtering logic)
    favRestaurants.sort((a, b) {
      if (sortBy == "rating") {
        final bRating = _averageRatingsByRestaurantId[b.id] ?? 0.0;
        final aRating = _averageRatingsByRestaurantId[a.id] ?? 0.0;
        final ratingCompare = bRating.compareTo(aRating);

        if (ratingCompare != 0) {
          return ratingCompare;
        }
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return Scaffold(
      body: Column(
        children: [
          FavouriteSortBar(
            sortBy: sortBy,
            onChanged: (value) {
              setState(() {
                sortBy = value;
              });
            },
          ),

          Expanded(
            child: favRestaurants.isEmpty
                ? const FavouriteEmptyState()
                : ListView.builder(
                    itemCount: favRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = favRestaurants[index];

                      return FavouriteCard(
                        restaurant: restaurant,
                        averageRating:
                            _averageRatingsByRestaurantId[restaurant.id] ?? 0.0,
                        onRemove: () {
                          ref
                              .read(favouriteViewModelProvider.notifier)
                              .removeFromFavourite(restaurant.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
