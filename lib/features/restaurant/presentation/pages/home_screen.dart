import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/state/restaurant_state.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(restaurantViewModelProvider.notifier).getRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Restaurants"),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(RestaurantState state) {
    switch (state.status) {


      case RestaurantStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case RestaurantStatus.error:
        return Center(
          child: Text(state.errorMessage ?? "Something went wrong"),
        );

      case RestaurantStatus.loaded:
        if (state.restaurants.isEmpty) {
          return const Center(
            child: Text("No restaurants found"),
          );
        }

       
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = state.restaurants[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RestaurantCard(
              restaurantId: restaurant.id,
              imageUrl: restaurant.imageUrl ?? "",
              name: restaurant.name,
              address: restaurant.address,
              mapLink: restaurant.mapLink ?? "",
              description: restaurant.description ?? "No description available",
              category: restaurant.category ?? "General",
            ),
            );
          },
        );

      default:
        return const SizedBox();
    }
  }
}