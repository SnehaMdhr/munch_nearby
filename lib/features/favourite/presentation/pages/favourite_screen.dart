import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/state/restaurant_state.dart';
import '../widgets/favourite_card.dart'; // Import the new card

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(favouriteViewModelProvider.notifier).loadFavourites();

      final restaurantState = ref.read(restaurantViewModelProvider);
      if (restaurantState.status == RestaurantStatus.initial ||
          restaurantState.restaurants.isEmpty) {
        await ref.read(restaurantViewModelProvider.notifier).getRestaurants();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favouriteState = ref.watch(favouriteViewModelProvider);
    final restaurantState = ref.watch(restaurantViewModelProvider);

    final favRestaurants = restaurantState.restaurants.where((res) {
      return favouriteState.favourites.any((fav) => fav.restaurantId == res.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
      ),
      body: favRestaurants.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: favRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = favRestaurants[index];
                return FavouriteCard(
                  restaurant: restaurant,
                  onRemove: () {
                    ref.read(favouriteViewModelProvider.notifier)
                       .removeFromFavourite(restaurant.id);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No favorites yet!", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}